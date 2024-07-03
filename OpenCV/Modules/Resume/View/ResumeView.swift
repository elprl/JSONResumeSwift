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
    private let resume: Resume
    private let modelContext: ModelContext
    private let resumeUrl: String
    
    init(resume: Resume, resumeUrl: String, modelContext: ModelContext) {
        self.resume = resume
        self.resumeUrl = resumeUrl
        self.modelContext = modelContext
        _viewModel = StateObject(wrappedValue: ResumeViewModel(resumeUrl: resumeUrl))
    }
    
    var body: some View {
        ZStack {
            MeshGradientView()
                .opacity(0.3)
               .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                basics
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
                
                Divider().padding()
                myNotes
            }
            .navigationTitle(resume.basics.name)
            .navigationBarTitleDisplayMode(.inline)
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private var myNotes: some View {
        MyNotesView(resumeUrl: resumeUrl)
    }
    
    @ViewBuilder
    private var basics: some View {
        BasicsView(basics: resume.basics)
    }
    
    @ViewBuilder
    private var work: some View {
        if let works = resume.work {
            WorkView(works: works)
                .padding(.top)
        }
    }
    
    @ViewBuilder
    private var volunteer: some View {
        if let vols = resume.volunteer {
            VolunteerView(vols: vols)
                .padding(.top)
        }
    }
    
    @ViewBuilder
    private var education: some View {
        if let edus = resume.education {
            EducationView(educations: edus)
                .padding(.top)
        }
    }
    
    @ViewBuilder
    private var awards: some View {
        if let awards = resume.awards {
            AwardsView(awards: awards)
                .padding(.top)
        }
    }
    
    @ViewBuilder
    private var certificates: some View {
        if let certificates = resume.certificates {
            CertificatesView(certificates: certificates)
                .padding(.top)
       }
    }
    
    @ViewBuilder
    private var publications: some View {
        if let publications = resume.publications {
            PublicationsView(publications: publications)
                .padding(.top)
       }
    }
    
    @ViewBuilder
    private var skills: some View {
        if let skills = resume.skills {
            SkillsView(skills: skills)
                .padding(.top)
        }
    }
    
    @ViewBuilder
    private var languages: some View {
        if let languages = resume.languages {
            LanguagesView(languages: languages)
                .padding(.top)
       }
    }
    
    @ViewBuilder
    private var interests: some View {
        if let interests = resume.interests {
            InterestsView(interests: interests)
                .padding(.top)
       }
    }
    
    @ViewBuilder
    private var references: some View {
        if let references = resume.references {
            ReferencesView(references: references)
                .padding(.top)
        }
    }
    
    @ViewBuilder
    private var projects: some View {
        if let projects = resume.projects {
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
