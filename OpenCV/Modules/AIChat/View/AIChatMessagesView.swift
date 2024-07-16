//
//  AIChatMessagesView.swift
//  TDCodeReview
//
//  Created by Paul Leo on 18/09/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import SwiftData

struct AIChatMessagesView: View {
    @State private var viewModel: AIChatMessagesViewModel
    private let maxHeight: CGFloat = 200.0
    private let rowHeight: CGFloat = 60.0
    @FocusState private var isFocused: Bool

    init(modelContext: ModelContext, resumeUrl: String) {
        _viewModel = State(initialValue: AIChatMessagesViewModel(modelContext: modelContext, resumeUrl: resumeUrl))
    }
    
    var body: some View {
        VStack {
            switch viewModel.state {
            case .loading, .appeared:
                loadingView
                    .task { @MainActor in
                        await self.viewModel.fetchData()
                    }
            case .loaded(let messages):
                list(messages: messages)
                    .overlay(scrollToBottom)
            case .empty(_):
                noMessages
            case .error(let message):
                error(message: message)
            }
            Spacer()
            scope
            input
        }
        .padding()
        .navigationTitle("AI Chat")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    var loadingView: some View {
        ProgressView()
            .frame(width: 40, height: 40, alignment: .center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .transition(.scale)
    }
    
    @ViewBuilder
    private var noMessages: some View {
        if case .empty = viewModel.state {
            ContentUnavailableView(
                "No messages found",
                systemImage: "message",
                description: Text("Enter a new message below")
            )
            .contentShape(Rectangle())
        }
    }
    
    @ViewBuilder
    private func error(message: String) -> some View {
        Label(message, systemImage: "exclamationmark.octagon")
    }
    
    @ViewBuilder
    private func list(messages: [ChatMessage]) -> some View {
        ScrollViewReader { outerProxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    Rectangle().foregroundColor(.clear).frame(height: 1.0) // bug: https://stackoverflow.com/questions/66523786/swiftui-putting-a-lazyvstack-or-lazyhstack-in-a-scrollview-causes-stuttering-a
                        .padding(.top, 4)
                    ForEach(messages) { message in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                self.viewModel.selectedMessageId = message.messageId
                            }
                        }, label: {
                            AIChatMessageRowView(viewModel: viewModel, message: message)
                                .padding(.horizontal)
                                .padding(.bottom, 8)
                                .id(message.id)
                        })
                        .transition(.slide)
                    }
                    scrollToBottomDetector
                }
            }
            .onChange(of: messages.count) {
                withAnimation {
                    if self.viewModel.isScrollLockActive {
                        outerProxy.scrollTo(Int.max, anchor: .bottom)
                    }
                }
            }
            .onChange(of: self.viewModel.isAGIResponding) {
                withAnimation {
                    if self.viewModel.isScrollLockActive {
                        outerProxy.scrollTo(Int.max, anchor: .bottom)
                    }
                }
            }
            .onChange(of: self.viewModel.isScrollLockActive) { 
                withAnimation {
                    if self.viewModel.isScrollLockActive {
                        outerProxy.scrollTo(Int.max, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var scrollToBottom: some View {
        if !viewModel.isScrollLockActive {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    RoundButton(action: {
                        self.viewModel.onTapScrollToBottom()
                    }, imageSize: 44, icon: "chevron.down", bgColor: .purple, isLoading: .constant(false))
                    .padding(.bottom)
                    .padding(.trailing)
                }
            }
            .transition(.fade)
        }
    }
    
    @ViewBuilder
    var scrollToBottomDetector: some View {
        Color.clear
            .frame(width: 0, height: 30, alignment: .bottom)
            .onAppear {
                viewModel.isScrollLockActive = true
            }
            .onDisappear {
                viewModel.isScrollLockActive = false
            }
            .id(Int.max)
    }
    
    @ViewBuilder
    var scope: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Text("Scopes: ")
                ToggleButton(title: "role", isOn: $viewModel.hasRoleScope, onColor: .blue) {}
                ToggleButton(title: "CV", isOn: $viewModel.hasFileScope, onColor: .blue) {}
                ToggleButton(title: "history", isOn: $viewModel.hasHistoryScope, onColor: .blue) {}
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 2)
    }
    
    @ViewBuilder
    var input: some View {
        HStack(alignment: .center, spacing: 6) {
            commentButton
            TextField(viewModel.selectedAGI.placeholder, text: $viewModel.newChatText, axis: .vertical)
                .font(.body)
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
                .keyboardType(.asciiCapable)
                .focused($isFocused)
                .onSubmit {
                    self.viewModel.newChatText.append("\n")
                    self.isFocused = true
                }
                .submitLabel(.return)
                .lineLimit(1...10) // reservesSpace: true)
                .tint(.logoOrange)
                .foregroundColor(.primary)
            RoundButton(action: {
                Task { @MainActor in
                    print("submit")
                    await self.viewModel.onSubmitNewMessage()
                }
            }, imageSize: 30, icon: "paperplane.fill", bgColor: .blue, isLoading: .constant(false))
        }
    }
    
    @ViewBuilder
    var commentButton: some View {
        Menu {
            Section(header: Text("Select AI Service".uppercased()).font(.headline).foregroundColor(.orange)) {
                if viewModel.hasAgiKey {
                    Button {
                        self.viewModel.selectedAGI = .openai
                    } label: {
                        Label(AGIServiceChoice.openai.name, image: AGIServiceChoice.openai.imageKey)
                    }
                }
                if viewModel.hasClaudeKey {
                    Button {
                        self.viewModel.selectedAGI = .claude
                    } label: {
                        Label(AGIServiceChoice.claude.name, image: AGIServiceChoice.claude.imageKey)
                    }
                }
                if viewModel.hasGeminiKey {
                    Button {
                        self.viewModel.selectedAGI = .gemini
                    } label: {
                        Label(AGIServiceChoice.gemini.name, image: AGIServiceChoice.gemini.imageKey)
                    }
                }
                if viewModel.hasCustomAIHost {
                    Button {
                        self.viewModel.selectedAGI = .customAI
                    } label: {
                        Label(AGIServiceChoice.customAI.name, image: AGIServiceChoice.customAI.imageKey)
                    }
                }
            }
            Button(role: .cancel) {
            } label: {
                Text("Cancel")
            }
        } label: {
            Image(viewModel.selectedAGI.imageKey)
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(Color.gray)
                .clipShape(Circle())
                .contentShape(Circle())
        }
        .menuOrder(.fixed)
        .highPriorityGesture(TapGesture())
    }
}

#if DEBUG

#Preview {
    AIChatMessagesView(modelContext: PreviewController.previewContainer.mainContext, resumeUrl: "")
        .modelContainer(PreviewController.previewContainer)
        .previewLayout(.fixed(width: 320, height: 800))
}

#endif
