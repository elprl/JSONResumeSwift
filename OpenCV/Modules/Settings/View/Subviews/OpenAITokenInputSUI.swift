//
//  OpenAITokenInputSUI.swift
//  TDCodeReview
//
//  Created by Paul Leo on 08/04/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct OpenAITokenInputSUI: View {
    @ObservedObject var viewModel: OpenAISettingsViewModel
    @Environment(\.openURL) var openURL
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            List {
                Label(title: {
                    Text("Connect your OpenAI Account")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.primary)
                }, icon: {
                    WebImage(url: URL(string: "https://chat.openai.com/favicon-32x32.png"))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                })
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                Section(header: Text("Steps")) {
                    Button {
                        openURL(URL(string: "https://platform.openai.com/account/api-keys")!)
                    } label: {
                        Text("**1**: Go to - https://platform.openai.com/account/api-keys")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .tint(.orange)
                    }
                    .listRowSeparator(.hidden)
                    Text("**2**: Create a new secret key")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .listRowSeparator(.hidden)
                    Text("**3**: Copy the key to clipboard")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .listRowSeparator(.hidden)
                    Text("**4**: Enter the details below")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .listRowSeparator(.hidden)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

                Section(header: Text("Enter secret key")) {
                    SecureField("Paste secret key here, e.g. sk-t3sdrfggt5dfhhgfkk7ghjgfhhsd3dDHJK4da", text: $viewModel.token)
                    Text("˟ Stored in your Secure Apple Keychain. NEVER sent to our servers.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .listRowSeparator(.hidden)
                    TextField("", text: $viewModel.name, prompt: Text("Add Label to help you identify this key"))
                        .lineLimit(1)
                        .keyboardType(.asciiCapable)
                        .textInputAutocapitalization(.never)
                        .tint(.orange)
                }
                
                Section {
                    Text(viewModel.errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .listRowSeparator(.hidden)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }.listStyle(.insetGrouped)
        }
        .onChange(of: self.viewModel.shouldDismissInputView) { 
            if self.viewModel.shouldDismissInputView {
                dismiss()
            }
        }
        .scrollContentBackground(.hidden)
        .background(MeshGradientView().opacity(0.3).ignoresSafeArea())
        .navigationTitle("New Secret Key")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: {
                    self.viewModel.didTapAdd()
                }) {
                    Text("Save")
                }
            }
        }
    }
}

#if DEBUG

struct OpenAITokenInputSUI_Previews: PreviewProvider {
    static var previews: some View {
        OpenAITokenInputSUI(viewModel: OpenAISettingsViewModel.mock())
    }
}

#endif
