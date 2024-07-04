//
//  EducationView.swift
//  OpenCV
//
//  Created by Paul Leo on 29/06/2024.
//

import SwiftUI

struct EducationView: View {
    @Environment(\.colorScheme) private var colorScheme
   let educations: [Education]
    
    var body: some View {
        GroupBox {
            DisclosureGroup {
                Rectangle().frame(width: 0, height: 0).padding(.top)

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
                            if !(element.studyType ?? "").isEmpty {
                                Text(element.studyType ?? "")
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
                                .tint(.gray)
                                .padding(.top, -4)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .backgroundStyle(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(4)
                    .shadow(radius: 4)
                }
            } label: {
                Label("Education", systemImage: "graduationcap")
                    .modifier(Heading())
            }
            .tint(colorScheme == .dark ? .orange : .brown)
        }
        .backgroundStyle(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 4)
        .shadow(radius: 4)
    }
}

#Preview {
    EducationView(educations: [
        Education(institution: "Durham University", url: "", area: "MEng in Systems Engineerring", studyType: "", startDate: "2020-12-22", endDate: "2020-12-22", score: "Distinction", courses: []),
        Education(institution: "Durahm Unfi", url: "", area: "MENg in engineerring", studyType: "", startDate: "2020-12-22", endDate: "2020-12-22", score: "Distinction", courses: [])
    ])
}
