//
//  EducationView.swift
//  OpenCV
//
//  Created by Paul Leo on 29/06/2024.
//

import SwiftUI

struct EducationView: View {
    let educations: [Education]
    
    var body: some View {
        GroupBox {
            Label("Education", systemImage: "graduationcap")
                .modifier(Heading())
            
            ForEach(educations) { element in
                GroupBox {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(element.institution)
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
                        Text("\(element.area) (with \(element.score ?? ""))")
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        if !element.studyType.isEmpty {
                            Text(element.studyType)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Text(element.dates)
                            .font(.callout)
                            .foregroundStyle(.secondary)

                        if !(element.courses?.isEmpty ?? true) {
                            DisclosureGroup {
                                ForEach(element.courses ?? [], id: \.self) { highlight in
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
                            .tint(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .backgroundStyle(.ultraThinMaterial)
        .padding(.horizontal, 4)
        .shadow(radius: 4)
    }
}

#Preview {
    EducationView(educations: [
        Education(institution: "Durham University", url: "", area: "MEng in Systems Engineerring", studyType: "", startDate: Date(), endDate: Date(), score: "Distinction", courses: []),
        Education(institution: "Durahm Unfi", url: "", area: "MENg in engineerring", studyType: "", startDate: Date(), endDate: Date(), score: "Distinction", courses: [])
    ])
}
