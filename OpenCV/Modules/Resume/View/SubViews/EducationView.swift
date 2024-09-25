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
                                Text(element.institution ?? "")
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
                            if !score(for: element).isEmpty {
                                Text(score(for: element))
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                            }
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
                    .groupBoxStyle(GlassifyGroupBoxStyle(lightStartPoint: .bottomLeading, lightEndPoint: .topTrailing, lightColor: .yellow))
                    .padding(4)
                }
            } label: {
                HStack {
                    Label("Education", systemImage: "graduationcap")
                        .modifier(Heading())
                    Spacer()
                    Text("\(educations.count)")
                }
            }
            .tint(colorScheme == .dark ? .orange : .brown)
        }
        .groupBoxStyle(GlassifyGroupBoxStyle(lightStartPoint: .bottomLeading, lightEndPoint: .topTrailing, lightColor: .yellow))
        .padding(.horizontal, 4)
    }
    
    private func score(for education: Education) -> String {
        var text = ""
        if let area = education.area, !area.isEmpty {
            text.append(area)
        }
        if let score = education.score, !score.isEmpty {
            text.append(" (\(score))")
        }
        return text
    }
}

#Preview {
    EducationView(educations: [
        Education(institution: "Durham University", url: "", area: "MEng in Systems Engineerring", studyType: "", startDate: "2020-12-22", endDate: "2020-12-22", score: "Distinction", courses: []),
        Education(institution: "Durahm Unfi", url: "", area: "MENg in engineerring", studyType: "", startDate: "2020-12-22", endDate: "2020-12-22", score: "Distinction", courses: [])
    ])
}
