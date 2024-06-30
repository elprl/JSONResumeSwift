//
//  ResumeListView.swift
//  OpenCV
//
//  Created by Paul Leo on 30/06/2024.
//

import SwiftUI
import SwiftData

struct ResumeListView: View {
//    @StateObject private var model: EmployeeListViewModel = EmployeeListViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query private var people: [Person]
    @State private var resumes: Set<Resume> = Set<Resume>()
    @State private var showingAlert = false
    @State private var url = ""

    var body: some View {
        NavigationStack {
            ZStack {
                MeshGradientView()
                    .ignoresSafeArea()
                ScrollView {
                    LazyVStack {
                        ForEach(people) { person in
                            row(for: person)
                        }
                    }
                }
                .overlay {
                    if people.isEmpty {
                        ContentUnavailableView(
                            "No resumes found",
                            systemImage: "person.badge.plus",
                            description: Text("Tap + to add a new resume")
                        )
                    }
                }
                .navigationTitle("Resumes")
                .navigationBarTitleDisplayMode(.inline)
                .padding()
                .toolbar {
                    ToolbarItem {
                        Button(action: {
                            self.showingAlert = true
                        }) {
                            Label("Add Item", systemImage: "person.badge.plus")
                        }
                        .alert("Enter your name", isPresented: $showingAlert) {
                            TextField("Enter url to JSON resume", text: $url)
                            Button("OK", action: addItem)
                            Button("Cancel", role: .cancel, action: {})
                        } message: {
                            Text("Xcode will print whatever you type.")
                        }
                    }
                }
            }
        }
        .accentColor(.black.opacity(0.7))
    }
    
    @ViewBuilder
    private func row(for person: Person) -> some View {
        NavigationLink {
            if let resume = resumes.first(where: { $0.basics.name == person.name }) {
                ResumeView(resume: resume)
            } else if let jsonString = person.cachedJSON {
                Text("Resume not yet loaded")
            } else {
                Text("Resume not yet loaded")
            }
        } label: {
            GroupBox {
                HStack {
                    if let imageUrl = person.image {
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                    } else {
                        ProgressView()
                    }
                    VStack {
                        if let name = person.name {
                            Text(name)
                                .font(.headline)
                                .lineLimit(1)
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Created: \(person.createdAt.formatted(.relative(presentation: .named, unitsStyle: .wide)))")
                                .font(.caption)
                                .lineLimit(1)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Text("Loading resume...")
                        }
                    }
                    Spacer()
                    Button {
                        delete(resume: person)
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                }
            }
            .tint(.black.opacity(0.7))
            .backgroundStyle(.ultraThinMaterial)
            .shadow(radius: 4)
        }
    }
    
    private func addItem() {
        // https://gist.githubusercontent.com/elprl/725d3337a3baedcfd95306e296587e8a/raw/f01133eaf6566b807c78938f880246df6bdf4f91/resume.json
        withAnimation {
            let newPerson = Person(resumeUrl: url)
            modelContext.insert(newPerson)
            
            Task { @MainActor in
                if let (resume, jsonString) = await ResumeLoader().loadResume(urlString: newPerson.resumeUrl) {
                    if let index = people.firstIndex(of: newPerson) {
                        people[index].name = resume.basics.name
                        people[index].image = resume.basics.image
                        people[index].cachedJSON = jsonString
                        resumes.insert(resume)
                        
                        do {
                            try modelContext.save() // Ensure changes are saved to the context
                        } catch {
                            // Handle error appropriately
                            print("Failed to save context: \(error)")
                        }
                    }
                }
            }
        }
    }

    private func delete(resume: Person) {
        withAnimation {
            modelContext.delete(resume)
        }
    }
}

#Preview {
    ResumeListView()
        .modelContainer(for: Person.self, inMemory: true)
}
