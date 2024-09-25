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
                            Text(element.language ?? "")
                                .font(.body)
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(element.fluency ?? "")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .groupBoxStyle(GlassifyGroupBoxStyle(lightStartPoint: .bottomLeading, lightEndPoint: .topTrailing, lightColor: .yellow))
                    .padding(4)
                }
            } label: {
                HStack {
                    Label("Languages", systemImage: "speaker.wave.2.bubble")
                        .modifier(Heading())
                    Spacer()
                    Text("\(languages.count)")
                }
            }
            .tint(colorScheme == .dark ? .orange : .brown)
        }
        .groupBoxStyle(GlassifyGroupBoxStyle(lightStartPoint: .bottomLeading, lightEndPoint: .topTrailing, lightColor: .yellow))
        .padding(.horizontal, 4)
    }
}

#Preview {
    LanguagesView(languages: [
        Language(language: "English", fluency: "Native"),
        Language(language: "French", fluency: "Beginner")
    ])
}
