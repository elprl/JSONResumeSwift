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
    var name: String?
    var createdAt: Date
    var resumeUrl: String
    var image: String?
    var cachedJSON: String?
    
    init(resumeUrl: String) {
        self.createdAt = Date()
        self.resumeUrl = resumeUrl
    }
}
