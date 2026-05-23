//
//  ChatGPTAPIModels.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 03/03/23.
//

import Foundation

enum GPTRole: String, Codable {
    case user
    case system
    case assistant
}

struct GPTMessage: Codable, Identifiable {
    var id: String = UUID().uuidString
    let role: String
    var content: String
    
    private enum CodingKeys: CodingKey {
        case role
        case content
    }
}

enum GPTModel {
    case gpt5(model: String, tokens: Int)
    case gpt4(model: String, tokens: Int)
    case custom(model: String, tokens: Int)
}
 
extension GPTModel: Hashable, Identifiable, Codable {
    static var `default`: GPTModel {
        return .gpt5(model: "gpt-5.5", tokens: 1050000)
    }
    
    static var allCases: [GPTModel] {
        return [
            .custom(model: "CUSTOM", tokens: 1050000),
            .gpt5(model: "gpt-5.5", tokens: 1050000),
            .gpt5(model: "gpt-5.4", tokens: 1050000),
            .gpt5(model: "gpt-5.4-mini", tokens: 400000)
        ]
    }
    
    var id: String {
        switch self {
        case .gpt5(let model, _), .gpt4(let model, _), .custom(let model, _):
            return model
        }
    }
    
    static func fromUserDefaults(key: String = UserDefaults.Keys.openAiModel) -> GPTModel {
        // Retrieve the model string from UserDefaults
        guard let modelString = UserDefaults.standard.string(forKey: key) else {
            return GPTModel.default
        }
        
        // Iterate through all cases to find a match
        for caseItem in allCases {
            switch caseItem {
            case .gpt5(let model, _), .gpt4(let model, _), .custom(let model, _):
                if model == modelString {
                    return caseItem
                }
            }
        }
        
        // If no match is found, return a custom model with the retrieved string
        return .custom(model: modelString, tokens: 8192)
    }
    
    var maxTokens: Int {
        switch self {
        case .gpt5(_, let tokens), .gpt4(_, let tokens), .custom(_, let tokens):
            return tokens
        }
    }
}

extension Array where Element == GPTMessage {
    var contentCount: Int { reduce(0, { $0 + $1.content.count })}
}

struct Request: Codable {
    let model: String
    let temperature: Double
    let messages: [GPTMessage]
    let stream: Bool
    let responseFormat: ResponseFormat?
    
    private enum CodingKeys: String, CodingKey {
        case model
        case temperature
        case messages
        case stream
        case responseFormat = "response_format"
    }
}

struct ResponseFormat: Codable {
    let type: String
}

struct ErrorRootResponse: Decodable {
    let error: ErrorResponse
}

struct ErrorResponse: Decodable {
    let message: String
    let type: String?
}

struct StreamCompletionResponse: Decodable {
    let choices: [StreamChoice]
}

struct CompletionResponse: Decodable {
    let choices: [Choice]
    let usage: Usage?
}

struct Usage: Decodable {
    let promptTokens: Int?
    let completionTokens: Int?
    let totalTokens: Int?
}

struct Choice: Decodable {
    let message: GPTMessage
    let finishReason: String?
}

struct StreamChoice: Decodable {
    let finishReason: String?
    let delta: StreamMessage
}

struct StreamMessage: Decodable {
    let role: String?
    let content: String?
}
