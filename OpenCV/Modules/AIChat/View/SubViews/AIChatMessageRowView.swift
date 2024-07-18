//
//  AIChatMessageRowView.swift
//  OpenCV
//
//  Created by Paul Leo on 18/09/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import SwiftUI

struct AIChatMessageRowView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State var viewModel: AIChatMessagesViewModel
    @ObservedObject var message: ChatMessage

    var body: some View {
#if DEBUG
let _ = Self._printChanges()
#endif
        VStack(spacing: 0) {
            if message.isMine {
                myMessageContent
            } else {
                header
                messageContent
            }
            footer
        }
        .modifier(Card(isSelected: .constant(false), bgColor: message.isMine ? .blue : .orange))
        .padding(.leading, message.isMine ? 32 : 0)
    }
    
    @ViewBuilder
    var header: some View {
        HStack(alignment: .center) {
            Image(message.author.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
            Text(message.author.displayName)
                .lineLimit(1)
                .foregroundStyle(message.author.color)
                .shadow(radius: 1)
                .bold()
            Spacer()
            optionsMenu
        }
        .padding(.horizontal, 8)
        .padding(.top, 6)
    }
    
    @ViewBuilder
    var messageContent: some View {
        Text(message.markdown)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .foregroundStyle(.black)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
                .padding(.top, 2)
                .tint(.blue)
    }
    
    @ViewBuilder
    var myMessageContent: some View {
        HStack(alignment: .top) {
            Text(message.markdown)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.white)
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
    var footer: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(message.updatedAt.messageTime)
                .lineLimit(1)
                .font(.caption)
                .foregroundStyle(message.isMine ? .white : .black)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    var optionsMenu: some View {
        Menu {
            Button {
                self.viewModel.onTapCopyClipboard(message: message)
            } label: {
                Label("Copy to Clipboard", systemImage: "clipboard")
            }
            Button(role: .destructive) {
                withAnimation {
                    self.viewModel.onDelete(message: message)
                }                
            } label: {
                Label("Delete", systemImage: "trash")
            }
            Button(role: .cancel) {
            } label: {
                Text("Cancel")
            }
        } label: {
            Image(systemName: "ellipsis")
                .foregroundStyle(message.isMine ? .white : .black)
                .padding()
                .rotationEffect(.degrees(90))
                .frame(width: 30, height: 30)
        }
        .contentShape(Rectangle())
        .menuOrder(.fixed)
    }
}

#if DEBUG

#Preview {
    @Previewable @State var message1: ChatMessage = ChatMessage(author: .user("Paul"), content: "Hello worlds", resumeUrl: "")
    @Previewable @State var message2: ChatMessage = ChatMessage(author: .gemini("Gemini 1.5"), content: "Hello worlds", resumeUrl: "")
    @Previewable @State var message3: ChatMessage = ChatMessage(author: .claude("Claude 2"), content: "Addressing these challenges requires careful planning, engineering, and collaboration with relevant stakeholders to ensure successful implementation of solar panels in car parks while maximizing their benefits.", resumeUrl: "")
    @Previewable @State var message4: ChatMessage = ChatMessage(author: .openai("ChatGPT 4"), content: "Hello worlds", resumeUrl: "")
    
    ScrollView {
        LazyVStack {
            
            AIChatMessageRowView(viewModel: AIChatMessagesViewModel(modelContext: PreviewController.previewContainer.mainContext, person: Person(resumeUrl: ""), resume: Resume.mock()), message: message1)
                .padding()
            
            AIChatMessageRowView(viewModel: AIChatMessagesViewModel(modelContext: PreviewController.previewContainer.mainContext, person: Person(resumeUrl: ""), resume: Resume.mock()), message: message2)
                .padding()
            
            AIChatMessageRowView(viewModel: AIChatMessagesViewModel(modelContext: PreviewController.previewContainer.mainContext, person: Person(resumeUrl: ""), resume: Resume.mock()), message: message3)
                .padding()
            
            AIChatMessageRowView(viewModel: AIChatMessagesViewModel(modelContext: PreviewController.previewContainer.mainContext, person: Person(resumeUrl: ""), resume: Resume.mock()), message: message4)
                .padding()
        }
    }
    .modelContainer(PreviewController.previewContainer)
}
#endif
