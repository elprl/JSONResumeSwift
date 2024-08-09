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
    @AppStorage("darkLightAutoMode") private var darkLightAutoMode: UIUserInterfaceStyle = .unspecified

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
        .preferredColorScheme(ColorScheme(darkLightAutoMode)) // tint on status bar
    }
    
    @ViewBuilder
    private var header: some View {
        Text("JSON CV is based on the open-source JSON Resume project: \nhttps://github.com/jsonresume\n\nThe CV URL entered below must conform to the JSON schema:\nhttps://jsonresume.org/schema")
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
            .font(.body)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom)
    }
    
    @ViewBuilder
    private var input: some View {
        GroupBox {
            HStack {
                TextField("", text: $viewModel.url, axis: .vertical)
                    .lineLimit(4...10)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .modifier(PlaceholderStyle(showPlaceHolder: viewModel.url.isEmpty,
                                               placeholder: "Enter a URL to CV \n(e.g. https://registry.jsonresume.org/elprl.json)"))
                Spacer()
                VStack {
                    Button {
                        viewModel.url = ""
                        viewModel.state = .appeared
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                    .disabled(viewModel.url.isEmpty)
                    .padding(.bottom, 20)
                    Button {
                        viewModel.showingScanSheet = true
                    } label: {
                        Image(systemName: "qrcode.viewfinder")
                    }
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
                Capsule().fill(colorScheme == .dark ? .orange : .brown)
                    .shadow(radius: 4)
                    .opacity(viewModel.isValidUrl ? 1.0 : 0.3)
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
                Log.view.error("error adding item")
            }
        }
    }
}

struct PlaceholderStyle: ViewModifier {
    var showPlaceHolder: Bool
    var placeholder: String

    public func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceHolder {
                Text(placeholder)
                    .foregroundStyle(.secondary)
                    .padding(.top, -20)
                    .padding(.horizontal, 4)
            }
            content
                .foregroundStyle(.primary)
                .padding(4.0)
        }
    }
}

#Preview {
    let viewModel = ResumeListViewModel(modelContext: PreviewController.previewContainer.mainContext)
    InputFormView(viewModel: viewModel)
        .modelContainer(PreviewController.previewContainer)
}
