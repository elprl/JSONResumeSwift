//
//  InterestsView.swift
//  OpenCV
//
//  Created by Paul Leo on 30/06/2024.
//

import SwiftUI

struct InterestsView: View {
    @Environment(\.colorScheme) private var colorScheme
    let interests: [Interest]
    
    var body: some View {
        GroupBox {
            DisclosureGroup {
                Rectangle().frame(width: 0, height: 0).padding(.top)

                ForEach(interests) { element in
                    GroupBox {
                        HStack(alignment: .center) {
                            VStack(alignment: .leading) {
                                Text(element.name ?? "")
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack {
                                        ForEach(element.keywords ?? [], id: \.self) { keyword in
                                            VStack {
                                                Text(keyword)
                                                    .font(.caption)
                                                    .foregroundStyle(colorScheme == .dark ? .black : .white)
                                                    .lineLimit(1)
                                                    .padding(.vertical, 2)
                                                    .padding(.horizontal, 6)
                                            }
                                            .background(colorScheme == .dark ? .orange : .brown)
                                            .clipShape(Capsule())
                                        }
                                        Spacer()
                                    }
                                    .frame(height: 20)
                                    .scrollTargetLayout()
                                }
                                .scrollTargetBehavior(.paging)
                            }
                        }
                    }
                    .backgroundStyle(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(4)
                    .shadow(radius: 4)
                }
            } label: {
                HStack {
                    Label("Interests", systemImage: "heart")
                        .modifier(Heading())
                    Spacer()
                    Text("\(interests.count)")
                }
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
    InterestsView(interests: [
        Interest(name: "Web development", keywords: ["HTML", "CSS", "Typescript"]),
        Interest(name: "Web development", keywords: ["HTML", "CSS", "Typescript"])
    ])
}
