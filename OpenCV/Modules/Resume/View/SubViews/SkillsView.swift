//
//  SkillsView.swift
//  OpenCV
//
//  Created by Paul Leo on 29/06/2024.
//

import SwiftUI

struct SkillsView: View {
    @Environment(\.colorScheme) private var colorScheme
    let skills: [Skill]
    
    var body: some View {
        GroupBox {
            DisclosureGroup {
                Rectangle().frame(width: 0, height: 0).padding(.top)

                ForEach(skills) { element in
                    GroupBox {
                        VStack(alignment: .leading) {
                            HStack(alignment: .center) {
                                Text(element.name)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text(element.skillLevel)
                                    .font(.callout)
                                    .foregroundStyle(colorScheme == .dark ? .orange : .brown)
                            }
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack {
                                    ForEach(element.keywords ?? [], id: \.self) { keyword in
                                        VStack {
                                            Text(keyword)
                                                .font(.caption)
                                                .foregroundStyle(colorScheme == .dark ? .black : .white)
                                                .lineLimit(1)
                                                .padding(.vertical, 2)
                                                .padding(.horizontal, 8)
                                        }
                                        .background(colorScheme == .dark ? .orange : .brown)
                                        .clipShape(Capsule())
                                        .shadow(radius: 1)
                                    }
                                    Spacer()
                                }
                                .frame(height: 20)
                                .scrollTargetLayout()
                            }
                            .scrollTargetBehavior(.paging)
                        }
                    }
                    .backgroundStyle(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(4)
                    .shadow(radius: 4)
                }
            } label: {
                Label("Skills", systemImage: "star")
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
    SkillsView(skills: [
        Skill(name: "Web Developer", level: "Master", keywords: ["CSS","HTML", "Objective-c", "Swift", "Typescript"]),
        Skill(name: "Web Developer", level: "Master", keywords: ["CSS","HTML"]),
        Skill(name: "Web Developer", level: "Master", keywords: ["CSS","HTML"])])
}
