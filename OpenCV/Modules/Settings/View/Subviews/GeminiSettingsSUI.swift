//
//  GeminiSettingsSUI.swift
//  TDCodeReview
//
//  Created by Paul Leo on 24/05/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import SwiftUI

struct GeminiSettingsSUI: View {
    @StateObject private var viewModel: GeminiSettingsViewModel = GeminiSettingsViewModel()
    
    var body: some View {
        List {
            Section(header: SectionHeaderBlock(title: "Google Gemini", description: "Setup integration with Google's API")) {
                ForEach(viewModel.userTokenMetadataList.indices, id: \.self) { index in
                    AITokenRowSUI(token: viewModel.userTokenMetadataList[index], isActiveToken: viewModel.isActiveAccessToken(id: viewModel.userTokenMetadataList[index].id)) {
                        self.viewModel.makeActiveAccessToken(id: viewModel.userTokenMetadataList[index].id)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .onTapGesture {
                        return // disables tap on the whole row, except the button
                    }
                    .contextMenu {
                        Button(action: {
                            viewModel.delete(at: IndexSet(integer: index))
                        }, label: {
                            Text("Delete")
                        })
                    }
                }
                .onDelete(perform: viewModel.delete)
                .listRowSeparator(.hidden)
                NavigationLink(destination: GeminiInputSettingsSUI(viewModel: viewModel)) {
                    HStack {
                        Label(viewModel.userTokenMetadataList.isEmpty ? "Add Access Token" : "Add Another", systemImage: "plus.circle")
                            .foregroundStyle(.orange)
                        Spacer()
                    }
                }
                
                Picker(selection: $viewModel.modelSelection, label: Text("Chat Model")) {
                    ForEach(GeminiModel.allCases) { model in
                        Text("\(model.id) (\(model.maxTokens) tokens)").tag(model)
                    }
                }
                .font(.body)
                .tint(.orange)
                if case GeminiModel.custom(_, _) = viewModel.modelSelection {
                    HStack {
                        Text("Custom Model")
                            .font(.body)
                        Spacer()
                        TextField("", text: $viewModel.geminiModel, prompt: Text("Enter custom model, e.g. gpt-3.5-turbo"))
                            .lineLimit(1)
                            .font(.body)
                            .keyboardType(.asciiCapable)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .tint(.orange)
                            .multilineTextAlignment(.trailing)
                            .frame(alignment: .trailing)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(MeshGradientView().opacity(0.3).ignoresSafeArea())
        .navigationTitle("Google Gemini Settings")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.loadAccessTokens()
        }
    }
}

struct GeminiSettingsSUI_Previews: PreviewProvider {
    static var previews: some View {
        GeminiSettingsSUI()
    }
}
