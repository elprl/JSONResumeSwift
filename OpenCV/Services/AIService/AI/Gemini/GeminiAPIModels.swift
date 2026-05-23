//
//  GeminiAPIModels.swift
//  TDCodeReview
//
//  Created by Paul Leo on 06/01/2024.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.
//

import Foundation

enum GeminiRole: String, Codable {
    case user
    case model
}

extension GeminiRole {
    // convert role from GPTRole to GeminiRole
    static func convertRole(_ role: String) -> String {
        switch role {
        case GPTRole.user.rawValue:
            return "user"
        default:
            return "model"
        }
    }
}

enum GeminiModel {
    case geminiPro(model: String, tokens: Int)
    case geminiFlash(model: String, tokens: Int)
    case custom(model: String, tokens: Int)
}
 
extension GeminiModel: Hashable, Identifiable, Codable {    
    static var `default`: GeminiModel {
        return .geminiFlash(model: "gemini-3.5-flash", tokens: 1048576)
    }
    
    static var allCases: [GeminiModel] {
        return [
            .custom(model: "CUSTOM", tokens: 1048576),
            .geminiFlash(model: "gemini-3.5-flash", tokens: 1048576),
            .geminiFlash(model: "gemini-2.5-flash", tokens: 1048576),
            .geminiPro(model: "gemini-3.5-pro", tokens: 1048576),
            .geminiPro(model: "gemini-2.5-pro", tokens: 1048576),
        ]
    }
    
    var id: String {
        switch self {
        case .geminiPro(let model, _), .geminiFlash(let model, _), .custom(let model, _):
            return model
        }
    }
    
    static func fromUserDefaults(key: String = UserDefaults.Keys.geminiModel) -> GeminiModel {
        // Retrieve the model string from UserDefaults
        guard let modelString = UserDefaults.standard.string(forKey: key) else {
            return GeminiModel.default
        }
        
        // Iterate through all cases to find a match
        for caseItem in allCases {
            switch caseItem {
            case .geminiPro(let model, _), .geminiFlash(let model, _), .custom(let model, _):
                if model == modelString {
                    return caseItem
                }
            }
        }
        
        // If no match is found, return a custom model with the retrieved string
        return .custom(model: modelString, tokens: 1048576)
    }
    
    var maxTokens: Int {
        switch self {
        case .geminiPro(_, let tokens), .geminiFlash(_, let tokens), .custom(_, let tokens):
            return tokens
        }
    }
}
