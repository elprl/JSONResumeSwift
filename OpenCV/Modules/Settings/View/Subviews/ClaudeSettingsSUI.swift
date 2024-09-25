//
//  ClaudeSettingsSUI.swift
//  TDCodeReview
//
//  Created by Paul Leo on 24/05/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import SwiftUI

struct ClaudeSettingsSUI: View {
    @StateObject private var viewModel: ClaudeSettingsViewModel = ClaudeSettingsViewModel()
    
    var body: some View {
        List {
            Section(header: SectionHeaderBlock(title: "Anthropic Claude", description: "Setup integration with Anthropic's Claude API")) {
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
                NavigationLink(destination: ClaudeInputSettingsSUI(viewModel: viewModel)) {
                    HStack {
                        Label(viewModel.userTokenMetadataList.isEmpty ? "Add Access Token" : "Add Another", systemImage: "plus.circle")
                            .foregroundStyle(.orange)
                        Spacer()
                    }
                }
                
                Picker(selection: $viewModel.modelSelection, label: Text("Chat Model")) {
                    ForEach(ClaudeModel.allCases) { model in
                        Text("\(model.id) (\(model.maxTokens) tokens)").tag(model)
                    }
                }
                .font(.body)
                .tint(.orange)
                if case ClaudeModel.custom(_, _) = viewModel.modelSelection {
                    HStack {
                        Text("Custom Model")
                            .font(.body)
                        Spacer()
                        TextField("", text: $viewModel.claudeModel, prompt: Text("Enter custom model, e.g. gpt-3.5-turbo"))
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
        .navigationTitle("Claude Settings")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.loadAccessTokens()
        }
    }
}

struct ClaudeSettingsSUI_Previews: PreviewProvider {
    static var previews: some View {
        ClaudeSettingsSUI()
    }
}
