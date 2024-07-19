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
    var messages: [ChatMessage] = []
    var state: LoadingViewState<[ChatMessage]> = .appeared
    var newChatText: String = ""
    var newChatPlaceholderText: String?
    var replyPresent: Bool = false
    var selectedMessage: ChatMessage?
    var selectedMessageId: String?
    var currentSelectedRow: Int?
    var agiContentCount: Int = 0
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
    var selectedAGI: AGIServiceChoice = UserDefaults.standard.selectedAGI ?? .none {
        didSet {
            switch selectedAGI {
            case .gemini:
                self.agiService = GeminiAPIService()
            case .claude:
                self.agiService = ClaudeAPIService()
            default:
                self.agiService = ChatGPTAPIService()
            }
        }
    }
    var hasAgiKey: Bool = UserDefaults.standard.hasAgiKey ?? false
    var hasClaudeKey: Bool = UserDefaults.standard.hasClaudeKey ?? false
    var hasGeminiKey: Bool = UserDefaults.standard.hasGeminiKey ?? false
    var modelContext: ModelContext
    var person: Person
    var resume: Resume
    var showingSettingsSheet = false
    @ObservationIgnored var scrollLockPublisher = PassthroughSubject<Bool, Never>()
    @ObservationIgnored private var scrollLockPublisherCancellable: AnyCancellable?
    @ObservationIgnored private var agiService: AGIServiceProtocol

    init(modelContext: ModelContext, person: Person, resume: Resume, agiService: AGIServiceProtocol = ChatGPTAPIService()) {
        self.modelContext = modelContext
        self.person = person
        self.resume = resume
        self.agiService = agiService
        
        // Debounce the scroll lock updates
        scrollLockPublisherCancellable = scrollLockPublisher
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .assign(to: \.isScrollLockActive, on: self)
    }
    
    @MainActor 
    func fetchData() {
        Task {
            do {
                let identifiers = try await performBackgroundQuery()
                
                let fetchedMessages = identifiers.compactMap {
                    self.modelContext.model(for: $0) as? ChatMessage
                }
                if fetchedMessages.isEmpty {
                    self.state = .empty("No messages found")
                } else {
                    self.state = .loaded([])
                    self.messages = fetchedMessages
                }
            } catch {
                print("Fetch failed")
                self.state = .error(error.localizedDescription)
            }
        }
    }
    
    /// background fetch
    func performBackgroundQuery() async throws -> [PersistentIdentifier] {
        let resumeUrl: String = person.resumeUrl
        let descriptor = FetchDescriptor<ChatMessage>(
            predicate: #Predicate { $0.resumeUrl == resumeUrl },
            sortBy: [SortDescriptor(\.updatedAt)]
        )
        let messages = try modelContext.fetch(descriptor)
        return messages.map( { $0.id } )
    }
    
    @MainActor
    func onSubmitNewMessage() {
        let message = ChatMessage(author: .user(person.resumeUrl), content: newChatText, resumeUrl: person.resumeUrl)
        modelContext.insert(message)
        save()
        messages.append(message)
        agiContentCount = 0
        handleAGIStream(content: String(newChatText))
        newChatText = ""
    }
    
    @MainActor
    func onDelete(message: ChatMessage) {
        messages.removeAll(where: { $0.id == message.id })
        modelContext.delete(message)
        save()
    }
    
    @MainActor
    func deleteAllMessages() {
        do {
            let resumeUrl: String = person.resumeUrl
            try modelContext.delete(model: ChatMessage.self, where: #Predicate { $0.resumeUrl == resumeUrl })
        } catch {
            print("Failed to delete all schools.")
        }
        save()
        messages.removeAll()
        fetchData()
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
    private func handleAGIStream(content: String) {
        var author = Author.openai(UserDefaults.standard.agiModel ?? "gpt-4o")
        switch selectedAGI {
        case .gemini:
            author = .gemini(UserDefaults.standard.geminiModel ?? "gemini-1.5-pro-latest")
        case .claude:
            author = .claude(UserDefaults.standard.claudeModel ?? "claude-3-sonnet-20240229")
        default:
            author = .openai(UserDefaults.standard.agiModel ?? "gpt-4o")
        }
        let message = ChatMessage(author: author, content: "", resumeUrl: person.resumeUrl)
        modelContext.insert(message)
        save()
        messages.append(message)
        let scopes = HistoryOptions.modeFrom(hasRole: hasRoleScope, hasCode: hasFileScope, hasHistory: hasHistoryScope, hasSelection: hasSelectionScope)
        agiService.setupHistory(for: resume.description, selectedRows: Set<Int>(), scopes: scopes, messages: messages)

        Task {
            do {
                var streamText = ""
                let stream = try await agiService.sendMessageStream(text: content, needsJSONResponse: false)
                for try await text in stream {
                    streamText += text
                    message.content = streamText
                    self.agiContentCount = streamText.count
                }
                save()
            } catch {
                message.content = error.localizedDescription
                return
            }
        }
    }
}
