//
//  ResumeRowView.swift
//  OpenCV
//
//  Created by Paul Leo on 02/07/2024.
//

import SwiftUI
import SwiftData
import SDWebImageSwiftUI

struct ResumeRowView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: ResumeListViewModel
    let person: Person
    let namespace: Namespace.ID
    
    var body: some View {
        NavigationLink {
            if #available(iOS 18.0, *) {
                navDestination
                    .navigationTransition(.zoom(sourceID: person.id, in: namespace))
            } else {
                navDestination
            }
        } label: {
            GroupBox {
                HStack(spacing: 14) {
                    if let imageUrl = person.image {
                        WebImage(url: URL(string: imageUrl)) { image in
                            image.resizable()
                        } placeholder: {
                            Rectangle().foregroundColor(.gray)
                        }
                        .indicator(.activity) // Activity Indicator
                        .transition(.fade(duration: 0.5)) // Fade Transition with duration
                        .scaledToFit()
                        .frame(width: 54, height: 54)
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
                            if let profession = person.profession {
                                Text(profession)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Text("Added: \(person.createdAt.formatted(.relative(presentation: .named, unitsStyle: .wide)))")
                                .font(.caption)
                                .lineLimit(1)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Text("Loading resume...")
                                .foregroundStyle(.primary)
                        }
                    }
                    Spacer()
                    Menu {
                        Button {
                            viewModel.showingQRCodeSheet = true
                        } label: {
                            Label("Share Resume", systemImage: "square.and.arrow.up")
                                .foregroundStyle(colorScheme == .dark ? .orange : .brown)
                        }
                        Button {
                            viewModel.showingDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                                .foregroundStyle(colorScheme == .dark ? .orange : .brown)
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(colorScheme == .dark ? .orange : .brown)
                    }
                    .menuOrder(.fixed)
                    .highPriorityGesture(TapGesture())
                    
                }
                .alert("Are you sure?", isPresented: $viewModel.showingDeleteAlert) {
                    Button("Delete", role: .destructive, action: {
                        Task { @MainActor in
                            viewModel.deleteItem(person)
                        }
                    })
                    Button("Cancel", role: .cancel, action: {})
                } message: {
                    Text("Delete \(person.name ?? "this person") (including your notes) permanently.")
                }
            }
            .backgroundStyle(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(4)
            .shadow(radius: 4)
            .tint(.primary)
        }
    }
    
    @ViewBuilder
    private var navDestination: some View {
        Group {
            if let resume = viewModel.resumes.first(where: { $0.basics.name == person.name }) {
                ResumeView(resume: resume, resumeUrl: person.resumeUrl, modelContext: modelContext)
            } else if let jsonString = person.cachedJSON {
                CachedResumeView(jsonString: jsonString, resumeUrl: person.resumeUrl)
            } else {
                Text("Resume not yet loaded")
            }
        }
    }
}

@available(iOS 18.0, *)
#Preview {
    @Previewable @Namespace() var namespace
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Person.self, configurations: config)
    // Create a mock ViewModel
    let viewModel = ResumeListViewModel(modelContext: container.mainContext)
    ResumeRowView(viewModel: viewModel, person: Person(resumeUrl: ""), namespace: namespace)
}
