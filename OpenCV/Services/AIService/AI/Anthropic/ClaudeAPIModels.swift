//
//  ClaudeAPIModels.swift
//  TDCodeReview
//
//  Created by Paul Leo on 08/11/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import Foundation
import SwiftAnthropic

enum ClaudeRole: String, Codable {
    case user, assistant
}

enum ClaudeModel {
    case opus(model: String, tokens: Int)
    case sonnet(model: String, tokens: Int)
    case haiku(model: String, tokens: Int)
    case custom(model: String, tokens: Int)
}
 
extension ClaudeModel: Hashable, Identifiable, Codable {
    static var `default`: ClaudeModel {
        return .sonnet(model: "claude-sonnet-4-6", tokens: 1050000)
    }

    static var allCases: [ClaudeModel] {
        return [
            .custom(model: "CUSTOM", tokens: 200000),
            .opus(model: "claude-opus-4-7", tokens: 1050000),
            .sonnet(model: "claude-sonnet-4-6", tokens: 1050000),
            .haiku(model: "claude-haiku-4-5", tokens: 200000),
        ]
    }
    
    var id: String {
        switch self {
        case .opus(let model, _), .sonnet(let model, _), .haiku(let model, _), .custom(let model, _):
            return model
        }
    }
    
    static func fromUserDefaults(key: String = UserDefaults.Keys.claudeModel) -> ClaudeModel {
        // Retrieve the model string from UserDefaults
        guard let modelString = UserDefaults.standard.string(forKey: key) else {
            return ClaudeModel.default
        }
        
        // Iterate through all cases to find a match
        for caseItem in allCases {
            switch caseItem {
            case .opus(let model, _), .sonnet(let model, _), .haiku(let model, _), .custom(let model, _):
                if model == modelString {
                    return caseItem
                }
            }
        }
        
        // If no match is found, return a custom model with the retrieved string
        return .custom(model: modelString, tokens: 100000)
    }
    
    var maxTokens: Int {
        switch self {
        case .opus(_, let tokens), .sonnet(_, let tokens), .haiku(_, let tokens), .custom(_, let tokens):
            return tokens
        }
    }
}

//extension SwiftAnthropic.APIError: LocalizedError, CustomStringConvertible {
//    public var description: String {
//        return displayDescription
//    }
//    
//    /// A localized message describing what error occurred.
//    public var errorDescription: String? {
//        return displayDescription
//    }
//}
