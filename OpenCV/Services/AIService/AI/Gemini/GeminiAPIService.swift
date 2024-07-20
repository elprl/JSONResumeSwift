//
//  GeminiAPIService.swift
//  TDCodeReview
//
//  Created by Paul Leo on 18/05/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import Foundation
import GoogleGenerativeAI

final class GeminiAPIService: ChatGPTAPIService, @unchecked Sendable {
    private var geminiClient: GenerativeModel?
    override var model: String {
        let modelString = UserDefaults.standard.geminiModel ?? "gemini-pro"
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
            self.geminiClient = GenerativeModel(name: model, apiKey: key)
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
        
        do {
            // gemini annoyingly only allows alternating between model and user
            for message in generateMessages(from: text) {
                var content = try ModelContent(role: GeminiRole.convertRole(message.role), message.content)
                if prevMessage.role == content.role {
                    content = try ModelContent(role: GeminiRole.convertRole(message.role), prevMessage.parts + [message.content])
                    if let index = modelContents.firstIndex(of: prevMessage) {
                        modelContents[index] = content
                    }
                } else {
                    modelContents.append(content)
                }
                prevMessage = content
            }
            
            // add the prompt
            var content = try ModelContent(role: GeminiRole.user.rawValue, text)
            if prevMessage.role == GeminiRole.user.rawValue {
                content = try ModelContent(role: GeminiRole.user.rawValue, prevMessage.parts + [text])
                if let index = modelContents.firstIndex(of: prevMessage) {
                    modelContents[index] = content
                }
            } else {
                modelContents.append(content)
            }
        } catch {
            print("Error generating messages: \(error)")
        }

        return modelContents
    }
    
    override func sendMessageStream(text: String, needsJSONResponse: Bool = false) async throws -> AsyncThrowingStream<String, Error> {
        return AsyncThrowingStream<String, Error> { continuation in
            Task(priority: .userInitiated) { [weak self] in
                guard let self = self else { return }
                do {
                    let messages: [ModelContent] = generateGeminiMessages(text: text)
                    guard let outputContentStream = geminiClient?.generateContentStream(messages) else { throw TDAPIError.invalidResponse }
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
                    var errorMessage: String = ""
                    switch error {
                    case let GenerateContentError.internalError(underlying: underlyingError):
                        Log.api.error("Gemini Failed: underlying error: \(underlyingError.localizedDescription)")
                        errorMessage = NSLocalizedString("Gemini Failed: Internal error", comment: "")
                    case let GenerateContentError.promptBlocked(response: generateContentResponse):
                        Log.api.error("Gemini Failed: promptBlocked error: \(generateContentResponse.text ?? "")")
                        errorMessage = NSLocalizedString("Gemini Failed: Your prompt was blocked", comment: "")
                    case let GenerateContentError.responseStoppedEarly(reason: finishReason, response: generateContentResponse):
                        Log.api.error("Gemini Failed: responseStoppedEarly error: \(generateContentResponse.text ?? "")")
                        errorMessage = NSLocalizedString("Gemini Failed: Response stopped early, \(finishReason.rawValue)", comment: "")
                    case GenerateContentError.invalidAPIKey:
                        errorMessage = NSLocalizedString("Gemini Failed: Invalid API Key", comment: "")
                    case GenerateContentError.unsupportedUserLocation:
                        errorMessage = NSLocalizedString("Gemini Failed: Unsupported User Location", comment: "")
                    default:
                        errorMessage = NSLocalizedString("Gemini Failed: Unknown error", comment: "")
                    }
                    Log.api.error("Error decoding gemini stream: \(errorMessage)")
                    continuation.finish(throwing: TDAPIError.streamError(errorMessage))
                }
            }
        }
    }
}

extension Array where Element == ModelContent {
    var contentCount: Int { reduce(0, { $0 + ($1.parts.first?.text?.count ?? 0) })}
}
