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
                        WebImage(url: URL(string: imageUrl)) { image in
                            image.resizable()
                        } placeholder: {
                            placeholderImage
                        }
                        .indicator(.activity) // Activity Indicator
                        .transition(.fade(duration: 0.6)) // Fade Transition with duration
                        .scaledToFit()
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
                        Button {
                            viewModel.showingQRCodeSheet = true
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
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(colorScheme == .dark ? .orange : .brown)
                    }
                    .menuOrder(.fixed)
                    .highPriorityGesture(TapGesture())
                    
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
}

@available(iOS 18.0, *)
#Preview {
    @Previewable @Namespace() var namespace
    let viewModel = ResumeListViewModel(modelContext: PreviewController.previewContainer.mainContext)
    ResumeRowView(viewModel: viewModel, person: Person(resumeUrl: "https://registry.jsonresume.org/elprl.json"), namespace: namespace)
        .modelContainer(PreviewController.previewContainer)
}
