//
//  EmployeeListViewModel.swift
//  OpenCV
//
//  Created by Paul Leo on 30/06/2024.
//
import Foundation
import Combine
import SwiftData

@MainActor
final class ResumeListViewModel: ObservableObject {
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
//    @Published var people: [Person] = []
    @Published var resumes: Set<Resume> = Set<Resume>()
    @Published var showingSheet = false
    @Published var showingScanSheet = false
    @Published var showingQRCodeSheet = false
    @Published var showingDeleteAlert = false
    @Published var showingSettingsSheet = false
    @Published var url = "https://gist.githubusercontent.com/elprl/725d3337a3baedcfd95306e296587e8a/raw/32a1e309f1ab8fc0ab19c7695ad941cdd3c93a9d/resume.json"
    @Published var state: LoadingViewState<Resume> = .appeared
    @Published var scannedCode: String = ""
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
    func deleteItem(_ item: Person) {
        modelContext.delete(item)
        save()
        deleteNotes(for: item)
    }
    
    private func deleteNotes(for person: Person) {
        UserDefaults.standard.removeObject(forKey: person.resumeUrl)
    }
    
    private func save() {
        do {
            try modelContext.save() // Ensure changes are saved to the context
        } catch {
            // Handle error appropriately
            print("Failed to save context: \(error)")
        }
    }
    
    var isValidUrl: Bool {
        // Check if the URL starts with "https" and ends with ".json"
        if url.hasPrefix("https://") && url.hasSuffix(".json") {
            // Check if the URL is a valid URL
            if let url = URL(string: url), url.scheme == "https" {
                return true
            }
        }
        return false
    }
    
    func generateAppClipLink(resumeUrl: String) -> String {
        return "https://appclip.apple.com/id?p=\(Bundle.main.bundleIdentifier ?? "com.tapdigital.OpenCV")&url=\(resumeUrl.toBase64())"
    }
}

extension String {
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
