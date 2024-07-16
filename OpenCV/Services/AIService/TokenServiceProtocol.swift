//
//  TokenServiceProtocol.swift
//  TDCodeReview
//
//  Created by Paul Leo on 17/01/2024.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.
//

import Foundation

protocol TokenServiceProtocol {
    func resetAccessToken(apiKey: String?)
    var hasSetToken: Bool { get }
}
