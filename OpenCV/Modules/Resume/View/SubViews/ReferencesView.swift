//
//  ReferencesView.swift
//  OpenCV
//
//  Created by Paul Leo on 30/06/2024.
//

import SwiftUI

struct ReferencesView: View {
    @Environment(\.colorScheme) private var colorScheme
    let references: [Reference]
    
    var body: some View {
        GroupBox {
            DisclosureGroup {
                Rectangle().frame(width: 0, height: 0).padding(.top)

                ForEach(references) { element in
                    GroupBox {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(element.reference)
                                .font(.body)
                                .italic()
                                .foregroundStyle(.primary)
                            
                            Text(element.name)
                                .font(.callout)
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
                Label("References", systemImage: "person.badge.shield.checkmark")
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
    ReferencesView(references: [
        Reference(name: "Elon Musk", reference: "Greatest engineer the world has ever produced."),
        Reference(name: "Elon Musk", reference: "Greatest engineer the world has ever produced.")
    ])
}
