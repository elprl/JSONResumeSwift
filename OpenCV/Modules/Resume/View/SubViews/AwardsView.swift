//
//  AwardsView.swift
//  OpenCV
//
//  Created by Paul Leo on 30/06/2024.
//

import SwiftUI

struct AwardsView: View {
    let awards: [Award]
    
    var body: some View {
        GroupBox {
            Label("Awards", systemImage: "trophy")
                .modifier(Heading())
            
            ForEach(awards) { element in
                GroupBox {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(element.title)
                            .font(.body)
                            .foregroundStyle(.primary)
                        if let date = element.date {
                            Text(date.formatted(Date.FormatStyle().year().month()))
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
            }
        }
        .backgroundStyle(.ultraThinMaterial)
        .padding(.horizontal, 4)
        .shadow(radius: 4)
    }
}

#Preview {
    AwardsView(awards: [
        Award(title: "Victoria Cross", date: Date(), awarder: "Army", summary: "For bravery and honour"),
        Award(title: "Victoria Cross", date: Date(), awarder: "Army", summary: "For bravery and honour")
    ])
}
