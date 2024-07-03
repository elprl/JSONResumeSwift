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
        NavigationStack {
            VStack {
                GroupBox {
                    header
                    input
                    submit
                }
                .backgroundStyle(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(4)
                .shadow(radius: 4)
                .tint(colorScheme == .dark ? .orange : .brown)
                .padding()
                Spacer()
            }
            .background(MeshGradientView().opacity(0.3).ignoresSafeArea())
            .navigationTitle("Add New CV")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(role: .cancel, action: {
                        self.dismiss()
                    }, label: {
                        Text("Cancel")
                    })
                    .tint(colorScheme == .dark ? .orange : .brown)
                }
            }
            .onReceive(viewModel.$state) { state in
                if case .loaded(_) = state {
                    self.dismiss()
                }
            }
        }
        .presentationSizing(.form)
    }
    
    @ViewBuilder
    private var header: some View {
        Text("JSON CV is based on the open-source JSON Resume project: \nhttps://github.com/jsonresume\n\nThe CV URL entered below must conform to the JSON schema:\nhttps://jsonresume.org/schema")
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
            .font(.body)
            .foregroundStyle(.secondary)
            .padding(.bottom)
    }
    
    @ViewBuilder
    private var input: some View {
        GroupBox {
            HStack {
                TextField("Enter a URL to CV, e.g. https://www.domain.com/resume.json", text: $viewModel.url, axis: .vertical)
                    .lineLimit(4...10)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                Spacer()
                Button {
                    viewModel.url = ""
                    viewModel.state = .appeared
                } label: {
                    Image(systemName: "xmark.circle")
                }
            }
        }
        .backgroundStyle(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(4)
        .shadow(radius: 4)
        .tint(colorScheme == .dark ? .orange : .brown)
    }
    
    @ViewBuilder
    private var submit: some View {
        switch viewModel.state {
        case .appeared:
            Button {
                addItem()
            } label: {
                Text("Submit")
                    .tint(colorScheme == .dark ? .black : .white)
                    .padding(.horizontal)
                    .padding(.vertical, 4)
            }
            .disabled(!viewModel.isValidUrl)
            .background {
                Capsule().fill(colorScheme == .dark ? .orange : .brown).shadow(radius: 4)
            }
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
