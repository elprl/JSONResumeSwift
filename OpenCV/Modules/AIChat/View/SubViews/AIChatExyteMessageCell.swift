//
//  AIChatExyteMessageCell.swift
//  OpenCV
//
//  Created by Cursor on 23/05/2026.
//

import ExyteChat
import SwiftUI

struct AIChatExyteMessageCell: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let exyteMessage: ExyteChat.Message
    let chatMessage: ChatMessage?
    var viewModel: AIChatMessagesViewModel
    let isThinking: Bool

    private var isMine: Bool {
        chatMessage?.isMine ?? exyteMessage.user.isCurrentUser
    }

    private var content: String {
        chatMessage?.content ?? exyteMessage.text
    }

    private var messageType: MessageType {
        chatMessage?.type ?? .note
    }

    private var bubbleColor: Color {
        chatMessage?.color ?? .blue
    }

    private var textColor: Color {
        messageType == .aiQuestion ? .white : .black
    }

    private var horizontalPadding: CGFloat {
        horizontalSizeClass == .regular ? 48 : 16
    }

    var body: some View {
        HStack {
            if isMine {
                Spacer(minLength: 32)
            }

            VStack(spacing: 0) {
                if isMine {
                    myMessageContent
                } else {
                    header
                    messageContent
                }
                footer
            }
            .modifier(Card(isSelected: .constant(false), bgColor: bubbleColor))
            .contextMenu {
                optionsMenuItems
            }

            if !isMine {
                Spacer(minLength: 32)
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private var header: some View {
        if let chatMessage {
            HStack(alignment: .center) {
                Image(chatMessage.author.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .environment(\.colorScheme, .light)
                Text(chatMessage.author.displayName)
                    .lineLimit(1)
                    .foregroundStyle(textColor)
                    .bold()
                Spacer()
                optionsMenu
            }
            .padding(.horizontal, 8)
            .padding(.top, 6)
        }
    }

    @ViewBuilder
    private var messageContent: some View {
        if isThinking && content.isEmpty {
            HStack(spacing: 8) {
                ProgressView()
                    .controlSize(.small)
                Text("Thinking...")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.top, 6)
        } else {
            Text(LocalizedStringKey(content))
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .foregroundStyle(textColor)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
                .padding(.top, 2)
                .tint(.blue)
        }
    }

    @ViewBuilder
    private var myMessageContent: some View {
        HStack(alignment: .top) {
            Text(LocalizedStringKey(content))
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .foregroundStyle(textColor)
                .font(.body)
                .padding(.leading, 8)
                .padding(.top, 2)
                .tint(.blue)
            Spacer()
            optionsMenu
        }
        .padding(.horizontal, 6)
        .padding(.top, 6)
    }

    @ViewBuilder
    private var footer: some View {
        HStack(alignment: .center, spacing: 8) {
            Text((chatMessage?.updatedAt ?? exyteMessage.createdAt).messageTime)
                .lineLimit(1)
                .font(.caption)
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private var optionsMenu: some View {
        if chatMessage != nil {
            Menu {
                optionsMenuItems
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(textColor)
                    .padding()
                    .rotationEffect(.degrees(90))
                    .frame(width: 30, height: 30)
            }
            .contentShape(Rectangle())
            .menuOrder(.fixed)
        }
    }

    @ViewBuilder
    private var optionsMenuItems: some View {
        if let chatMessage {
            Button {
                viewModel.onTapCopyClipboard(message: chatMessage)
            } label: {
                Label("Copy to Clipboard", systemImage: "clipboard")
            }
            Button(role: .destructive) {
                withAnimation {
                    viewModel.onDelete(message: chatMessage)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
