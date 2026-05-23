//
//  AIChatMessagesView.swift
//  TDCodeReview
//
//  Created by Paul Leo on 18/09/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import SwiftUI
import SwiftData

struct AIChatMessagesView: View {
    @State private var viewModel: AIChatMessagesViewModel
    
    init(modelContext: ModelContext, resumeUrl: String, resume: Resume) {
        _viewModel = State(initialValue: AIChatMessagesViewModel(modelContext: modelContext, resumeUrl: resumeUrl, resume: resume))
    }
    
    var body: some View {
#if DEBUG
let _ = Self._printChanges()
#endif
        ZStack {
            MeshGradientView()
                .opacity(0.3)
                .ignoresSafeArea()
            VStack {
                switch viewModel.state {
                case .loading, .appeared:
                    loadingView
                        .task {
                            self.viewModel.fetchData()
                        }
                case .loaded(_):
                    MessageScrollView(viewModel: viewModel)
                case .empty(_):
                    MessageScrollView(viewModel: viewModel)
                case .error(let message):
                    error(message: message)
                }
            }
        }
        .navigationTitle("AI Chat")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showingSettingsSheet) {
            SettingsView()
        }
        .onDisappear {
            viewModel.save()
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu {
                    Button(action: {
                        self.viewModel.deleteAllMessages()
                    }) {
                        Label("Clear All", systemImage: "trash")
                    }
                    Button(action: {
                        self.viewModel.showingSettingsSheet = true
                    }) {
                        Label("Settings", systemImage: "gearshape")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .padding()
                        .frame(width: 30, height: 30)
                }
                .contentShape(Rectangle())
                .menuOrder(.fixed)
            }
        }
    }

    @ViewBuilder
    var loadingView: some View {
        ProgressView()
            .frame(width: 40, height: 40, alignment: .center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .transition(.scale)
    }

    @ViewBuilder
    private func error(message: String) -> some View {
        Label(message, systemImage: "exclamationmark.octagon")
    }
}

#if DEBUG

#Preview {
    AIChatMessagesView(modelContext: PreviewController.previewContainer.mainContext, resumeUrl: "", resume: Resume.mock())
        .modelContainer(PreviewController.previewContainer)
}

#endif
