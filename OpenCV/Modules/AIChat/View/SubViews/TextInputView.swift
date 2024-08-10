//
//  TextInputView.swift
//  OpenCV
//
//  Created by Paul Leo on 20/07/2024.
//
import SwiftUI

struct TextInputView: View {
    @State var viewModel: AIChatMessagesViewModel
    @FocusState private var isFocused: Bool
    @AppStorage(UserDefaults.Keys.hasAgiKey) var hasAgiKey: Bool = false
    @AppStorage(UserDefaults.Keys.hasClaudeKey) var hasClaudeKey: Bool = false
    @AppStorage(UserDefaults.Keys.hasGeminiKey) var hasGeminiKey: Bool = false
    @AppStorage(UserDefaults.Keys.selectedAGI) var selectedAGI: AGIServiceChoice = .none
    @AppStorage(UserDefaults.Keys.hasScopedRole) var hasScopedRole: Bool = true
    @AppStorage(UserDefaults.Keys.hasScopedCV) var hasScopedCV: Bool = true
    @AppStorage(UserDefaults.Keys.hasScopedHistory) var hasScopedHistory: Bool = true
    
    var body: some View {
        VStack {
            Spacer()
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
        .zIndex(1)
    }
    
    @ViewBuilder
    var scope: some View {
        if selectedAGI != .none {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Text("Scopes: ")
                    ToggleButton(title: "role", isOn: $hasScopedRole, onColor: .blue) {}
                    ToggleButton(title: "CV", isOn: $hasScopedCV, onColor: .blue) {}
                    ToggleButton(title: "history", isOn: $hasScopedHistory, onColor: .blue) {}
                    Spacer()
                }
            }
            .padding(.bottom, 2)
        }
    }
    
    @ViewBuilder
    var input: some View {
        HStack(alignment: .center, spacing: 6) {
            commentButton
            TextField(selectedAGI.placeholder, text: $viewModel.newChatText, axis: .vertical)
                .font(.body)
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
                .keyboardType(.asciiCapable)
                .focused($isFocused)
                .onSubmit {
                    self.viewModel.newChatText.append("\n")
                    self.isFocused = true
                }
                .submitLabel(.return)
                .lineLimit(1...10) // reservesSpace: true)
                .tint(.logoOrange)
                .foregroundColor(.primary)
            if viewModel.isAGIResponding {
                RoundButton(action: {
                    withAnimation {
                        self.viewModel.onCancelAGI()
                    }
                }, imageSize: 30, icon: "stop.fill", bgColor: .orange, isLoading: .constant(false))
            } else {
                RoundButton(action: {
                    withAnimation {
                        self.viewModel.onSubmitNewMessage()
                        self.isFocused = false
                    }
                }, imageSize: 30, icon: "paperplane.fill", bgColor: .blue, isLoading: .constant(false))
            }
        }
    }
    
    @ViewBuilder
    var commentButton: some View {
        Menu {
            Section(header: Text("Select AI Service".uppercased()).font(.headline).foregroundColor(.orange)) {
                if hasAgiKey {
                    Button {
                        self.selectedAGI = .openai
                        self.viewModel.updateAGIService(selectedAGI: .openai)
                    } label: {
                        Label(AGIServiceChoice.openai.name, image: AGIServiceChoice.openai.imageKey)
                    }
                }
                if hasClaudeKey {
                    Button {
                        self.selectedAGI = .claude
                        self.viewModel.updateAGIService(selectedAGI: .claude)
                    } label: {
                        Label(AGIServiceChoice.claude.name, image: AGIServiceChoice.claude.imageKey)
                    }
                }
                if hasGeminiKey {
                    Button {
                        self.selectedAGI = .gemini
                        self.viewModel.updateAGIService(selectedAGI: .gemini)
                    } label: {
                        Label(AGIServiceChoice.gemini.name, image: AGIServiceChoice.gemini.imageKey)
                    }
                }
            }
            Button(action: {
                self.selectedAGI = .none
                self.viewModel.updateAGIService(selectedAGI: .none)
            }) {
                Label("Personal Note", systemImage: "note")
            }
            Button(action: {
                self.viewModel.showingSettingsSheet = true
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
                    .foregroundStyle(.black)
                    .padding(4)
            }
            .frame(width: 30, height: 30)
        }
        .menuOrder(.fixed)
        .highPriorityGesture(TapGesture())
    }
}
