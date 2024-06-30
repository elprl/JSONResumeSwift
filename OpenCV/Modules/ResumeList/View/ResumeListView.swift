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
    @Query private var resumes: [Person]
    
    var body: some View {
        NavigationStack {
            ZStack {
                MeshGradientView()
                    .ignoresSafeArea()
                ScrollView {
                    LazyVStack {
                        ForEach(resumes) { resume in
                            NavigationLink {
                                AsyncTestView()
                            } label: {
                                GroupBox {
                                    HStack {
                                        Image(systemName: "person.circle")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 50, height: 50)
                                        VStack {
                                            Text(resume.name)
                                                .font(.headline)
                                                .lineLimit(1)
                                                .foregroundStyle(.primary)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            Text("Created: \(resume.createdAt.formatted(.relative(presentation: .named, unitsStyle: .wide)))")
                                                .font(.caption)
                                                .lineLimit(1)
                                                .foregroundStyle(.secondary)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        Spacer()
                                        Button {
                                            delete(resume: resume)
                                        } label: {
                                            Image(systemName: "trash")
                                        }
                                    }
                                }
                                .tint(.black.opacity(0.7))
                                .backgroundStyle(.ultraThinMaterial)
                                .shadow(radius: 4)
                            }
                        }
                    }
                }
                .overlay {
                    if resumes.isEmpty {
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
                        Button(action: addItem) {
                            Label("Add Item", systemImage: "person.badge.plus")
                        }
                    }
                }
            }
        }
        .accentColor(.black.opacity(0.7))
    }
    
    private func addItem() {
        withAnimation {
            let newPerson = Person(name: "Paul Leo", createdAt: Date(), resumeUrl: "https://gist.githubusercontent.com/elprl/725d3337a3baedcfd95306e296587e8a/raw/f01133eaf6566b807c78938f880246df6bdf4f91/resume.json")
            modelContext.insert(newPerson)
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
