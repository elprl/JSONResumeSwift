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
                                    .opacity(index == (works.count - 1) ? 0 : 1)
                            }
                            .foregroundStyle(colorScheme == .dark ? .orange : .brown)
                            Spacer()
                        }
                        .padding(.leading, 4)
                        .padding(.vertical, -4)
                    }
                }
            } label: {
                HStack {
                    Label("Work Experience", systemImage: "building.2")
                        .modifier(Heading())
                    Spacer()
                    Text("\(works.count)")
                }
            }
            .tint(colorScheme == .dark ? .orange : .brown)
        }
        .groupBoxStyle(GlassifyGroupBoxStyle(lightStartPoint: .bottomLeading, lightEndPoint: .topTrailing, lightColor: .yellow))
        .padding(.horizontal, 4)
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
