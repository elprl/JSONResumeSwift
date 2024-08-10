//
//  ResumeView.swift
//  OpenCV
//
//  Created by Paul Leo on 29/06/2024.
//

import SwiftUI
import SwiftData

struct ResumeView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel: ResumeViewModel
    private let modelContext: ModelContext
    @AppStorage(UserDefaults.Keys.hasAgiKey) var hasAgiKey: Bool = false
    @AppStorage(UserDefaults.Keys.hasClaudeKey) var hasClaudeKey: Bool = false
    @AppStorage(UserDefaults.Keys.hasGeminiKey) var hasGeminiKey: Bool = false

    init(resume: Resume, resumeUrl: String, modelContext: ModelContext) {
        self.modelContext = modelContext
        _viewModel = StateObject(wrappedValue: ResumeViewModel(resumeUrl: resumeUrl, resume: resume))
    }
    
    var body: some View {
        ZStack {
            MeshGradientView()
                .opacity(0.3)
               .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                basics
                stats
                work
                volunteer
                education
                awards
                certificates
                publications
                skills
                languages
                interests
                references
                projects
            }
            .padding(.horizontal)
        }
        .navigationTitle(viewModel.resume.basics.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $viewModel.showAIChat, destination: {
            AIChatMessagesView(modelContext: modelContext, resumeUrl: viewModel.resumeUrl, resume: viewModel.resume)
                .modelContainer(modelContext.container)
        })
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: {
                    self.viewModel.showAIChat = true
                }) {
                    Label("AI Chat & Notes", systemImage: "message")
                }
            }
        }
    }
    
    @ViewBuilder
    private var basics: some View {
        BasicsView(basics: viewModel.resume.basics)
    }
    
    @ViewBuilder
    private var stats: some View {
        StatsView(viewModel: viewModel)
            .padding(.top)
    }
    
    @ViewBuilder
    private var work: some View {
        if let works = viewModel.resume.work {
            WorkView(works: works)
                .padding(.top)
        }
    }
    
    @ViewBuilder
    private var volunteer: some View {
        if let vols = viewModel.resume.volunteer {
            VolunteerView(vols: vols)
                .padding(.top)
        }
    }
    
    @ViewBuilder
    private var education: some View {
        if let edus = viewModel.resume.education {
            EducationView(educations: edus)
                .padding(.top)
        }
    }
    
    @ViewBuilder
    private var awards: some View {
        if let awards = viewModel.resume.awards {
            AwardsView(awards: awards)
                .padding(.top)
        }
    }
    
    @ViewBuilder
    private var certificates: some View {
        if let certificates = viewModel.resume.certificates {
            CertificatesView(certificates: certificates)
                .padding(.top)
       }
    }
    
    @ViewBuilder
    private var publications: some View {
        if let publications = viewModel.resume.publications {
            PublicationsView(publications: publications)
                .padding(.top)
       }
    }
    
    @ViewBuilder
    private var skills: some View {
        if let skills = viewModel.resume.skills {
            SkillsView(skills: skills)
                .padding(.top)
        }
    }
    
    @ViewBuilder
    private var languages: some View {
        if let languages = viewModel.resume.languages {
            LanguagesView(languages: languages)
                .padding(.top)
       }
    }
    
    @ViewBuilder
    private var interests: some View {
        if let interests = viewModel.resume.interests {
            InterestsView(interests: interests)
                .padding(.top)
       }
    }
    
    @ViewBuilder
    private var references: some View {
        if let references = viewModel.resume.references {
            ReferencesView(references: references)
                .padding(.top)
        }
    }
    
    @ViewBuilder
    private var projects: some View {
        if let projects = viewModel.resume.projects {
            ProjectsView(projects: projects)
                .padding(.top)
       }
    }
}

struct AsyncTestView: View {
    @State var resume: Resume?

    var body: some View {
        VStack {
            if let resume {
                let config = ModelConfiguration(isStoredInMemoryOnly: true)
                let container = try! ModelContainer(for: Person.self, configurations: config)

                ResumeView(resume: resume, resumeUrl: "", modelContext: container.mainContext)
            }
        }
        .task {
            resume = await ResumeLoaderService().loadSample()
        }
    }
}

#Preview {
    AsyncTestView()
}
