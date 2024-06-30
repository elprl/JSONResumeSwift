//
//  LanguagesView.swift
//  OpenCV
//
//  Created by Paul Leo on 30/06/2024.
//

import SwiftUI

struct LanguagesView: View {
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
                }
            } label: {
                Label("Languages", systemImage: "speaker.wave.2.bubble")
                    .modifier(Heading())
            }
            .tint(.orange)
        }
        .backgroundStyle(.ultraThinMaterial)
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
