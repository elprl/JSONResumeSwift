//
//  ResumeListView.swift
//  OpenCV
//
//  Created by Paul Leo on 30/06/2024.
//

import SwiftUI
import SwiftData
import CodeScanner

struct ResumeListView: View {
    @Query private var people: [Person]
    @StateObject private var viewModel: ResumeListViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Namespace() var namespace

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
                            Group {
                                if #available(iOS 18.0, *) {
                                    ResumeRowView(viewModel: viewModel, person: person, namespace: namespace)
                                        .transition(.move(edge: .leading))
                                        .matchedTransitionSource(id: person.id, in: namespace)
                                } else {
                                    ResumeRowView(viewModel: viewModel, person: person, namespace: namespace)
                                        .transition(.move(edge: .leading))
                                }
                            }
                            .sheet(isPresented: $viewModel.showingQRCodeSheet) {
                                QRCodeGenView(resumeUrl: person.resumeUrl)
                            }
                        }
                    }
                    .animation(.easeInOut, value: people)
                }
                .sheet(isPresented: $viewModel.showingScanSheet) {
                    CodeScannerView(codeTypes: [.qr]) { response in
                        if case let .success(result) = response {
                            viewModel.scannedCode = result.string
                            viewModel.showingScanSheet = false
                        }
                    }
                }
                .sheet(isPresented: $viewModel.showingSheet) {
                    if #available(iOS 18.0, *) {
                        InputFormView(viewModel: viewModel)
                            .presentationSizing(.form)
                    } else {
                        InputFormView(viewModel: viewModel)
                    }
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
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button(action: {
                            self.viewModel.state = .appeared
                            self.viewModel.showingSheet = true
                        }) {
                            Label("Add Item", systemImage: "person.badge.plus")
                        }
                    }
                    
                    ToolbarItemGroup(placement: .topBarLeading) {
                        Button(action: {
                            self.viewModel.showingSettingsSheet = true
                        }) {
                            Label("Settings", systemImage: "gearshape")
                        }
                        .sheet(isPresented: $viewModel.showingSettingsSheet) {
                            SettingsView()
                        }
                    }
                }
            }
        }
        .tint(colorScheme == .dark ? .orange : .brown)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Person.self, configurations: config)
    ResumeListView(modelContext: container.mainContext)
}
