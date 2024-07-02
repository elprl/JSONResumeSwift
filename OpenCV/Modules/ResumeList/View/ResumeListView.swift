//
//  ResumeListView.swift
//  OpenCV
//
//  Created by Paul Leo on 30/06/2024.
//

import SwiftUI
import SwiftData

struct ResumeListView: View {
    @Query private var people: [Person]
    @StateObject private var viewModel: ResumeListViewModel
    @Environment(\.colorScheme) private var colorScheme

    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: ResumeListViewModel(modelContext: modelContext))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MeshGradientView()
                    .opacity(0.3)
                    .ignoresSafeArea()
                ScrollView {
                    LazyVStack {
                        ForEach(people) { person in
                            ResumeRowView(viewModel: viewModel, person: person)
                                .transition(.opacity)
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
                            self.viewModel.showingAlert = true
                        }) {
                            Label("Add Item", systemImage: "person.badge.plus")
                        }
                        .tint(colorScheme == .dark ? .orange : .brown)
                        .alert("Enter your name", isPresented: $viewModel.showingAlert) {
                            TextField("Enter url to JSON resume", text: $viewModel.url)
                            Button("OK", action: addItem)
                            Button("Cancel", role: .cancel, action: {})
                        } message: {
                            Text("Xcode will print whatever you type.")
                        }
                    }
                }
            }
        }
        .environment(\.modelContext, viewModel.modelContext)
    }
    
    func addItem() {
        Task { @MainActor in
            do {
                try await viewModel.addItem()
            } catch {
                print("error")
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Person.self, configurations: config)
    ResumeListView(modelContext: container.mainContext)
}
