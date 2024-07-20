//
//  OpenAISettingsViewModel.swift
//  TDCodeReview
//
//  Created by Paul Leo on 08/04/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

final class OpenAISettingsViewModel: ObservableObject {
    private var keychainService = KeychainService()
    private var agiService = ChatGPTAPIService()
    @Published var userTokenMetadataList: [APIAccessToken] = []
    @Published var name: String = ""
    @Published var token: String = ""
    @Published var expirationIndex = 1
    @Published var shouldDismissInputView = false
    @Published var errorMessage: String = ""
    let expirationOptions = ["7 days", "30 days", "60 days", "90 days", "Custom", "No expiration"]
    private var openAIAccount: UserAPIAccounts?
    @AppStorage(UserDefaults.Keys.openAiModel) var openAiModel: String = "gpt-3.5-turbo"
    @Published var modelSelection: GPTModel = GPTModel.fromUserDefaults() {
        didSet {
            self.openAiModel = modelSelection.id
        }
    }
    @AppStorage(UserDefaults.Keys.agiRole) var agiRole: String = AGIServiceConstants.agiRole
    @AppStorage(UserDefaults.Keys.hasAgiKey) var hasAgiKey: Bool = false
    let userId = "userId"

    func loadAccessTokens() {
        self.openAIAccount = UserDefaults.standard.getUserTokens(userId: userId)
        if self.openAIAccount == nil {
            self.openAIAccount = UserAPIAccounts(id: userId)
        }
        if let tokens = self.openAIAccount?.tokens {
            self.userTokenMetadataList = tokens.filter({ token in
                return token.apiId == .openAI
            })
        }
#if DEBUG
        if let keychainStore = self.keychainService[APIName.openAI.rawValue] {
            let tokenHint: String = keychainStore.prefix(8) + "..."
            let keyChainToken = APIAccessToken(id: APIName.openAI.rawValue, tokenHint: tokenHint, expiry: nil, label: "(DEBUG) Apple Keychain", apiId: .openAI)
            self.userTokenMetadataList.insert(keyChainToken, at: 0)
        }
#endif
    }


    @discardableResult private func addNewAccessToken(note: String, actualToken: String, expiryIndex: Int) -> APIAccessToken? {
        guard var openAIUser = self.openAIAccount else { return nil }
        if note.isEmpty || actualToken.isEmpty { return nil }
        let tokenHint: String = actualToken.prefix(5) + "..." + actualToken.suffix(3)
        let tokenMetadata = APIAccessToken(id: UUID().uuidString, tokenHint: tokenHint, expiry: nil, label: note, apiId: .openAI)
        saveAccessToken(id: tokenMetadata.id, actualToken: actualToken)
        self.userTokenMetadataList.append(tokenMetadata)
        openAIUser.tokens = self.userTokenMetadataList
        UserDefaults.standard.saveUserTokens(userId: userId, user: openAIUser)
        UserDefaults.standard.hasAgiKey = true
        return tokenMetadata
    }

    private func saveAccessToken(id: String, actualToken: String) {
        self.keychainService[id] = actualToken
    }
    
    func isActiveAccessToken(id: String) -> Bool {
        let currentActiveToken = self.keychainService[APIName.openAI.rawValue]
        let queryToken = self.keychainService[id]
        return currentActiveToken == queryToken
    }
    
    func makeActiveAccessToken(id: String) {
        let queryToken = self.keychainService[id]
        self.keychainService[APIName.openAI.rawValue] = queryToken
        self.agiService.resetAccessToken(apiKey: queryToken)
        self.objectWillChange.send()
    }
    
    func delete(at offsets: IndexSet) {
        guard var openAIAccount = self.openAIAccount else { return }
        self.userTokenMetadataList.remove(atOffsets: offsets)
        openAIAccount.tokens = self.userTokenMetadataList
        UserDefaults.standard.saveUserTokens(userId: userId, user: openAIAccount)
        if self.userTokenMetadataList.isEmpty {
            UserDefaults.standard.hasAgiKey = false
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
        
        if token.count < 30 || token.count > 70 {
            errorMessage = "Token has an invalid length"
            return false
        }
        return true
    }
}

#if DEBUG

extension OpenAISettingsViewModel {
    static func mock() -> OpenAISettingsViewModel {
        let obj = OpenAISettingsViewModel()
        let token = APIAccessToken.mock()
        obj.userTokenMetadataList = [token]
        obj.openAIAccount = UserAPIAccounts(id: "1", tokens: [token])
        return obj
    }
}

#endif
