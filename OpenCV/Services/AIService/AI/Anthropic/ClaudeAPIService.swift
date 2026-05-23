//
//  ClaudeAPIService.swift
//  TDCodeReview
//
//  Created by Paul Leo on 24/05/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import Foundation
import SwiftAnthropic
import OSLog

final class ClaudeAPIService: @unchecked Sendable, AGIServiceProtocol {
    let keychainService = KeychainService()
    private var service: (any AnthropicService)?
    private var apiKey: String?
    private var historyList = [GPTMessage]()
    private var model: String {
        let modelString = UserDefaults.standard.claudeModel ?? ClaudeModel.default.id
        return modelString
    }

    init(apiKey: String? = nil) {
        Log.agi.debug("ClaudeAPIService init")
        var prepToken: String?
        if apiKey == nil {
            prepToken = keychainService[APIName.claude.rawValue]?.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            prepToken = apiKey?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        #if DEBUG
        if prepToken == nil {
            if let mockToken = Bundle.main.infoDictionary?["MOCK_CLAUDE_TOKEN"] as? String {
                prepToken = mockToken
            }
        }
        #endif
        self.apiKey = prepToken
        if let key = self.apiKey {
            self.service = AnthropicServiceFactory.service(apiKey: key, betaHeaders: nil)
        }
        setIsActive()
    }
    
    func setIsActive() {
        if let key = apiKey, !key.isEmpty {
            if !(UserDefaults.standard.hasClaudeKey ?? false) {
                UserDefaults.standard.hasClaudeKey = true
            }
        }
    }
    
    deinit {
        Log.agi.debug("deinit \(String(describing: type(of: self)))")
    }
    
    func setupHistory(for fileContent: String, selectedRows: Set<Int>, scopes: HistoryOptions, messages: [ChatMessage]) {
        deleteHistoryList()
        var userContent = ""
        if scopes.contains(.role) {
            let roleContent = (UserDefaults.standard.agiRole ?? AGIServiceConstants.agiRole) + " " + AGIServiceConstants.agiOutput
            userContent.append(roleContent)
        }
        if scopes.contains(.code) {
            userContent.append("\n" + fileContent)
        }
        if scopes.contains(.selection) {
            let selectionContent = processSelection(for: fileContent, selectedRows: selectedRows)
            userContent.append("\n" + selectionContent)
        }
        
        historyList.append(GPTMessage(role: ClaudeRole.user.rawValue, content: userContent))
        if scopes.contains(.messages) {
            let oldMessages = messages.compactMap { message -> GPTMessage? in
                return GPTMessage(id: message.id, role: ClaudeRole.assistant.rawValue, content: message.content)
            }
            historyList.append(contentsOf: oldMessages)
        }
    }
    
    func processSelection(for fileContent: String, selectedRows: Set<Int>) -> String {
        // Split the string into an array of lines
        let lines = fileContent.components(separatedBy: "\n")
        // Filter lines based on the rowIndexesToInclude Set
        let filteredLines = lines.enumerated().filter { selectedRows.contains($0.offset) }.map { $0.element }
        // Join the filtered lines back into a single string
        let filteredString = filteredLines.joined(separator: "\n")
        return filteredString
    }
    
    func getHistory() -> [GPTMessage] {
        return historyList
    }
    
    func addHistoryItem(message: ChatMessage) {
        let mess = GPTMessage(id: message.id, role: ClaudeRole.assistant.rawValue, content: message.content)
        historyList.append(mess)
    }
    
    func removeHistoryItem(message: ChatMessage) {
        if let index = historyList.firstIndex(where: { mess in
            mess.id == message.id
        }) {
            historyList.remove(at: index)
        }
    }
    
    func generateMessages(from text: String) -> [GPTMessage] {
        var messages = historyList + [GPTMessage(role: ClaudeRole.user.rawValue, content: text)]
        
        if messages.contentCount > (ClaudeModel.fromUserDefaults().maxTokens * 4) {
            _ = historyList.removeFirst()
            messages = generateMessages(from: text)
        }
        Log.agi.debug("Generated \(messages.count) messages")
        return messages
    }
    
    /// claude messages must alternate between roles
    private func processClaudeMessages(messages: [GPTMessage]) -> [MessageParameter.Message] {
        var orderedMessages = [GPTMessage]()
        messages.forEach {
            if !$0.content.isEmpty {
                if var lastClaudeMessage = orderedMessages.last {
                    if $0.role == lastClaudeMessage.role {
                        lastClaudeMessage.content = String(lastClaudeMessage.content + "\n" + $0.content)
                    } else {
                        orderedMessages.append($0)
                    }
                } else {
                    orderedMessages.append($0)
                }
            }
        }
        return orderedMessages.map { MessageParameter.Message(role: MessageParameter.Message.Role(rawValue: $0.role) ?? .user, content: .text($0.content)) }
    }
    
    private func appendToHistoryList(userText: String, responseText: String) {
        self.historyList.append(GPTMessage(role: ClaudeRole.user.rawValue, content: userText))
        self.historyList.append(GPTMessage(role: ClaudeRole.assistant.rawValue, content: responseText))
    }
    
    @MainActor
    func sendMessageStream(text: String, needsJSONResponse: Bool = false) async throws -> AsyncThrowingStream<String, any Error> {
        return AsyncThrowingStream<String, any Error> { continuation in
            Task(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                do {
                    let gptMessages = generateMessages(from: text)
                    let messages = processClaudeMessages(messages: gptMessages)
                    let parameters = MessageParameter(model: Model.other(self.model), messages: messages, maxTokens: 1024)
                    guard let service = self.service else { throw APIError.requestFailed(description: "Claude service has not been setup") }
                    let stream = try await service.streamMessage(parameters)
                        for try await result in stream {
                            let content = result.delta?.text ?? ""
                            continuation.yield(content)
                        }
                    
                    continuation.finish()
                } catch let error as APIError {
                    Log.agi.error("AGI stream error: \(error.displayDescription)")
                    continuation.finish(throwing: error)
                } catch {
                    Log.agi.error("AGI stream error: \(error.localizedDescription)")
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    func sendMessage(_ text: String) async throws -> String {
        // use streaming
        let messages = generateMessages(from: text).map { MessageParameter.Message(role: MessageParameter.Message.Role(rawValue: $0.role) ?? .user, content: .text($0.content)) }
        let parameters = MessageParameter(model: Model.other(self.model), messages: messages, maxTokens: 1024)
        let message = try await service?.createMessage(parameters)
        if case let .text(firstText, _) = message?.content.first {
            return firstText
        } else {
            throw TDAPIError.invalidResponse
        }
    }
    
    func deleteHistoryList() {
        self.historyList.removeAll()
    }
}

extension ClaudeAPIService: TokenServiceProtocol {
    
    var hasSetToken: Bool {
        if let token = apiKey {
            return !token.isEmpty
        }
        return false
    }
    
    func resetAccessToken(apiKey: String? = nil) {
        var prepToken: String? = apiKey
        if apiKey == nil {
            prepToken = keychainService[APIName.claude.rawValue]?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        self.apiKey = prepToken
    }
}
