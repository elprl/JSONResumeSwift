//
//  MyNotesView.swift
//  OpenCV
//
//  Created by Paul Leo on 03/07/2024.
//

import SwiftUI

struct MyNotesView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject var viewModel: MyNotesViewModel
    
    init(resumeUrl: String) {
        _viewModel = StateObject(wrappedValue: MyNotesViewModel(resumeUrl: resumeUrl))
    }
    
    var body: some View {
        GroupBox {
            DisclosureGroup {
                Rectangle().frame(width: 0, height: 0).padding(.top)
                GroupBox {
                    TextField("Enter notes", text: $viewModel.notes,  axis: .vertical)
                        .lineLimit(4...10)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                }
                .backgroundStyle(.ultraThickMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(4)
                .shadow(radius: 4)
            } label: {
                Label("My Notes", systemImage: "doc")
                    .modifier(Heading())
                    .tint(.primary)
            }
            .tint(colorScheme == .dark ? .orange : .brown)
        }
        .backgroundStyle(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 4)
        .shadow(radius: 4)
        .padding(.bottom, 160)
    }
}

#Preview {
    MyNotesView(resumeUrl: "notesKey")
}
