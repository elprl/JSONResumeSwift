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
                                .transition(.move(edge: .leading))
                        }
                    }
                    .animation(.easeInOut, value: people)
                }
                .overlay {
                    if people.isEmpty {
                        ContentUnavailableView(
                            "No resumes found",
                            systemImage: "person.badge.plus",
                            description: Text("Tap to add a new resume")
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.viewModel.state = .appeared
                            self.viewModel.showingSheet = true
                        }
                    }
                }
                .navigationTitle("CVs")
                .navigationBarTitleDisplayMode(.inline)
                .padding()
                .toolbar {
                    ToolbarItem {
                        Button(action: {
                            self.viewModel.state = .appeared
                            self.viewModel.showingSheet = true
                        }) {
                            Label("Add Item", systemImage: "person.badge.plus")
                        }
                        .sheet(isPresented: $viewModel.showingSheet) { InputFormView(viewModel: viewModel)
                        }
                    }
                }
            }
        }
        .tint(colorScheme == .dark ? .orange : .brown)
//        .environment(\.modelContext, viewModel.modelContext)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Person.self, configurations: config)
    ResumeListView(modelContext: container.mainContext)
}
