//
//  EmployeeListViewModel.swift
//  OpenCV
//
//  Created by Paul Leo on 30/06/2024.
//
import Foundation
import Combine
import SwiftData
import CodeScanner
import OSLog

@MainActor
final class ResumeListViewModel: ObservableObject {
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
//    @Published var people: [Person] = []
    @Published var resumes: Set<Resume> = Set<Resume>()
    @Published var showingInputSheet = false
    @Published var showingScanSheet = false
    @Published var showingQRCodeSheet = false
    @Published var showingDeleteAlert = false
    @Published var showingSettingsSheet = false
#if DEBUG
    @Published var url = "https://registry.jsonresume.org/elprl.json"
#else
    @Published var url = ""
#endif
    @Published var state: LoadingViewState<Resume> = .appeared
    @Published var scannedCode: String = ""
    @Published var selectedPerson: Person?
    @Published var searchString: String = ""
    @Published var isImporting: Bool = false
}

extension ResumeListViewModel {
    
    func addItem(urlString: String) async throws {
        state = .loading
        Task { @MainActor in
            do {
                if let (resume, jsonString) = try await ResumeLoaderService().loadResume(urlString: urlString) {
                    resumes.insert(resume)

                    let newPerson = Person(resumeUrl: urlString)
                    newPerson.name = resume.basics.name
                    newPerson.image = resume.basics.image
                    newPerson.profession = resume.basics.label
                    newPerson.cachedJSON = jsonString
                    modelContext.insert(newPerson)
                    save()
                    state = .loaded(resume)
                } else {
                    state = .error("Cannot read resume. Check JSON has valid schema.")
                }
            } catch {
                state = .error("Cannot read resume. Check JSON has valid schema.\n\(error.localizedDescription)")
            }
        }
    }
    
    // Delete
    func deleteItem(_ item: Person?) {
        if let item {
            modelContext.delete(item)
            save()
            deleteNotes(for: item)
        }
    }
    
    private func deleteNotes(for person: Person) {
        UserDefaults.standard.removeObject(forKey: person.resumeUrl)
    }
    
    private func save() {
        do {
            try modelContext.save() // Ensure changes are saved to the context
        } catch {
            // Handle error appropriately
            Log.pres.error("Failed to save context: \(error)")
        }
    }
    
    var isValidUrl: Bool {
        // Check if the URL is valid
        if isValidURL(url: url) {
            // Check if the URL is a valid URL
            if let _ = URL(string: url) {
                return true
            }
        }
        return false
    }
    
    private func isValidURL(url: String) -> Bool {
        let urlPattern = #"^(https?|ftp)://[^\s/$.?#].[^\s]*$"#
        let urlTest = NSPredicate(format: "SELF MATCHES %@", urlPattern)
        return urlTest.evaluate(with: url)
    }
    
    func generateAppClipLink(resumeUrl: String) -> String {
        return "https://appclip.apple.com/id?p=com.tapdigital.OpenCV.Clip&url=\(resumeUrl.toBase64)"
    }
    
    @MainActor
    func handleUserActivity(_ userActivity: NSUserActivity) {
        isImporting = true
        guard
            let incomingURL = userActivity.webpageURL,
            let components = URLComponents(
                url: incomingURL,
                resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems
        else {
            isImporting = false
            return
        }
        
        guard let url = queryItems.first(where: { $0.name == "url" })?.value?.fromBase64 else {
            isImporting = false
            return
        }
        Log.pres.debug("App Clip URL: \(url)")
        self.url = url
        Task { @MainActor in
            do {
                try await addItem(urlString: url)
            } catch {
                Log.pres.error("Error adding item: \(error.localizedDescription)")
            }
            isImporting = false
        }        
    }
    
    @MainActor
    func handleQRScan(response: Result<ScanResult, ScanError>) {
        if case let .success(result) = response {
            if result.string.hasPrefix("https://registry.jsonresume.org/") && !result.string.hasSuffix(".json") {
                url = result.string + ".json"
            } else {
                url = result.string
            }
            showingScanSheet = false
        }
    }
}
