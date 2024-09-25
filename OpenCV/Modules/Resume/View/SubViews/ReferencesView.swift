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
                            Text(element.reference ?? "")
                                .font(.body)
                                .italic()
                                .foregroundStyle(.primary)
                            
                            Text(element.name ?? "")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .groupBoxStyle(GlassifyGroupBoxStyle(lightStartPoint: .bottomLeading, lightEndPoint: .topTrailing, lightColor: .yellow))
                    .padding(4)
                }
            } label: {
                HStack {
                    Label("References", systemImage: "person.badge.shield.checkmark")
                        .modifier(Heading())
                    Spacer()
                    Text("\(references.count)")
                }
            }
            .tint(colorScheme == .dark ? .orange : .brown)
        }
        .groupBoxStyle(GlassifyGroupBoxStyle(lightStartPoint: .bottomLeading, lightEndPoint: .topTrailing, lightColor: .yellow))
        .padding(.horizontal, 4)
    }
}

#Preview {
    ReferencesView(references: [
        Reference(name: "Elon Musk", reference: "Greatest engineer the world has ever produced."),
        Reference(name: "Elon Musk", reference: "Greatest engineer the world has ever produced.")
    ])
}
