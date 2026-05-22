//
//  OpenCVApp.swift
//  OpenCV
//
//  Created by Paul Leo on 28/06/2024.
//

import SwiftUI
import SwiftData
import FirebaseCore

/// Application delegate responsible for early SDK bootstrap (Supabase client) before SwiftUI attaches.
class AppDelegate: NSObject, UIApplicationDelegate {
    
    /// Ensures the FactoryKit Supabase client initializes once at launch so later views share a single client.
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }

}

@main
struct OpenCVApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Person.self, ChatMessage.self
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
            ContainerView()
        }
        .modelContainer(sharedModelContainer)
    }
}

struct ContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("darkLightAutoMode") var darkLightAutoMode: UIUserInterfaceStyle = .unspecified
    
    var body: some View {
        ResumeListView(modelContext: modelContext)
            .preferredColorScheme(ColorScheme(darkLightAutoMode)) // tint on status bar
    }
}
