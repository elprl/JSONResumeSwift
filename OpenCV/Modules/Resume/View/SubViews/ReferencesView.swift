//
//  ReferencesView.swift
//  OpenCV
//
//  Created by Paul Leo on 30/06/2024.
//

import SwiftUI

struct ReferencesView: View {
    let references: [Reference]
    
    var body: some View {
        GroupBox {
            Label("References", systemImage: "person.badge.shield.checkmark")
                .modifier(Heading())
            
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
            }
        }
        .backgroundStyle(.ultraThinMaterial)
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
