//
//  SettingsView.swift
//  OpenCV
//
//  Created by Paul Leo on 03/07/2024.
//

import SwiftUI
import SDWebImageSwiftUI

enum NavigationItem {
    case openAISettings
    case openAIInputSettings
    case geminiSettings
    case geminiInputSettings
    case customAISettings
    case claudeSettings
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("darkLightAutoMode") private var darkLightAutoMode: UIUserInterfaceStyle = .unspecified
    @StateObject var aiViewModel: OpenAISettingsViewModel = OpenAISettingsViewModel()

    private struct Constants {
        static let appId = "6511210635"
    }

    var body: some View {
        NavigationStack {
            List {
                appPreferences
                aiSettings
                miscellaneous
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(MeshGradientView().opacity(0.3).ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationDestination(for: NavigationItem.self) { navItem in
                switch navItem {
                case .openAISettings:
                    OpenAISettingsSUI(viewModel: aiViewModel)
                case .geminiSettings:
                    GeminiSettingsSUI()
                case .claudeSettings:
                    ClaudeSettingsSUI()
                default:
                    EmptyView()
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(role: .cancel, action: {
                        self.dismiss()
                    }, label: {
                        Text("Cancel")
                            .foregroundStyle(colorScheme == .dark ? .orange : .brown)
                    })
                }
            }
        }
        .preferredColorScheme(ColorScheme(darkLightAutoMode)) // tint on status bar
    }
    
    @ViewBuilder
    private var appPreferences: some View {
        Section(header: SectionHeaderBlock(title: "App Preferences", description: "")) {
            Picker(selection: $darkLightAutoMode, label: Text("Visual Mode")) {
                Text("Automatic").font(.callout).tag(UIUserInterfaceStyle.unspecified)
                Text("Dark").font(.callout).tag(UIUserInterfaceStyle.dark)
                Text("Light").font(.callout).tag(UIUserInterfaceStyle.light)
            }
            .tint(colorScheme == .dark ? .orange : .brown)
        }
    }
    
    @ViewBuilder
    var aiSettings: some View {
        Section(header: SectionHeaderBlock(title: "AI SETUP", description: "Setup Integrations with AI Models")) {
            NavigationLink(value: NavigationItem.openAISettings) {
                HStack {
                    WebImage(url: URL(string: "https://chat.openai.com/favicon-32x32.png"))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                    Text("OpenAI / ChatGPT")
                        .font(.body)
                        .foregroundStyle(.primary)
                    Spacer()
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            NavigationLink(value: NavigationItem.claudeSettings) {
                HStack {
                    WebImage(url: URL(string: "https://www.anthropic.com/favicon.ico"))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                    Text("Anthropic Claude")
                        .font(.body)
                        .foregroundStyle(.primary)
                    Spacer()
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            NavigationLink(value: NavigationItem.geminiSettings) {
                HStack {
                    WebImage(url: URL(string: "https://ai.google.dev/static/docs/images/icon_480.png"))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                    Text("Google Gemini (US only)")
                        .font(.body)
                        .foregroundStyle(.primary)
                    Spacer()
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            NavigationLink(destination: SingleTextEditor(text: $aiViewModel.agiRole, defaultText: AGIServiceConstants.agiRole, title: "Role Setup", maxCharacters: 400)) {
                HStack {
                    Text("Role Setup").font(.body).lineLimit(1).foregroundStyle(.primary)
                    Spacer()
                    Text(aiViewModel.agiRole).font(.body).lineLimit(1).foregroundStyle(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    @ViewBuilder
    private var miscellaneous: some View {
        Section(header: SectionHeaderBlock(title: "Miscellaneous", description: "")) {
            NavigationLink("Licenses & Thanks") {
                List {
                    Text("JSON Resume\nhttps://github.com/jsonresume")
                    Text("SDWebImageSwiftUI\nhttps://github.com/SDWebImage/SDWebImageSwiftUI.git")
                    Text("generative-ai-swift\nhttps://github.com/google-gemini/generative-ai-swift")
                    Text("GPT3-Tokenizer\nhttps://github.com/aespinilla/GPT3-Tokenizer")
                    Text("SwiftAnthropic\nhttps://github.com/jamesrochabrun/SwiftAnthropic")
                    Text("CodeScanner\nhttps://github.com/twostraws/CodeScanner")
                    Text("swift-markdown\nhttps://github.com/apple/swift-markdown")
                }
                .scrollContentBackground(.hidden)
                .background(MeshGradientView().opacity(0.3).ignoresSafeArea())
            }
            createJSON
            share
            version
        }
        .tint(.primary)
    }
    
    @ViewBuilder
    private var createJSON: some View {
        Button {
            openLink(url: "https://jsonresume.org/getting-started")
        } label: {
            HStack {
                Text("How to create JSON CV")
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "link")
            }
        }
    }
    
    @ViewBuilder
    private var share: some View {
        ShareLink(item: URL(string: "https://apps.apple.com/app/id\(Constants.appId)")!, preview: SharePreview("https://apps.apple.com/app/id\(Constants.appId)", image: Image("AppIcon"))) {
            HStack {
                Text("Share App")
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "square.and.arrow.up")
            }
        }
    }
    
    @ViewBuilder
    private var version: some View {
        HStack {
            Text("Version")
                .lineLimit(1)
                .foregroundStyle(.primary)
            Spacer()
            Text(versionString)
                .font(.callout)
                .lineLimit(1)
                .foregroundStyle(.secondary)
        }
    }
    
    private var versionString: String {
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
           let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            return "v\(version) (\(build))"
        }
        return "unknown"
    }
}

struct SectionHeaderBlock: View {
    var title: String = ""
    var description: String = ""
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
}
