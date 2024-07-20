//
//  SingleTextEditorView.swift
//  OpenCV
//
//  Created by Paul Leo on 20/07/2024.
//

import SwiftUI

struct SingleTextEditor: View {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @Binding var text: String
    let defaultText: String
    var title: String = ""
    var maxCharacters: Int = 200
    
    var body: some View {
        List {
            HStack(alignment: .top) {
                TextField("", text: $text, axis: .vertical)
                    .font(.body)
                    .lineLimit(1...8)
                    .tint(.orange)
                    .foregroundStyle(.primary)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
                Spacer()
                Button("", systemImage: "xmark.circle.fill") {
                    text = ""
                }
                .foregroundStyle(.gray)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 0))
            Text("Character count: \(text.count)/\(maxCharacters)")
                .font(.caption)
                .foregroundStyle(text.count <= maxCharacters ? .green : .red)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 2, trailing: 8))
        }
        .scrollContentBackground(.hidden)
        .background {
            MeshGradientView()
                .opacity(0.3)
                .ignoresSafeArea()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: text) {
            if text.count > maxCharacters {
                text = String(text.prefix(maxCharacters))
            }
        }
        .onDisappear {
            if text.isEmpty {
                text = defaultText
            }
        }
    }
}

#Preview {
    Group {
        SingleTextEditor(text: .constant("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."), defaultText: "")
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .light)
            .previewDisplayName("Light Mode")
        
        SingleTextEditor(text: .constant("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."), defaultText: "")
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Dark Mode")
    }
}
