//
//  Person.swift
//  OpenCV
//
//  Created by Paul Leo on 30/06/2024.
//

import Foundation
import SwiftData

@Model
final class Person {
    var name: String
    var createdAt: Date
    var resumeUrl: String
    
    init(name: String, createdAt: Date = Date(), resumeUrl: String) {
        self.name = name
        self.createdAt = createdAt
        self.resumeUrl = resumeUrl
    }
}
