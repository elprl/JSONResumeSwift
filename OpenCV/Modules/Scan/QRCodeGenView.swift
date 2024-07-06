//
//  QRScanner.swift
//  OpenCV
//
//  Created by Paul Leo on 04/07/2024.
//
import SwiftUI

struct QRCodeGenView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("darkLightAutoMode") private var darkLightAutoMode: UIUserInterfaceStyle = .unspecified
    let resumeUrl: String
    @State private var isRaw: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker(selection: $isRaw, label: Text("JSON Link or App Clip")) {
                    Text("JSON URL").font(.body).tag(true)
                    Text("App Clip").font(.body).tag(false)
                }
                .font(.body)
                .tint(colorScheme == .dark ? .orange : .brown)
                .padding(.horizontal, 20)
                GroupBox {
                    if let qrCodeImage = QRCodeGenerator().generateCode(from: isRaw ? resumeUrl : generateAppClipLink(resumeUrl: resumeUrl)) {
                        Image(uiImage: qrCodeImage)
                            .interpolation(.none)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 320, height: 320)
                    } else {
                        Text("Failed to generate QR Code")
                    }
                    if !isRaw {
                        HStack(alignment: .center) {
                            Image(systemName: "apple.logo").padding(.trailing, -6)
                            Text("App Clip").padding(.top, 6)
                        }
                        .foregroundStyle(.black)
                        .font(.title)
                        .bold()
                    }
                }
                .backgroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding()
                .shadow(radius: 4)
                Text("or")
                    .lineLimit(1)
                Text(isRaw ? resumeUrl : generateAppClipLink(resumeUrl: resumeUrl))
                    .foregroundStyle(colorScheme == .dark ? .orange : .brown)
                    .lineLimit(1)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .truncationMode(.middle)
                    .padding(.top)
                    .padding(.horizontal, 44)

                Button {
                    UIPasteboard.general.string = isRaw ? resumeUrl : generateAppClipLink(resumeUrl: resumeUrl)
                } label: {
                    Label("Copy to Clipboard", systemImage: "clipboard")
                        .foregroundStyle(colorScheme == .dark ? .orange : .brown)
                }
                Spacer()
            }
            .navigationTitle("Scan CV")
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
    
    private func generateAppClipLink(resumeUrl: String) -> String {
        return "https://appclip.apple.com/id?p=com.tapdigital.OpenCV.Clip&url=\(resumeUrl.toBase64)"
    }
}

#Preview {
    QRCodeGenView(resumeUrl: "https://gist.githubusercontent.com/elprl/725d3337a3baedcfd95306e296587e8a/raw/e2ff19713945a8f2ae8c5bd5e4cdff8840a7b6ba/resume.json")
}
