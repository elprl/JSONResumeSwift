//
//  OpenAISettingsSUI.swift
//  TDCodeReview
//
//  Created by Paul Leo on 08/04/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import SwiftUI

struct OpenAISettingsSUI: View {
    @ObservedObject var viewModel: OpenAISettingsViewModel
    
    var body: some View {
        List {
            Section(header: SectionHeaderBlock(title: "OpenAI", description: "Switch between OpenAI Accounts")) {
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
                NavigationLink(destination: OpenAITokenInputSUI(viewModel: viewModel)) {
                    HStack {
                        Label(viewModel.userTokenMetadataList.isEmpty ? "Add Access Token" : "Add Another", systemImage: "plus.circle")
                            .foregroundStyle(.orange)
                        Spacer()
                    }
                }
                Picker(selection: $viewModel.modelSelection, label: Text("Chat Model")) {
                    ForEach(GPTModel.allCases) { model in
                        Text("\(model.id) (\(model.maxTokens) tokens)").tag(model)
                    }
                }
                .font(.body)
                .tint(.orange)
                if case GPTModel.custom(_, _) = viewModel.modelSelection {
                    HStack {
                        Text("Custom Model")                
                            .font(.body)
                        Spacer()
                        TextField("", text: $viewModel.openAiModel, prompt: Text("Enter custom model, e.g. gpt-3.5-turbo"))
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
                HStack {
                    Spacer()
                    Text("GPT-4 requires acceptance from OpenAI on limited beta. [Waitlist](https://openai.com/waitlist/gpt-4-api)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .tint(.orange)
                }
                .listRowSeparator(.hidden)
            }
        }
        .scrollContentBackground(.hidden)
        .background(MeshGradientView().opacity(0.3).ignoresSafeArea())
        .navigationTitle("Open AI Settings")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.loadAccessTokens()
        }
    }
}

struct AITokenRowSUI: View {
    var token: APIAccessToken
    var isActiveToken: Bool = true
    let action: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(token.label)
                    .lineLimit(1)
                    .font(.title3)
                    .foregroundColor(.primary)
                Text(token.tokenHint)
                    .lineLimit(1)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Button {
                    self.action()
                } label: {
                    Text(isActiveToken ? "Active" : "Set Active")
                        .lineLimit(1)
                        .font(.body)
                        .underline(!isActiveToken)
                        .foregroundColor(isActiveToken ? .orange : .blue)
                }
                
                .disabled(isActiveToken ? true : false)
                Text("Expires: \(token.expiry?.formatted(.relative(presentation: .named, unitsStyle: .wide)) ?? "never")")
                    .lineLimit(1)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#if DEBUG

struct OpenAISettingsSUI_Previews: PreviewProvider {
    static var previews: some View {
        OpenAISettingsSUI(viewModel: OpenAISettingsViewModel.mock())
    }
}

#endif
