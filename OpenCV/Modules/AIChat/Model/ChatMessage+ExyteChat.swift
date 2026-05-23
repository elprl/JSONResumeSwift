//
//  ChatMessage+ExyteChat.swift
//  OpenCV
//
//  Created by Cursor on 23/05/2026.
//

import ExyteChat
import Foundation

extension ChatMessage {
    func toExyteMessage() -> ExyteChat.Message {
        ExyteChat.Message(
            id: messageId,
            user: ExyteChat.User(
                id: messageId,
                name: author.displayName,
                avatarURL: nil,
                isCurrentUser: isMine
            ),
            createdAt: updatedAt,
            text: content,
            customData: [
                "messageType": type.rawValue,
                "resumeUrl": resumeUrl
            ]
        )
    }
}

extension AIChatMessagesViewModel {
    var exyteMessages: [ExyteChat.Message] {
        messages.map { $0.toExyteMessage() }
    }

    func send(draft: DraftMessage) {
        send(text: draft.text)
    }

    func chatMessage(for exyteMessage: ExyteChat.Message) -> ChatMessage? {
        messages.first { $0.messageId == exyteMessage.id }
    }

    func isThinkingMessage(_ exyteMessage: ExyteChat.Message) -> Bool {
        guard isAGIResponding, let chatMessage = chatMessage(for: exyteMessage) else {
            return false
        }

        return chatMessage.type == .aiAnswer && chatMessage.content.isEmpty
    }
}
