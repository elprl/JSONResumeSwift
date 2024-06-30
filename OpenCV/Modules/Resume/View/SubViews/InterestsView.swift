//
//  InterestsView.swift
//  OpenCV
//
//  Created by Paul Leo on 30/06/2024.
//

import SwiftUI

struct InterestsView: View {
    let interests: [Interest]
    
    var body: some View {
        GroupBox {
            Label("Interests", systemImage: "heart")
                .modifier(Heading())
            
            ForEach(interests) { element in
                GroupBox {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading) {
                            Text(element.name)
                                .font(.body)
                                .foregroundStyle(.primary)
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack {
                                    ForEach(element.keywords ?? [], id: \.self) { keyword in
                                        VStack {
                                            Text(keyword)
                                                .font(.caption)
                                                .foregroundStyle(.black)
                                                .lineLimit(1)
                                                .padding(.vertical, 2)
                                                .padding(.horizontal, 6)
                                        }
                                        .background(.yellow)
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
            }
        }
        .backgroundStyle(.ultraThinMaterial)
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
