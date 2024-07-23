//
//  Person.swift
//  OpenCV
//
//  Created by Paul Leo on 30/06/2024.
//

import Foundation
import SwiftData
import SwiftUI

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

@MainActor
class PreviewController {
    static let previewContainer: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Person.self, configurations: config)
            
            for i in 1..<100 {
                let user = Person(resumeUrl: UUID().uuidString)
                user.name = UUID().uuidString
                container.mainContext.insert(user)
            }
            
            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }()
}

//struct SamplePersonData: PreviewModifier {
//    static func makeSharedContext() throws -> ModelContainer {
//        return PreviewController.previewContainer
//    }
//    
//    func body(content: Content, context: ModelContainer) -> some View {
//        content.modelContainer(context)
//    }
//}
//
//@available(iOS 18.0, *)
//extension PreviewTrait where T == Preview.ViewTraits {
//    @MainActor static var samplePeopleData: Self = .modifier(SamplePersonData())
//}
