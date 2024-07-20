//
//  GithubAccount.swift
//  TDCodeReview
//
//  Created by Paul Leo on 08/04/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import Foundation

/// Against a single app account (id), they can have multiple API keys for multiple API (Github, Bard, OpenAI) accounts
struct UserAPIAccounts: Identifiable, Codable {
    /// User id
    let id: String
    /// Store of Access Token metadata (not the actual tokens which is stored in the keychain)
    var tokens: [APIAccessToken] = []
}

extension UserAPIAccounts: Hashable {
    static func == (lhs: UserAPIAccounts, rhs: UserAPIAccounts) -> Bool {
        return lhs.id == rhs.id
    }
}
