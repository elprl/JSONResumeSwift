//
//  MessageScrollView.swift
//  OpenCV
//
//  Created by Paul Leo on 20/07/2024.
//
import ExyteChat
import SwiftUI

struct MessageScrollView: View {
    var viewModel: AIChatMessagesViewModel
    @AppStorage(UserDefaults.Keys.hasAgiKey) var hasAgiKey: Bool = false
    @AppStorage(UserDefaults.Keys.hasClaudeKey) var hasClaudeKey: Bool = false
    @AppStorage(UserDefaults.Keys.hasGeminiKey) var hasGeminiKey: Bool = false

    var body: some View {
        ChatView(messages: viewModel.exyteMessages) { draft in
            viewModel.send(draft: draft)
        } messageBuilder: { params in
            AIChatExyteMessageCell(
                exyteMessage: params.message,
                chatMessage: viewModel.chatMessage(for: params.message),
                viewModel: viewModel,
                isThinking: viewModel.isThinkingMessage(params.message)
            )
        } inputViewBuilder: { params in
            AIChatInputBar(params: params, viewModel: viewModel)
        }
        .setAvailableInputs([.text])
        .showScrollToBottomButton(true)
        .showMessageMenuOnLongPress(false)
        .showDateHeaders(false)
        .mainHeaderBuilder {
            Group {
                if viewModel.messages.isEmpty {
                    emptyState
                }
            }
        }
        .chatTheme(
            ChatTheme(
                colors: ChatTheme.Colors(
                    mainBG: .clear,
                    mainTint: .logoOrange,
                    sendButtonBackground: .blue
                )
            )
        )
    }

    @ViewBuilder
    private var emptyState: some View {
        if hasAgiKey || hasClaudeKey || hasGeminiKey {
            ContentUnavailableView(
                "No messages found",
                systemImage: "message",
                description: Text("Enter a new message or note below")
            )
        } else {
            ContentUnavailableView(
                "No messages found",
                systemImage: "message",
                description: Text("Enter a new note below.\nTo chat with AI, add an API key in Settings")
            )
        }
    }
}
