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
    var messages: [ChatMessage] = [] {
        didSet {
            if messages.isEmpty {
                self.state = .empty("No messages found")
            } else {
                self.state = .loaded(messages)
            }
        }
    }
    var state: LoadingViewState<[ChatMessage]> = .appeared
    var newChatText: String = ""
    var selectedMessageId: String?
    var agiContentCount: Int = 0
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
    var modelContext: ModelContext
    var person: Person
    var resume: Resume
    var showingSettingsSheet = false
    @ObservationIgnored var scrollLockPublisher = PassthroughSubject<Bool, Never>()
    @ObservationIgnored private var cancellables: [AnyCancellable] = []
    @ObservationIgnored private var agiService: AGIServiceProtocol?

    init(modelContext: ModelContext, person: Person, resume: Resume) {
        self.modelContext = modelContext
        self.person = person
        self.resume = resume
        
        // Debounce the scroll lock updates
        scrollLockPublisher
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .assign(to: \.isScrollLockActive, on: self)
            .store(in: &cancellables)
    }
    
//    @MainActor
    func updateAGIService(selectedAGI: AGIServiceChoice) {
        switch selectedAGI {
        case .gemini:
            self.agiService = GeminiAPIService()
        case .claude:
            self.agiService = ClaudeAPIService()
        case .none:
            self.agiService = nil
        default:
            self.agiService = ChatGPTAPIService()
        }
    }
    
    @MainActor 
    func fetchData() {
        Task {
            do {
                let identifiers = try await performBackgroundQuery()
                let fetchedMessages = identifiers.compactMap {
                    self.modelContext.model(for: $0) as? ChatMessage
                }
                self.messages = fetchedMessages
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
    
//    @MainActor
    func onSubmitNewMessage() {
        Task {
            let message = ChatMessage(author: .user(person.resumeUrl), content: newChatText, resumeUrl: person.resumeUrl)
            if UserDefaults.standard.selectedAGI != AGIServiceChoice.none {
                message.type = .aiQuestion
            }
            modelContext.insert(message)
            messages.append(message)
            newChatText = ""
            Log.pres.debug("Inserted question/note message")
            if agiService != nil {
                agiContentCount = 0
                await handleAGIStream(content: String(newChatText))
            }
        }
    }
    
    @MainActor
    func onDelete(message: ChatMessage) {
        messages.removeAll(where: { $0.id == message.id })
        modelContext.delete(message)
        Log.pres.debug("deleted message")
    }
    
    @MainActor
    func deleteAllMessages() {
        do {
            let resumeUrl: String = person.resumeUrl
            try modelContext.delete(model: ChatMessage.self, where: #Predicate { $0.resumeUrl == resumeUrl })
            Log.pres.debug("deleted all schools.")
        } catch {
            Log.pres.error("Failed to delete all schools.")
        }
        messages.removeAll()
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
            Log.pres.debug("Saved data context")
        } catch {
            // Handle error appropriately
            Log.pres.error("Failed to save context: \(error)")
        }
    }
    
    func onTapCopyClipboard(message: ChatMessage) {
        UIPasteboard.general.string = message.content
    }
    
    @MainActor
    private func handleAGIStream(content: String) async {
        Task {
            var author = Author.openai(UserDefaults.standard.agiModel ?? "gpt-4o")
            let currentSelectedAGI = UserDefaults.standard.selectedAGI ?? .none
            switch currentSelectedAGI {
            case .gemini:
                author = .gemini(UserDefaults.standard.geminiModel ?? "gemini-1.5-pro-latest")
            case .claude:
                author = .claude(UserDefaults.standard.claudeModel ?? "claude-3-sonnet-20240229")
            default:
                author = .openai(UserDefaults.standard.agiModel ?? "gpt-4o")
            }
            let message = ChatMessage(author: author, content: "", resumeUrl: person.resumeUrl)
            message.type = .aiAnswer
            modelContext.insert(message)
            messages.append(message)
            Log.pres.debug("Added blank AGI message")
            guard let agiService else { return }
            let scopes = HistoryOptions.modeFrom(hasRole: hasRoleScope, hasCode: hasFileScope, hasHistory: hasHistoryScope, hasSelection: hasSelectionScope)
            agiService.setupHistory(for: resume.description, selectedRows: Set<Int>(), scopes: scopes, messages: messages)
            
            do {
                var streamText = ""
                let stream = try await agiService.sendMessageStream(text: content, needsJSONResponse: false)
                for try await text in stream {
                    streamText += text
                    message.content = streamText
                    self.agiContentCount = streamText.count
                }
            } catch {
                Log.pres.error("Error thrown with message stream: \(error.localizedDescription)")
                message.content = error.localizedDescription
                return
            }
        }
    }
}
