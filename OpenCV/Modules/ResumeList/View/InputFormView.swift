//
//  InputFormView.swift
//  OpenCV
//
//  Created by Paul Leo on 02/07/2024.
//

import SwiftUI
import SwiftData

struct InputFormView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ResumeListViewModel

    var body: some View {
        VStack {
            GroupBox {
                Text("JSON CV")
                    .lineLimit(1)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .padding(.vertical)
                Text("JSON CV is based on the Open Source JSON Resume project: \nhttps://github.com/jsonresume\n\nThe CV URL entered below must conform to the JSON schema:\nhttps://jsonresume.org/schema")
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.bottom)
                GroupBox {
                    TextField("Enter a URL, e.g. https://domain.com/resume.json", text: $viewModel.url)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
                
                switch viewModel.state {
                case .appeared:
                    Button {
                        addItem()
                    } label: {
                        Text("Submit")
                    }
                    .disabled(!viewModel.isValidUrl)
                    .buttonStyle(.bordered)
                    .padding()
                case .loading:
                    ProgressView()
                case .loaded(_):
                    Image(systemName: "checkmark")
                        .foregroundStyle(.green)
                case .empty(_):
                    EmptyView()
                case let .error(message):
                    Text(message)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .font(.body)
                        .foregroundStyle(.red)
                        .padding()
                }
            }
            .backgroundStyle(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(4)
            .shadow(radius: 4)
            .tint(colorScheme == .dark ? .orange : .brown)
            .padding()
        }
        .presentationSizing(.form.fitted(horizontal: false, vertical: true))
        .onReceive(viewModel.$state) { state in
            if case .loaded(_) = state {
                self.dismiss()
            }
        }
    }
    
    private func addItem() {
        Task { @MainActor in
            do {
                try await viewModel.addItem(urlString: viewModel.url)
            } catch {
                print("error")
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Person.self, configurations: config)
    // Create a mock ViewModel
    let viewModel = ResumeListViewModel(modelContext: container.mainContext)
    InputFormView(viewModel: viewModel)
}
