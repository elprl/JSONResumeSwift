//
//  ClaudeSettingsViewModel.swift
//  TDCodeReview
//
//  Created by Paul Leo on 24/05/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

final class ClaudeSettingsViewModel: ObservableObject {
    private var keychainService = KeychainService()
    private var claudeService = ClaudeAPIService()
    @Published var userTokenMetadataList: [APIAccessToken] = []
    @Published var name: String = ""
    @Published var token: String = ""
    @Published var expirationIndex = 1
    @Published var shouldDismissInputView = false
    @Published var errorMessage: String = ""
    let expirationOptions = ["7 days", "30 days", "60 days", "90 days", "Custom", "No expiration"]
    private var apiAccount: UserAPIAccounts?
    @AppStorage(UserDefaults.Keys.claudeModel) var claudeModel: String = ClaudeModel.default.id
    @Published var modelSelection: ClaudeModel = ClaudeModel.fromUserDefaults() {
        didSet {
            self.claudeModel = modelSelection.id
        }
    }
    @AppStorage(UserDefaults.Keys.hasClaudeKey) var hasClaudeKey: Bool = false
    let userId = "userId"
    
    func loadAccessTokens() {
        self.apiAccount = UserDefaults.standard.getUserTokens(userId: userId)
        if self.apiAccount == nil {
            self.apiAccount = UserAPIAccounts(id: userId)
        }
        if let tokens = self.apiAccount?.tokens {
            self.userTokenMetadataList = tokens.filter({ token in
                return token.apiId == .claude
            })
        }
#if DEBUG
        if let keychainStore = self.keychainService[APIName.claude.rawValue] {
            let tokenHint: String = keychainStore.prefix(5) + "..." + keychainStore.suffix(3)
            let keyChainToken = APIAccessToken(id: APIName.claude.rawValue, tokenHint: tokenHint, expiry: nil, label: "(DEBUG) Apple Keychain", apiId: .claude)
            self.userTokenMetadataList.insert(keyChainToken, at: 0)
        }
#endif
        
    }
    
    @discardableResult private func addNewAccessToken(note: String, actualToken: String, expiryIndex: Int) -> APIAccessToken? {
        guard var account = self.apiAccount else { return nil }
        if note.isEmpty || actualToken.isEmpty { return nil }
        let tokenHint: String = actualToken.prefix(5) + "..." + actualToken.suffix(3)
        let tokenMetadata = APIAccessToken(id: UUID().uuidString, tokenHint: tokenHint, expiry: nil, label: note, apiId: .claude)
        saveAccessToken(id: tokenMetadata.id, actualToken: actualToken)
        self.userTokenMetadataList.append(tokenMetadata)
        account.tokens = self.userTokenMetadataList
        UserDefaults.standard.saveUserTokens(userId: userId, user: account)
        UserDefaults.standard.hasClaudeKey = true
        return tokenMetadata
    }

    private func saveAccessToken(id: String, actualToken: String) {
        self.keychainService[id] = actualToken
    }
    
    func isActiveAccessToken(id: String) -> Bool {
        let currentActiveToken = self.keychainService[APIName.claude.rawValue]
        let queryToken = self.keychainService[id]
        return currentActiveToken == queryToken
    }
    
    func makeActiveAccessToken(id: String) {
        let queryToken = self.keychainService[id]
        self.keychainService[APIName.claude.rawValue] = queryToken
        claudeService.resetAccessToken(apiKey: queryToken)
        self.objectWillChange.send()
    }
    
    func delete(at offsets: IndexSet) {
        guard var account = self.apiAccount else { return }
        self.userTokenMetadataList.remove(atOffsets: offsets)
        account.tokens = self.userTokenMetadataList
        UserDefaults.standard.saveUserTokens(userId: userId, user: account)
        if self.userTokenMetadataList.isEmpty {
            UserDefaults.standard.hasClaudeKey = false
        }
    }
    
    func didTapAdd() {
        if isValidForm() {
            if let userToken = addNewAccessToken(note: self.name, actualToken: self.token, expiryIndex: self.expirationIndex) {
                makeActiveAccessToken(id: userToken.id)
                self.shouldDismissInputView = true
                clearForm()
            }
        }
    }
    
    func clearForm() {
        self.errorMessage = ""
        self.name = ""
        self.token = ""
        self.expirationIndex = 1
    }
    
    func isValidForm() -> Bool {
        if name.isEmpty {
            errorMessage = "Note field is empty"
            return false
        }
            
        if token.isEmpty {
            errorMessage = "Token field is empty"
            return false
        }
        
        if token.count < 30 || token.count > 140 {
            errorMessage = "Token has an invalid length"
            return false
        }
        return true
    }
}

#if DEBUG

extension ClaudeSettingsViewModel {
    static func mock() -> ClaudeSettingsViewModel {
        let obj = ClaudeSettingsViewModel()
        let token = APIAccessToken.mock()
        obj.userTokenMetadataList = [token]
        obj.apiAccount = UserAPIAccounts(id: "1", tokens: [token])
        return obj
    }
}

#endif
