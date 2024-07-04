//
//  VolunteerView.swift
//  OpenCV
//
//  Created by Paul Leo on 30/06/2024.
//

import SwiftUI

struct VolunteerView: View {
    @Environment(\.colorScheme) private var colorScheme
    let vols: [Volunteer]
    
    var body: some View {
        GroupBox {
            DisclosureGroup {
                Rectangle().frame(width: 0, height: 0).padding(.top)

                ForEach(Array(vols.enumerated()), id: \.element) { index, element in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(element.position)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(element.organization)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(element.dates)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(element.summary)
                            .font(.body)
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(1.5)
                            .foregroundStyle(.primary)
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
                            .tint(.secondary)
                            .padding(.top, -4)
                        }
                    }
                    .frame(maxWidth: .infinity)
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
                                    .opacity(index == (vols.count - 1) ? 0 : 1)
                            }
                            .foregroundStyle(colorScheme == .dark ? .orange : .brown)
                            Spacer()
                        }
                        .padding(.leading, 10)
                        .padding(.vertical, -4)
                    }
                }
            } label: {
                Label("Volunteer Experience", systemImage: "figure.2.arms.open")
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
    VolunteerView(vols: [
        Volunteer(organization: "Org", position: "vp", url: "MEng in Systems Engineerring", startDate: "2020-12-22", endDate: "2020-12-22", summary: "Distinction", highlights: []),
        Volunteer(organization: "Org", position: "vp", url: "MEng in Systems Engineerring", startDate: "2020-12-22", endDate: "2020-12-22", summary: "Distinction", highlights: []),
    ])
}
