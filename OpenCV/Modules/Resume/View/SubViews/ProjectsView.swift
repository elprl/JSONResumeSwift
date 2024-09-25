//
//  ProjectsView.swift
//  OpenCV
//
//  Created by Paul Leo on 30/06/2024.
//

import SwiftUI

struct ProjectsView: View {
    @Environment(\.colorScheme) private var colorScheme
    let projects: [Project]
    
    var body: some View {
        GroupBox {
            DisclosureGroup {
                Rectangle().frame(width: 0, height: 0).padding(.top)

                ForEach(Array(projects.enumerated()), id: \.element) { index, element in
                    row(index: index, element: element)
                }
            } label: {
                HStack {
                    Label("Projects", systemImage: "wrench.and.screwdriver")
                        .modifier(Heading())
                    Spacer()
                    Text("\(projects.count)")
                }
            }
            .tint(colorScheme == .dark ? .orange : .brown)
        }
        .groupBoxStyle(GlassifyGroupBoxStyle(lightStartPoint: .bottomLeading, lightEndPoint: .topTrailing, lightColor: .yellow))
        .padding(.horizontal, 4)
    }
    
    private func row(index: Int, element: Project) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            GroupBox {
                HStack {
                    Text(element.name ?? "")
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
                Text(element.projectDescription ?? "")
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
                    .padding(.top, -8)
                }
            }
            .groupBoxStyle(GlassifyGroupBoxStyle(lightStartPoint: .bottomLeading, lightEndPoint: .topTrailing, lightColor: .yellow))
            .padding(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 28)
        .padding(.vertical, 4)
        .overlay {
            HStack(spacing: 0) {
                VStack(alignment: .center, spacing: 8) {
                    Rectangle()
                        .frame(width: 1)
                        .opacity(index == 0 ? 0 : 1)
                    Circle()
                        .frame(width: 6, height: 6)
                    Rectangle()
                        .frame(width: 1)
                        .opacity(index == (projects.count - 1) ? 0 : 1)
                }
                .foregroundStyle(colorScheme == .dark ? .orange : .brown)
                Spacer()
            }
            .padding(.leading, 4)
            .padding(.vertical, -4)
        }
    }
}

#Preview {
    ProjectsView(projects: [
        Project(name: "Moon Landing", projectDescription: "Go tot he moon", highlights: ["spacewalk", "launch"], keywords: ["spacewalk", "launch"], startDate: "2020-12-22", endDate: "2020-12-22", url: "https://github.com/elprl/JSONResumeSwift.git", roles: [], entity: nil, type: nil),
        Project(name: "Moon Landing", projectDescription: "Go tot he moon", highlights: ["spacewalk", "launch"], keywords: ["spacewalk", "launch"], startDate: "2020-12-22", endDate: "2020-12-22", url: "https://github.com/elprl/JSONResumeSwift.git", roles: [], entity: nil, type: nil)
    ])
}
