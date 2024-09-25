//
//  StatsView.swift
//  OpenCV
//
//  Created by Paul Leo on 10/08/2024.
//

import SwiftUI

struct StatsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: ResumeViewModel
    
    var body: some View {
        GroupBox {
            DisclosureGroup {
                Rectangle().frame(width: 0, height: 0).padding(.top)
                experience
                averageDuration
            } label: {
                Label("Stats Overview", systemImage: "chart.bar.fill")
                    .modifier(Heading())
            }
            .tint(colorScheme == .dark ? .orange : .brown)
        }
        .groupBoxStyle(GlassifyGroupBoxStyle(lightStartPoint: .bottomLeading, lightEndPoint: .topTrailing, lightColor: .yellow))
        .padding(.horizontal, 4)
    }
    
    @ViewBuilder
    private var experience: some View {
        GroupBox {
            HStack {
                Text("Total Experience")
                    .font(.body)
                    .foregroundStyle(.primary)
                Spacer()
                Text(viewModel.totalExperience)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .groupBoxStyle(GlassifyGroupBoxStyle(lightStartPoint: .bottomLeading, lightEndPoint: .topTrailing, lightColor: .yellow))
        .padding(4)
    }
    
    @ViewBuilder
    private var averageDuration: some View {
        GroupBox {
            HStack {
                Text("Average Job Duration")
                    .font(.body)
                    .foregroundStyle(.primary)
                Spacer()
                Text(viewModel.averageJobDuration)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .groupBoxStyle(GlassifyGroupBoxStyle(lightStartPoint: .bottomLeading, lightEndPoint: .topTrailing, lightColor: .yellow))
        .padding(4)
    }
}

#Preview {
    StatsView(viewModel: ResumeViewModel(resumeUrl: "", resume: Resume.mock()))
}
