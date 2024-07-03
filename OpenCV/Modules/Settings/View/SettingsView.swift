//
//  SettingsView.swift
//  OpenCV
//
//  Created by Paul Leo on 03/07/2024.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("darkLightAutoMode") private var darkLightAutoMode: UIUserInterfaceStyle = .unspecified

    var body: some View {
        NavigationStack {
            List {
                appPreferences
                miscellaneous
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(MeshGradientView().opacity(0.3).ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
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
            Picker(selection: $darkLightAutoMode, label: Text("Visual Mode").font(.headline)) {
                Text("Automatic").font(.callout).tag(UIUserInterfaceStyle.unspecified)
                Text("Dark").font(.callout).tag(UIUserInterfaceStyle.dark)
                Text("Light").font(.callout).tag(UIUserInterfaceStyle.light)
            }
            .tint(colorScheme == .dark ? .orange : .brown)
        }
    }
    
    @ViewBuilder
    private var miscellaneous: some View {
        Section(header: SectionHeaderBlock(title: "Miscellaneous", description: "")) {
            NavigationLink("Licenses") {
                List {
                    Text("JSON Resume\nhttps://github.com/jsonresume")
                }
            }
            version
        }
    }
    
    @ViewBuilder
    private var version: some View {
        HStack {
            Text("Version")
                .font(.headline)
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
                    .font(.headline)
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
