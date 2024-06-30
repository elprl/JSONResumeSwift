//
//  SkillsView.swift
//  OpenCV
//
//  Created by Paul Leo on 29/06/2024.
//

import SwiftUI

struct SkillsView: View {
    let skills: [Skill]
    
    var body: some View {
        GroupBox {
            Label("Skills", systemImage: "star")
                .modifier(Heading())
            
            ForEach(skills) { element in
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
                        Spacer()
                        Text(element.level)
                            .font(.callout)
                            .foregroundStyle(.primary)
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
    SkillsView(skills: [
        Skill(name: "Web Developer", level: "Master", keywords: ["CSS","HTML", "Objective-c", "Swift", "Typescript"]),
        Skill(name: "Web Developer", level: "Master", keywords: ["CSS","HTML"]),
        Skill(name: "Web Developer", level: "Master", keywords: ["CSS","HTML"])])
}
