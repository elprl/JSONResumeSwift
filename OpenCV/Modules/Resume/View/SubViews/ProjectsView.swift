//
//  ProjectsView.swift
//  OpenCV
//
//  Created by Paul Leo on 30/06/2024.
//

import SwiftUI

struct ProjectsView: View {
    let projects: [Project]
    
    var body: some View {
        GroupBox {
            DisclosureGroup {
                Rectangle().frame(width: 0, height: 0).padding(.top)

                ForEach(Array(projects.enumerated()), id: \.element) { index, element in
                    VStack(alignment: .leading, spacing: 4) {
                        GroupBox {
                            HStack {
                                Text(element.name)
                                    .font(.headline)
                                    .lineLimit(nil)
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if let url = element.url {
                                    Button {
                                        openLink(url: url)
                                    } label: {
                                        Image(systemName: "link")
                                    }
                                }
                            }
                            Text(element.description)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(element.dates)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if !(element.highlights?.isEmpty ?? true) {
                                DisclosureGroup {
                                    ForEach(element.highlights ?? [], id: \.self) { highlight in
                                        Text("• \(highlight)")
                                            .font(.body)
                                            .lineLimit(nil)
                                            .multilineTextAlignment(.leading)
                                            .lineSpacing(1.5)
                                            .foregroundStyle(.primary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                } label: {
                                    Text("Highlights")
                                        .font(.caption)
                                        .foregroundStyle(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .tint(.gray)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 40)
                    .padding(.vertical, 4)
                    .overlay {
                        HStack(spacing: 0) {
                            VStack(alignment: .center, spacing: 4) {
                                Rectangle()
                                    .frame(width: 1)
                                    .opacity(index == 0 ? 0 : 1)
                                Circle()
                                    .frame(width: 5, height: 5)
                                Rectangle()
                                    .frame(width: 1)
                                    .opacity(index == (projects.count - 1) ? 0 : 1)
                            }
                            .foregroundStyle(.orange)
                            Spacer()
                        }
                        .padding(.leading, 10)
                        .padding(.vertical, -4)
                    }
                }
            } label: {
                Label("Projects", systemImage: "wrench.and.screwdriver")
                    .modifier(Heading())
            }
            .tint(.orange)
        }
        .backgroundStyle(.ultraThinMaterial)
        .padding(.horizontal, 4)
        .shadow(radius: 4)
    }
}

#Preview {
    ProjectsView(projects: [
        Project(name: "Moon Landing", description: "Go tot he moon", highlights: ["spacewalk", "launch"], keywords: ["spacewalk", "launch"], startDate: Date(), endDate: Date(), url: "https://github.com/elprl/JSONResumeSwift.git", roles: [], entity: nil, type: nil),
        Project(name: "Moon Landing", description: "Go tot he moon", highlights: ["spacewalk", "launch"], keywords: ["spacewalk", "launch"], startDate: Date(), endDate: Date(), url: "https://github.com/elprl/JSONResumeSwift.git", roles: [], entity: nil, type: nil)
    ])
}
