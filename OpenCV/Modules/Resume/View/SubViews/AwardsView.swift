//
//  AwardsView.swift
//  OpenCV
//
//  Created by Paul Leo on 30/06/2024.
//

import SwiftUI

struct AwardsView: View {
    @Environment(\.colorScheme) private var colorScheme
    let awards: [Award]
    
    var body: some View {
        GroupBox {
            DisclosureGroup {
                Rectangle().frame(width: 0, height: 0).padding(.top)

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
                    .backgroundStyle(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(4)
                    .shadow(radius: 4)
                }
            } label: {
                Label("Awards", systemImage: "trophy")
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
    AwardsView(awards: [
        Award(title: "Victoria Cross", date: Date(), awarder: "Army", summary: "For bravery and honour"),
        Award(title: "Victoria Cross", date: Date(), awarder: "Army", summary: "For bravery and honour")
    ])
}
