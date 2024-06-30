//
//  ResumeView.swift
//  OpenCV
//
//  Created by Paul Leo on 28/06/2024.
//

import SwiftUI
import SwiftData

struct ResumeContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject var model: ResumeViewModel = ResumeViewModel()
    @State var isLoaded: Bool = false

    var body: some View {
        VStack {
            if isLoaded {
                Text(model.resume?.basics.name ?? "n/a")
                    .transition(.move(edge: .bottom))
            } else {
                Text("Loading...")
            }
        }
        .transition(.move(edge: .bottom))
        .onReceive(model.$resume) { _ in
            withAnimation {
                self.isLoaded = true
            }
        }
        .task {
            await model.loadResume()
        }
    }
}

#Preview {
    ResumeContainerView()
}
