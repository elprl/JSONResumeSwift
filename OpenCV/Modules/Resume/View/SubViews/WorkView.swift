//
//  WorkView.swift
//  OpenCV
//
//  Created by Paul Leo on 29/06/2024.
//

import SwiftUI

struct WorkView: View {
    let works: [Work]
    
    var body: some View {
        GroupBox {
            Label("Work Experience", systemImage: "building.2")
                .modifier(Heading())
            
            ForEach(Array(works.enumerated()), id: \.element) { index, element in
                VStack(alignment: .leading, spacing: 4) {
                    Text(element.position)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack {
                        Text(element.name)
                            .font(.headline)
                            .lineLimit(1)
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
                        .tint(.secondary)
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
                                .opacity(index == (works.count - 1) ? 0 : 1)
                        }
                        .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.leading, 10)
                    .padding(.vertical, -4)
                }
            }
        }
        .backgroundStyle(.ultraThinMaterial)
        .padding(.horizontal, 4)
        .shadow(radius: 4)
    }
}

#Preview {
    WorkView(works: [
        Work(name: "Chelsea FC", location: "London", description: "Football Club", position: "Vice President", url: "https://company.com", startDate: Date(), endDate: Date(), summary: "Lead Architect", highlights: ["Started the company"]),
        Work(name: "Arsenal FC", location: "London", description: "Football Club", position: "Vice President", url: "https://company.com", startDate: Date(), endDate: Date(), summary: "Lead Architect", highlights: []),
        Work(name: "Man United", location: "London", description: "Football Club", position: "Vice President", url: "https://company.com", startDate: Date(), endDate: Date(), summary: "Lead Architect", highlights: ["Started the company", "Peerwalk (2024) - AI-powered iPad / MacOS app that allows teams to perform frequent and rapid code reviews. Fully SwiftUI MVVM integrating with: Firestore, Factory DI, Github APIs, ChatGPT / Claude / Gemini APIs."])
    ])
}
