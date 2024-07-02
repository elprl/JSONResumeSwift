//
//  ResumeRowView.swift
//  OpenCV
//
//  Created by Paul Leo on 02/07/2024.
//

import SwiftUI
import SwiftData

struct ResumeRowView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: ResumeListViewModel
    let person: Person
    
    var body: some View {
        NavigationLink {
            if let resume = viewModel.resumes.first(where: { $0.basics.name == person.name }) {
                ResumeView(resume: resume)
            } else if let jsonString = person.cachedJSON {
                CachedResumeView(jsonString: jsonString)
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
                                .foregroundStyle(.primary)
                        }
                    }
                    Spacer()
                    Button {
                        Task { @MainActor in
                            deleteItem(person)
                        }
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(colorScheme == .dark ? .orange : .brown)
                    }
                }
            }
            .backgroundStyle(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(4)
            .shadow(radius: 4)
            .tint(.primary)
        }
    }
    
    func deleteItem(_ resume: Person) {
        withAnimation {
//            Task { @MainActor in
                viewModel.deleteItem(resume)
//            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Person.self, configurations: config)
    // Create a mock ViewModel
    let viewModel = ResumeListViewModel(modelContext: container.mainContext)
    ResumeRowView(viewModel: viewModel, person: Person(resumeUrl: ""))
}
