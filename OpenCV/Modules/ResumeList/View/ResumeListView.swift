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
    @Query(sort: \Person.createdAt, order: .reverse) private var people: [Person]
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
                        ForEach(filteredPeople, id: \.self) { person in
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
                    CodeScannerView(codeTypes: [.qr], showViewfinder: true) { response in
                        viewModel.handleQRScan(response: response)
                    }
                }
                .sheet(isPresented: $viewModel.showingInputSheet) {
                    if #available(iOS 18.0, *) {
                        InputFormView(viewModel: viewModel)
                            .presentationSizing(.form)
                    } else {
                        InputFormView(viewModel: viewModel)
                    }
                }
                .overlay {
                    empty
                }
                .navigationTitle("CVs")
                .navigationBarTitleDisplayMode(.automatic)
                .padding()
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button(action: {
                            self.viewModel.state = .appeared
                            self.viewModel.showingInputSheet = true
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
                .alert("Are you sure?", isPresented: $viewModel.showingDeleteAlert) {
                    Button("Delete", role: .destructive, action: {
                        Task { @MainActor in
                            viewModel.deleteItem(viewModel.selectedPerson)
                        }
                    })
                    Button("Cancel", role: .cancel, action: {})
                } message: {
                    Text("Delete \(viewModel.selectedPerson?.name ?? "this person") (including your notes) permanently.")
                }
            }
        }
        .tint(colorScheme == .dark ? .orange : .brown)
        .searchable(text: $viewModel.searchString)
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: viewModel.handleUserActivity)
    }
    
    @ViewBuilder
    private var empty: some View {
        if people.isEmpty {
            ContentUnavailableView(
                "No CVs found",
                systemImage: "person.badge.plus",
                description: Text("Tap to add a new CV")
            )
            .contentShape(Rectangle())
            .onTapGesture {
                self.viewModel.state = .appeared
                self.viewModel.showingInputSheet = true
            }
        }
    }
    
    private var filteredPeople: [Person] {
        if viewModel.searchString.isEmpty {
            return people
        }
        return people.filter { person in
            (person.name?.localizedCaseInsensitiveContains(viewModel.searchString) ?? false) || (person.cachedJSON?.localizedCaseInsensitiveContains(viewModel.searchString) ?? false)
        }
    }
}

#Preview {
    ResumeListView(modelContext: PreviewController.previewContainer.mainContext)
        .modelContainer(PreviewController.previewContainer)
}
