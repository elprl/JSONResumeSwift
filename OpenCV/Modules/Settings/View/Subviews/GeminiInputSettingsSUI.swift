//
//  GeminiInputSettingsSUI.swift
//  TDCodeReview
//
//  Created by Paul Leo on 24/05/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct GeminiInputSettingsSUI: View {
    @ObservedObject var viewModel: GeminiSettingsViewModel
    @Environment(\.openURL) var openURL
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            List {
                Label(title: {
                    Text("Connect your Google Gemini API Account")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.primary)
                }, icon: {
                    WebImage(url: URL(string: "https://ai.google.dev/static/docs/images/icon_480.png"))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                })
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                Section(header: Text("Steps")) {
                    Button {
                        openURL(URL(string: "https://makersuite.google.com/app/apikey")!)
                    } label: {
                        Text("**1**: Get an API key - https://makersuite.google.com/app/apikey")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .tint(.orange)
                    }
                    .listRowSeparator(.hidden)
                    Text("**2**: Copy the key to clipboard")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .listRowSeparator(.hidden)
                    Text("**3**: Enter the details below")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .listRowSeparator(.hidden)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

                Section(header: Text("Enter API key")) {
                    SecureField("Paste API key here, e.g. sk-t3sdrfggt5dfhhgfkk7ghjgfhhsd3dDHJK4da", text: $viewModel.token)
                    Text("˟ Stored in your Secure Apple Keychain. NEVER sent to our servers.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .listRowSeparator(.hidden)
                    TextField("", text: $viewModel.name, prompt: Text("Add Label to help you identify this key"))
                        .lineLimit(1)
                        .tint(.orange)
                        .foregroundColor(.primary)
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

struct GeminiInputSettingsSUI_Previews: PreviewProvider {
    static var previews: some View {
        GeminiInputSettingsSUI(viewModel: GeminiSettingsViewModel.mock())
    }
}

#endif
