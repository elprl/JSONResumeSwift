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
    @Attribute(.unique) var resumeUrl: String
    var createdAt: Date
    var name: String?
    var profession: String?
    var notes: String?
    var image: String?
    var cachedJSON: String?
    
    init(resumeUrl: String) {
        self.createdAt = Date()
        self.resumeUrl = resumeUrl
    }
}

extension Person: Identifiable, Hashable {
    var id: String {
        return resumeUrl
    }
    
    var hashValue: Int {
        return resumeUrl.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(resumeUrl)
    }
}
