//
//  LanguagesView.swift
//  OpenCV
//
//  Created by Paul Leo on 30/06/2024.
//

import SwiftUI

struct LanguagesView: View {
    @Environment(\.colorScheme) private var colorScheme
    let languages: [Language]
    
    var body: some View {
        GroupBox {
            DisclosureGroup {
                Rectangle().frame(width: 0, height: 0).padding(.top)

                ForEach(languages) { element in
                    GroupBox {
                        HStack(alignment: .center) {
                            Text(element.language)
                                .font(.body)
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(element.fluency)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .backgroundStyle(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(4)
                    .shadow(radius: 4)
                }
            } label: {
                Label("Languages", systemImage: "speaker.wave.2.bubble")
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
    LanguagesView(languages: [
        Language(language: "English", fluency: "Native"),
        Language(language: "French", fluency: "Beginner")
    ])
}
