//
//  ChatMessage.swift
//  OpenCV
//
//  Created by Paul Leo on 16/07/2024.
//

import Foundation
import SwiftData
import SwiftUI

enum Author: Codable {
    case gemini(String)
    case openai(String)
    case claude(String)
    case user(String)
    
    var displayName: String {
        switch self {
        case .gemini(let model):
            return model
        case .openai(let model):
            return model
        case .claude(let model):
            return model
        case .user(let username):
            return username
        }
    }
    
    var color: Color {
        switch self {
        case .gemini(_):
            return .blue
        case .openai(_):
            return .black
        case .claude(_):
            return .brown
        case .user(_):
            return .blue
        }
    }
    
    var image: String {
        switch self {
        case .gemini(_):
            return "geminiIcon"
        case .openai(_):
            return "openai-logomark"
        case .claude(_):
            return "claudeSpark"
        case .user(_):
            return "brain"
        }
    }
}

enum MessageType: String, Codable {
    case note
    case aiQuestion
    case aiAnswer
    case image
    case doc
    case emoji
}

@Model
final class ChatMessage: ObservableObject {
    @Attribute(.unique) var messageId: String
    var author: Author
    var content: String
    var resumeUrl: String
    var createdAt: Date
    var updatedAt: Date
    var parentId: String?
    var isStarred: Bool?
    var type: MessageType

    init(author: Author, content: String, resumeUrl: String) {
        self.messageId = UUID().uuidString
        self.author = author
        self.content = content
        self.resumeUrl = resumeUrl
        self.createdAt = Date()
        self.updatedAt = Date()
        self.type = .note
    }
}

extension ChatMessage: Identifiable, Equatable {
    var id: String {
        return messageId
    }
    
    var isMine: Bool {
        switch author {
        case .user(_): return true
        default: return false
        }
    }
    
    var color: Color {
        switch type {
        case .note:
            Color(red: 0.90, green: 0.94, blue: 0.63, opacity: 1.00)
        case .aiQuestion:
                .blue
        case .aiAnswer:
                .orange
        default:
                .blue
        }
    }
    
    var markdown: LocalizedStringKey {
        return LocalizedStringKey(content)
    }
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.messageId == rhs.messageId && lhs.content == rhs.content && lhs.updatedAt == rhs.updatedAt
    }
}
