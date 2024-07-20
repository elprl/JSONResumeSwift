//
//  GithubAccessToken.swift
//  TDCodeReview
//
//  Created by Paul Leo on 15/01/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import Foundation

enum APIName: String, Codable {
    case github
    case openAI
    case gemini
    case meta
    case claude
    case customAi
}

/// A token pointer used to retrieve the actual token stored in the User's keychain
struct APIAccessToken: Codable, Identifiable {
    /// User id
    let id: String
    /// Toekn hint for UI purposes to show it exists (not actual token)
    let tokenHint: String
    /// expiry date of token access
    let expiry: Date?
    /// A label that describes what this token is for, or to help id it
    let label: String
    /// The org this key is for, e.g. github
    let apiId: APIName
}

extension APIAccessToken: Hashable {
    static func == (lhs: APIAccessToken, rhs: APIAccessToken) -> Bool {
        return lhs.id == rhs.id
    }
}

#if DEBUG

extension APIAccessToken {
    static func mock() -> APIAccessToken {
        let obj = APIAccessToken(id: "1", tokenHint: "ghs_dfsgdfsg...", expiry: Date(), label: "MacBook Key", apiId: .github)
        return obj
    }
}

#endif
