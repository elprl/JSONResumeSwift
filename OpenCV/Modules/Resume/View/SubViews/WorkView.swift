//
//  WorkView.swift
//  OpenCV
//
//  Created by Paul Leo on 29/06/2024.
//

import SwiftUI

struct WorkView: View {
    @Environment(\.colorScheme) private var colorScheme
    let works: [Work]
    
    var body: some View {
        GroupBox {
            DisclosureGroup {
                Rectangle().frame(width: 0, height: 0).padding(.top)

                ForEach(Array(works.enumerated()), id: \.element) { index, element in
                    VStack(alignment: .leading, spacing: 4) {
                        GroupBox {
                            position(element: element)
                            name(element: element)
                            dates(element: element)
                            highlights(element: element)
                        }
                        .backgroundStyle(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(4)
                        .shadow(radius: 4)
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
                                    .opacity(index == (works.count - 1) ? 0 : 1)
                            }
                            .foregroundStyle(colorScheme == .dark ? .orange : .brown)
                            Spacer()
                        }
                        .padding(.leading, 10)
                        .padding(.vertical, -4)
                    }
                }
            } label: {
                Label("Work Experience", systemImage: "building.2")
                    .modifier(Heading())
            }
            .tint(colorScheme == .dark ? .orange : .brown)
        }
        .backgroundStyle(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 4)
        .shadow(radius: 4)
    }
    
    @ViewBuilder
    private func position(element: Work) -> some View {
        Text(element.position ?? "")
            .font(.headline)
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
        Text(element.companyDescription ?? "")
            .font(.headline)
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func name(element: Work) -> some View {
        HStack {
            Text(element.name ?? "")
                .font(.subheadline)
                .lineLimit(1)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            if let url = element.url {
                Button {
                    openLink(url: url)
                } label: {
                    Image(systemName: "link")
                }
            }
        }
    }
    
    @ViewBuilder
    private func dates(element: Work) -> some View {
        Text(element.dates)
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func highlights(element: Work) -> some View {
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
    
    @ViewBuilder
    private func overlay(index: Int) -> some View {
        
    }
}

#Preview {
    WorkView(works: [
        Work(name: "Chelsea FC", location: "London", companyDescription: "Football Club", position: "Vice President", url: "https://company.com", startDate: "2020-12-22", endDate: "2020-12-22", summary: "Lead Architect", highlights: ["Started the company"]),
        Work(name: "Arsenal FC", location: "London", companyDescription: "Football Club", position: "Vice President", url: "https://company.com", startDate: "2020-12-22", endDate: "2020-12-22", summary: "Lead Architect", highlights: []),
        Work(name: "Man United", location: "London", companyDescription: "Football Club", position: "Vice President", url: "https://company.com", startDate: "2020-12-22", endDate: "2020-12-22", summary: "Lead Architect", highlights: ["Started the company", "Peerwalk (2024) - AI-powered iPad / MacOS app that allows teams to perform frequent and rapid code reviews. Fully SwiftUI MVVM integrating with: Firestore, Factory DI, Github APIs, ChatGPT / Claude / Gemini APIs."])
    ])
}
