//
//  PublicationsView.swift
//  OpenCV
//
//  Created by Paul Leo on 30/06/2024.
//

import SwiftUI

struct PublicationsView: View {
    @Environment(\.colorScheme) private var colorScheme
    let publications: [Publication]
    
    var body: some View {
        GroupBox {
            DisclosureGroup {
                Rectangle().frame(width: 0, height: 0).padding(.top)

                ForEach(publications) { element in
                    GroupBox {
                        VStack(alignment: .leading, spacing: 4) {
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
                            if let publisher = element.publisher {
                                Text(publisher)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            if let date = element.releaseDate {
                                Text(date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Text(element.summary)
                                .font(.callout)
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                                .foregroundStyle(.secondary)
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .backgroundStyle(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(4)
                    .shadow(radius: 4)
                }
            } label: {
                Label("Publications", systemImage: "text.book.closed")
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
    PublicationsView(publications: [
        Publication(name: "Quantum Entaglement of Hydrogen elections", publisher: "Nature", releaseDate: "2020-12-22", url: "https://www.nature.com", summary: "Communications across Galaxies with Quantum Entaglement of Hydrogen elections"),
        Publication(name: "Quantum Entaglement of Hydrogen elections", publisher: "Nature", releaseDate: "2020-12-22", url: "https://www.nature.com", summary: "Communications across Galaxies with Quantum Entaglement of Hydrogen elections")
    ])
}
