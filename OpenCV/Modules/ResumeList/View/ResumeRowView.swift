//
//  ResumeRowView.swift
//  OpenCV
//
//  Created by Paul Leo on 02/07/2024.
//

import SwiftUI
import SwiftData
import NukeUI

struct ResumeRowView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: ResumeListViewModel
    @State var person: Person
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
                        LazyImage(url: URL(string: imageUrl)) { state in
                            if let image = state.image {
                                image.resizable().aspectRatio(contentMode: .fit)
                            } else if state.error != nil {
                                Image(systemName: "exclamationmark.triangle.fill") // Indicates an error
                            } else {
                                placeholderImage // Acts as a placeholder
                            }
                        }
                        .transition(.opacity)
                        .animation(.easeInOut, value: person.image)
                        .frame(width: 54, height: 54)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                    } else {
                        placeholderImage
                            .frame(width: 54, height: 54)
                            .shadow(radius: 4)
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
                            Text("Loading CV...")
                                .foregroundStyle(.primary)
                        }
                    }
                    Spacer()
                    Menu {
                        optionsMenuItems
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(colorScheme == .dark ? .orange : .brown)
                    }
                    .menuOrder(.fixed)
                    .highPriorityGesture(TapGesture())
                }
            }
            .groupBoxStyle(GlassifyGroupBoxStyle(lightStartPoint: .bottomLeading, lightEndPoint: .topTrailing, lightColor: .yellow))
            .padding(4)
            .tint(.primary)
            .contextMenu(menuItems: {
                optionsMenuItems
            })
            .buttonStyle(.plain)
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
                Text("CV not yet loaded")
            }
        }
    }
    
    @ViewBuilder
    private var placeholderImage: some View {
        Image(systemName: "person.circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
    
    @ViewBuilder
    var optionsMenuItems: some View {
        Group {
            Button {
                viewModel.showingQRCodeSheet = true
                viewModel.selectedPerson = person
                viewModel.url = person.resumeUrl
            } label: {
                Label("Share CV", systemImage: "square.and.arrow.up")
                    .foregroundStyle(colorScheme == .dark ? .orange : .brown)
            }
            Button {
                viewModel.showingDeleteAlert = true
                viewModel.selectedPerson = person
            } label: {
                Label("Delete", systemImage: "trash")
                    .foregroundStyle(colorScheme == .dark ? .orange : .brown)
            }
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .samplePeopleData) {
    @Previewable @Namespace() var namespace
    @Previewable @Query var people: [Person]
    let viewModel = ResumeListViewModel(modelContext: PreviewController.previewContainer.mainContext)
    ResumeRowView(viewModel: viewModel, person: people.first ?? Person(resumeUrl: "https://registry.jsonresume.org/elprl.json"), namespace: namespace)
        .modelContainer(PreviewController.previewContainer)
}
