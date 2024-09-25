//
//  AGIService.swift
//  TDCodeReview
//
//  Created by Paul Leo on 30/03/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import GPT3_Tokenizer

protocol AGIServiceProtocol: TokenServiceProtocol {
    func sendMessageStream(text: String, needsJSONResponse: Bool) async throws -> AsyncThrowingStream<String, any Error>
    func sendMessage(_ text: String) async throws -> String
    func generateMessages(from text: String) -> [GPTMessage]
    func setupHistory(for fileContent: String, selectedRows: Set<Int>, scopes: HistoryOptions, messages: [ChatMessage])
    func getHistory() -> [GPTMessage]
    func addHistoryItem(message: ChatMessage)
    func removeHistoryItem(message: ChatMessage)
    func deleteHistoryList()
}

extension AGIServiceProtocol {
    func numTokensFromMessages(messages: [ChatMessage]) -> Int {
        let gpt3Tokenizer = GPT3Tokenizer()
        var numTokens = 0
        for message in messages {
            numTokens += 3
            let encoded = gpt3Tokenizer.encoder.enconde(text: message.content)
            numTokens += encoded.count
        }
        numTokens += 2
        return numTokens
    }
}

enum TDAPIError: LocalizedError {
    case invalidJsonEncoding
    case invalidJsonDecoding
    case invalidResponse
    case badResponse(Int, String)
    case urlSessionError(String)
    case streamError(String)
    case invalidParams(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidJsonEncoding:
            return NSLocalizedString("Invalid JSON encoding.", comment: "")
        case .invalidJsonDecoding:
            return NSLocalizedString("Invalid JSON decoding.", comment: "")
        case .invalidResponse:
            return NSLocalizedString("Invalid response.", comment: "")
        case .badResponse(_, let message):
            return message
        case .urlSessionError(let description):
            return description
        case .streamError(let description):
            return description
        case .invalidParams(let description):
            return description
        }
    }
}

struct AGIServiceConstants {
    static let agiRole = "Play the role of a mentoring careers consultant who regularly assesses CVs and gives constructive advice."
    static let agiReviewQ = "Question: perform a detailed code review of the above code. A Peer Code Review should focus on what should be improved in the following categories: architecture, code, design, error handling, maintainability, performance, scalability, readability, security, testability (but not exclusively). Avoid a Static Analysis type of review. "
    static let agiOutput = "Give all output in the basic Markdown a SwiftUI Text object can handle (e.g.: **bold**, *italics*, ~~strikethrough~~, [link](https://apple.com), 'code')."
    static let agiReflectionQ = "Did your answer meet the requirements of my question?"
    static let agiChainOfThought = "Answer: Let's work through the review step by step to be sure we have the right answer."
}

struct HistoryOptions: OptionSet {
    let rawValue: Int
    
    static let none = HistoryOptions(rawValue: 1 << 0)
    static let role = HistoryOptions(rawValue: 1 << 1)
    static let selection = HistoryOptions(rawValue: 1 << 2)
    static let code = HistoryOptions(rawValue: 1 << 3)
    static let messages = HistoryOptions(rawValue: 1 << 4)
    static let all: HistoryOptions = [.role, .selection, .code, .messages] // Combines all options
    
    static func modeFrom(hasRole: Bool, hasCode: Bool, hasHistory: Bool, hasSelection: Bool) -> Self {
        var scopes: HistoryOptions = []
        if hasRole {
            scopes.insert(HistoryOptions.role)
        }
        if hasCode {
            scopes.insert(HistoryOptions.code)
        }
        if hasHistory {
            scopes.insert(HistoryOptions.messages)
        }
        if hasSelection {
            scopes.insert(HistoryOptions.selection)
        }
        return scopes
    }
}

enum AGIServiceChoice: String {
    case openai = "0"
    case gemini = "1"
    case claude = "2"
    case customAI = "3"
    case none = "-1"
    
    var defaultModel: String {
        switch self {
        case .openai:
            return UserDefaults.standard.openAiModel ?? "gpt-4o-mini"
        case .gemini:
            return UserDefaults.standard.geminiModel ?? GeminiModel.default.id
        case .claude:
            return UserDefaults.standard.claudeModel ?? ClaudeModel.default.id
        case .customAI:
            return UserDefaults.standard.customAIModel ?? "Hermes"
        default:
            return "Not set"
        }
    }
    
    var name: String {
        switch self {
        case .openai:
            return "ChatGPT"
        case .claude:
            return "Claude"
        case .gemini:
            return "Gemini"
        case .customAI:
            return "Custom AI"
        default:
            return "Not set"
        }
    }
    
    var imageKey: String {
        switch self {
        case .openai:
            return "openai-logomark"
        case .claude:
            return "claudeSpark"
        case .gemini:
            return "geminiIcon"
        case .customAI:
            return "brain.head.profile"
        case .none:
            return "note"
        }
    }
    
    var systemImageKey: String {
        switch self {
        case .openai:
            return "atom"
        case .claude:
            return "staroflife.fill"
        case .gemini:
            return "sparkle"
        case .customAI:
            return "brain.head.profile"
        case .none:
            return "note"
        }
    }
    
    var placeholder: String {
        switch self {
        case .openai, .claude, .gemini, .customAI:
            return NSLocalizedString("Chat with \(self.defaultModel)", comment: "")
        case .none:
            return NSLocalizedString("Add personal note", comment: "")
        }
    }
}

enum AnnotationMode: String {
    case text = "0"
    case annotations = "1"
}
