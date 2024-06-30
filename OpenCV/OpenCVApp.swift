//
//  OpenCVApp.swift
//  OpenCV
//
//  Created by Paul Leo on 28/06/2024.
//

import SwiftUI
import SwiftData

@main
struct OpenCVApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            AsyncTestView()
        }
        .modelContainer(sharedModelContainer)
    }
}
