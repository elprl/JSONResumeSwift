//
//  GeminiAPIService.swift
//  TDCodeReview
//
//  Created by Paul Leo on 18/05/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import Foundation
import FirebaseAILogic
import OSLog

final class GeminiAPIService: ChatGPTAPIService, @unchecked Sendable {
    private var geminiClient: GenerativeModel?
    override var model: String {
        let modelString = UserDefaults.standard.geminiModel ?? GeminiModel.default.id
        return modelString
    }
    override var urlRequest: URLRequest {
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta3/models/\(model):generateContent?key=\(apiKey ?? "")")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        headers.forEach {  urlRequest.setValue($1, forHTTPHeaderField: $0) }
        return urlRequest
    }
    override var headers: [String: String] {
        [
            "Content-Type": "application/json"
        ]
    }

    override init(apiKey: String? = nil) {
        super.init(apiKey: apiKey)
        Log.agi.debug("GeminiAPIService init")
        var prepToken: String?
        if apiKey == nil {
            prepToken = keychainService[APIName.gemini.rawValue]?.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            prepToken = apiKey?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        #if DEBUG
        if prepToken == nil {
            if let mockToken = Bundle.main.infoDictionary?["MOCK_GEMINI_TOKEN"] as? String {
                prepToken = mockToken
            }
        }
        #endif
        self.apiKey = prepToken
        setIsActive()
    }
    
    override func setIsActive() {
        if let key = self.apiKey, !key.isEmpty {
            // Initialize the Gemini Developer API backend service
            let ai = FirebaseAI.firebaseAI(backend: .googleAI())

            // Create a `GenerativeModel` instance with a model that supports your use case
            let client = ai.generativeModel(modelName: model)

            self.geminiClient = client
            if !(UserDefaults.standard.hasGeminiKey ?? false) {
                UserDefaults.standard.hasGeminiKey = true
            }
        }
    }
    
    override func resetAccessToken(apiKey: String? = nil) {
        var prepToken: String? = apiKey
        if apiKey == nil {
            prepToken = keychainService[APIName.gemini.rawValue]?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        self.apiKey = prepToken
        setIsActive()
    }
    
    override func generateMessages(from text: String) -> [GPTMessage] {
        var messages = historyList
        
        if messages.contentCount > (GeminiModel.fromUserDefaults().maxTokens * 4) { // rough alternative to token counting
            _ = historyList.removeFirst()
            messages = generateMessages(from: text)
        }
        Log.agi.debug("Generated \(messages.count) messages")
        return messages
    }
    
    /// Annoyingly Google requires awkward consolidation of messages and only allows alternating between roles
    private func generateGeminiMessages(text: String) -> [ModelContent] {
        var prevMessage: ModelContent = ModelContent(role: GeminiRole.model.rawValue, parts: "Hi, behaving as a software engineer, how can I help?")
        // gemini only seems to allow a starting with a user message and must include a model message
        var modelContents: [ModelContent] = [
            ModelContent(role: GeminiRole.user.rawValue, parts: "Hi, I'm a software engineer."),
            prevMessage
        ]
        
        // gemini annoyingly only allows alternating between model and user
        for message in generateMessages(from: text) {
            let role = GeminiRole.convertRole(message.role)
            var content = ModelContent(role: role, parts: message.content)
            if prevMessage.role == content.role {
                let mergedText = Self.mergedText(from: prevMessage, appending: message.content)
                content = ModelContent(role: role, parts: mergedText)
                if let index = modelContents.firstIndex(of: prevMessage) {
                    modelContents[index] = content
                }
            } else {
                modelContents.append(content)
            }
            prevMessage = content
        }
        
        // add the prompt
        var content = ModelContent(role: GeminiRole.user.rawValue, parts: text)
        if prevMessage.role == GeminiRole.user.rawValue {
            let mergedText = Self.mergedText(from: prevMessage, appending: text)
            content = ModelContent(role: GeminiRole.user.rawValue, parts: mergedText)
            if let index = modelContents.firstIndex(of: prevMessage) {
                modelContents[index] = content
            }
        } else {
            modelContents.append(content)
        }

        return modelContents
    }
    
    override func sendMessageStream(text: String, needsJSONResponse: Bool = false) async throws -> AsyncThrowingStream<String, any Error> {
        return AsyncThrowingStream<String, any Error>(bufferingPolicy: .unbounded) { continuation in
            Task(priority: .userInitiated) { [weak self] in
                guard let self = self else { return }
                do {
                    let messages: [ModelContent] = generateGeminiMessages(text: text)
                    guard let outputContentStream = try geminiClient?.generateContentStream(messages) else {
                        throw TDAPIError.invalidResponse
                    }
                    var outputText: String = ""
                    
                    // stream response
                    for try await chunk in outputContentStream {
                        if let line = chunk.text {
                            outputText += line
                            continuation.yield(line)
                        }
                    }
                    Log.api.debug("outputText: \(outputText)")
                    continuation.finish()
                } catch {
                    let errorMessage = Self.errorMessage(for: error)
                    Log.api.error("Error decoding gemini stream: \(errorMessage)")
                    continuation.finish(throwing: TDAPIError.streamError(errorMessage))
                }
            }
        }
    }
    
    private static func mergedText(from content: ModelContent, appending text: String) -> String {
        let existingText = content.parts.compactMap { $0 as? TextPart }.map(\.text).joined()
        guard !existingText.isEmpty else { return text }
        return existingText + "\n" + text
    }
    
    private static func errorMessage(for error: any Error) -> String {
        switch error {
        case let GenerateContentError.internalError(underlying: underlyingError):
            Log.api.error("Gemini Failed: underlying error: \(underlyingError.localizedDescription)")
            return NSLocalizedString("Gemini Failed: Internal error. Check billing & availability in your country.", comment: "")
        case let GenerateContentError.promptBlocked(response: generateContentResponse):
            Log.api.error("Gemini Failed: promptBlocked error: \(generateContentResponse.text ?? "")")
            return NSLocalizedString("Gemini Failed: Your prompt was blocked", comment: "")
        case let GenerateContentError.responseStoppedEarly(reason: finishReason, response: generateContentResponse):
            Log.api.error("Gemini Failed: responseStoppedEarly error: \(generateContentResponse.text ?? "")")
            return NSLocalizedString("Gemini Failed: Response stopped early, \(finishReason.rawValue)", comment: "")
        case let GenerateContentError.promptImageContentError(underlying: underlyingError):
            Log.api.error("Gemini Failed: prompt image error: \(underlyingError.localizedDescription)")
            return NSLocalizedString("Gemini Failed: Invalid prompt content", comment: "")
        default:
            return NSLocalizedString("Gemini Failed: Unknown error", comment: "")
        }
    }
}

extension Array where Element == ModelContent {
    var contentCount: Int {
        reduce(0) { count, content in
            count + content.parts.compactMap { $0 as? TextPart }.map(\.text.count).reduce(0, +)
        }
    }
}
