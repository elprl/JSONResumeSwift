//
//  AIChatInputBar.swift
//  OpenCV
//
//  Created by Cursor on 23/05/2026.
//

import ExyteChat
import SwiftUI

struct AIChatInputBar: View {
    let params: InputViewBuilderParameters
    var viewModel: AIChatMessagesViewModel

    @FocusState private var isFocused: Bool
    @AppStorage(UserDefaults.Keys.hasAgiKey) var hasAgiKey: Bool = false
    @AppStorage(UserDefaults.Keys.hasClaudeKey) var hasClaudeKey: Bool = false
    @AppStorage(UserDefaults.Keys.hasGeminiKey) var hasGeminiKey: Bool = false
    @AppStorage(UserDefaults.Keys.selectedAGI) var selectedAGI: AGIServiceChoice = .none
    @AppStorage(UserDefaults.Keys.hasScopedRole) var hasScopedRole: Bool = true
    @AppStorage(UserDefaults.Keys.hasScopedCV) var hasScopedCV: Bool = true
    @AppStorage(UserDefaults.Keys.hasScopedHistory) var hasScopedHistory: Bool = true

    private var canSend: Bool {
        !params.text.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && inputViewStateAllowsSending
    }

    private var inputViewStateAllowsSending: Bool {
        switch params.inputViewState {
        case .hasTextOrMedia, .hasRecording, .isRecordingTap, .playingRecording, .pausedRecording:
            true
        default:
            false
        }
    }

    var body: some View {
        VStack {
            scope
                .padding(.horizontal)
            input
                .padding(.horizontal)
        }
        .padding(.top, 12)
        .padding(.bottom, isFocused ? 12 : 32)
        .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private var scope: some View {
        if selectedAGI != .none {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Text("Scopes: ")
                    ToggleButton(title: "role", isOn: $hasScopedRole, onColor: .orange, onTextColor: .black) {}
                    ToggleButton(title: "CV", isOn: $hasScopedCV, onColor: .orange, onTextColor: .black) {}
                    ToggleButton(title: "history", isOn: $hasScopedHistory, onColor: .orange, onTextColor: .black) {}
                    Spacer()
                }
            }
            .padding(.bottom, 2)
        }
    }

    @ViewBuilder
    private var input: some View {
        HStack(alignment: .center, spacing: 6) {
            commentButton
            TextField(selectedAGI.placeholder, text: params.text, axis: .vertical)
                .font(.body)
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
                .keyboardType(.asciiCapable)
                .focused($isFocused)
                .onSubmit {
                    params.text.wrappedValue.append("\n")
                    isFocused = true
                }
                .submitLabel(.return)
                .lineLimit(1...10)
                .tint(.logoOrange)
                .foregroundStyle(.primary)
            if viewModel.isAGIResponding {
                RoundButton(action: {
                    withAnimation {
                        viewModel.onCancelAGI()
                    }
                }, imageSize: 30, icon: "stop.fill", bgColor: .orange, isLoading: .constant(false))
            } else {
                RoundButton(action: {
                    withAnimation {
                        params.inputViewActionClosure(.send)
                        isFocused = false
                    }
                }, imageSize: 30, icon: "paperplane.fill", bgColor: .blue, isLoading: .constant(false))
                .disabled(!canSend)
                .opacity(canSend ? 1 : 0.45)
            }
        }
    }

    @ViewBuilder
    private var commentButton: some View {
        Menu {
            Section(header: Text("Select AI Service".uppercased()).font(.headline).foregroundStyle(.orange)) {
                if hasAgiKey {
                    Button {
                        selectedAGI = .openai
                        viewModel.updateAGIService(selectedAGI: .openai)
                    } label: {
                        Label(AGIServiceChoice.openai.name, image: AGIServiceChoice.openai.imageKey)
                    }
                }
                if hasClaudeKey {
                    Button {
                        selectedAGI = .claude
                        viewModel.updateAGIService(selectedAGI: .claude)
                    } label: {
                        Label(AGIServiceChoice.claude.name, image: AGIServiceChoice.claude.imageKey)
                    }
                }
                if hasGeminiKey {
                    Button {
                        selectedAGI = .gemini
                        viewModel.updateAGIService(selectedAGI: .gemini)
                    } label: {
                        Label(AGIServiceChoice.gemini.name, image: AGIServiceChoice.gemini.imageKey)
                    }
                }
            }
            Button(action: {
                selectedAGI = .none
                viewModel.updateAGIService(selectedAGI: .none)
            }) {
                Label("Personal Note", systemImage: "note")
            }
            Button(action: {
                viewModel.showingSettingsSheet = true
            }) {
                Label("Settings", systemImage: "gearshape")
            }
            Button(role: .cancel) {
            } label: {
                Text("Cancel")
            }
        } label: {
            VStack {
                Image(selectedAGI.imageKey)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.orange)
                    .padding(4)
            }
            .frame(width: 30, height: 30)
        }
        .menuOrder(.fixed)
        .highPriorityGesture(TapGesture())
    }
}
