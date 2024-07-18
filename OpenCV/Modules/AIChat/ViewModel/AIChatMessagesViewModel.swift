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
    @MainActor var messages: [ChatMessage] = []
    @MainActor var state: LoadingViewState<[ChatMessage]> = .appeared
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
    var selectedAGI: AGIServiceChoice = UserDefaults.standard.selectedAGI ?? .none
    var hasAgiKey: Bool = UserDefaults.standard.hasAgiKey ?? false
    var hasClaudeKey: Bool = UserDefaults.standard.hasClaudeKey ?? false
    var hasGeminiKey: Bool = UserDefaults.standard.hasGeminiKey ?? false
    var modelContext: ModelContext
    var person: Person
    var resume: Resume
    var showingSettingsSheet = false
    @ObservationIgnored var scrollLockPublisher = PassthroughSubject<Bool, Never>()
    @ObservationIgnored private var scrollLockPublisherCancellable: AnyCancellable?
    @ObservationIgnored private let agiService: AGIServiceProtocol
    @ObservationIgnored private let dataService: DataService<ChatMessage>

    init(modelContext: ModelContext, person: Person, resume: Resume, agiService: AGIServiceProtocol = ChatGPTAPIService()) {
        self.modelContext = modelContext
        self.person = person
        self.resume = resume
        self.agiService = agiService
        self.dataService = DataService<ChatMessage>(modelContainer: modelContext.container)
        
        // Debounce the scroll lock updates
        scrollLockPublisherCancellable = scrollLockPublisher
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
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
    func onSubmitNewMessage() async {
        let message = ChatMessage(author: .user(person.resumeUrl), content: newChatText, resumeUrl: person.resumeUrl)
        modelContext.insert(message)
        save()
        messages.append(message)
        handleAGIStream(content: String(newChatText))
        newChatText = ""
    }
    
    @MainActor
    func onDelete(message: ChatMessage) async {
        do {
            await dataService.remove(id: message.id)
            try await dataService.save()
            fetchData()
        } catch {
            print("Save failed")
            self.state = .error(error.localizedDescription)
        }
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
        
        let message = ChatMessage(author: .openai("gpt-4o"), content: "", resumeUrl: person.resumeUrl)
        modelContext.insert(message)
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
                }
                save()
            } catch {
                message.content = error.localizedDescription
                return
            }
        }
    }
}
