//
//  AIChatMessagesViewModel.swift
//  TDCodeReview
//
//  Created by Paul Leo on 18/09/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import SwiftData

@Observable
final class AIChatMessagesViewModel {
    var state: LoadingViewState<[ChatMessage]> = .appeared
    var newChatText: String = ""
    var newChatPlaceholderText: String?
    var replyPresent: Bool = false
    var selectedMessage: ChatMessage?
    var selectedMessageId: String?
    var currentSelectedRow: Int?
    var text: String = ""
    var selectedIndex: Int?
    var isAGIResponding: Bool = false
    var isScrollLockActive: Bool = true
    var hasRoleScope: Bool = true
    var hasSelectionScope: Bool = false {
        didSet {
            if hasSelectionScope && hasFileScope {
                self.hasFileScope = false
            }
        }
    }
    var hasFileScope: Bool = true {
        didSet {
            if hasSelectionScope && hasFileScope {
                self.hasSelectionScope = false
            }
        }
    }
    var hasHistoryScope: Bool = true
    var selectedAGI: AGIServiceChoice = .none
    var hasAgiKey: Bool = false
    var hasClaudeKey: Bool = false
    var hasGeminiKey: Bool = false
    var hasCustomAIHost: Bool = false
    var modelContext: ModelContext
    private let resumeUrl: String
    @ObservationIgnored private let agiService: AGIServiceProtocol
    @ObservationIgnored private var cancellables: [String: AnyCancellable] = [:]

    init(modelContext: ModelContext, resumeUrl: String, agiService: AGIServiceProtocol = ChatGPTAPIService()) {
        self.modelContext = modelContext
        self.resumeUrl = resumeUrl
        self.agiService = agiService
    }
    
    @MainActor
    func fetchData() async {
        do {
            let descriptor = FetchDescriptor<ChatMessage>(
                predicate: #Predicate { $0.resumeUrl == resumeUrl },
                sortBy: [SortDescriptor(\.updatedAt)]
            )
            let messages = try modelContext.fetch(descriptor)
            if messages.isEmpty {
                self.state = .empty("No messages found")
            } else {
                self.state = .loaded(messages)
            }
        } catch {
            print("Fetch failed")
            self.state = .error(error.localizedDescription)
        }
    }
  
    @MainActor
    func onSubmitNewMessage() async {
        let message = ChatMessage(author: .user(resumeUrl), content: newChatText, resumeUrl: resumeUrl)
        modelContext.insert(message)
        save()
        await handleAGIStream(content: String(newChatText))
        newChatText = ""
        await fetchData()
    }
    
    @MainActor
    func onDelete(message: ChatMessage) async {
        modelContext.delete(message)
        save()
        await fetchData()
    }
    
    func onTap(message: ChatMessage) {

    }
    
    func onTapScrollToBottom() {
        self.isScrollLockActive = true
    }
    
    func onUpKeyPressed() {

    }
    
    private var isValidMessage: Bool {
        if newChatText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false }
        if newChatText.trimmingCharacters(in: .whitespacesAndNewlines).count > 280 { // twitter char limit
            return false
        }
        return true
    }
    
    private func save() {
        do {
            try modelContext.save() // Ensure changes are saved to the context
        } catch {
            // Handle error appropriately
            print("Failed to save context: \(error)")
        }
    }
    
    func onTapCopyClipboard(message: ChatMessage) {
        UIPasteboard.general.string = message.content
    }
    
    @MainActor
    private func handleAGIStream(content: String) async {
        var streamText = ""
        
        let message = ChatMessage(author: .openai("gpt-4o"), content: "", resumeUrl: resumeUrl)
        modelContext.insert(message)
        save()
        
        Task { @MainActor in
            do {
                let stream = try await agiService.sendMessageStream(text: content, needsJSONResponse: false)
                for try await text in stream {
                    streamText += text
                    message.content = streamText
                }
//                save()
            } catch {
                message.content = error.localizedDescription
                return
            }
        }
    }
}
