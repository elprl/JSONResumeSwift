//
//  EmployeeListViewModel.swift
//  OpenCV
//
//  Created by Paul Leo on 30/06/2024.
//

import Combine
import SwiftData
import SwiftUI

@MainActor
final class ResumeListViewModel: ObservableObject {
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
//    @Published var people: [Person] = []
    @Published var resumes: Set<Resume> = Set<Resume>()
    @Published var showingAlert = false
    @Published var url = "https://gist.githubusercontent.com/elprl/725d3337a3baedcfd95306e296587e8a/raw/32a1e309f1ab8fc0ab19c7695ad941cdd3c93a9d/resume.json"
    @Published var errorMessage: String?
}

extension ResumeListViewModel {
    
    func addItem() async throws {        
        Task { @MainActor in            
            do {
                if let (resume, jsonString) = try await ResumeLoader().loadResume(urlString: url) {
                    resumes.insert(resume)

                    let newPerson = Person(resumeUrl: url)
                    newPerson.name = resume.basics.name
                    newPerson.image = resume.basics.image
                    newPerson.cachedJSON = jsonString
                    withAnimation {
                        modelContext.insert(newPerson)
                        save()
                    }
                }
            } catch {
                errorMessage = "Cannot parse JSON resume"
            }
        }
    }
    
    // Delete
    func deleteItem(_ item: Person) {
        modelContext.delete(item)
        save()
    }
    
    private func save() {
        do {
            try modelContext.save() // Ensure changes are saved to the context
        } catch {
            // Handle error appropriately
            print("Failed to save context: \(error)")
        }
    }
}
