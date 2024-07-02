//
//  CertificatesView.swift
//  OpenCV
//
//  Created by Paul Leo on 30/06/2024.
//

import SwiftUI

struct CertificatesView: View {
    @Environment(\.colorScheme) private var colorScheme
    let certificates: [Certificate]
    
    var body: some View {
        GroupBox {
            DisclosureGroup {
                Rectangle().frame(width: 0, height: 0).padding(.top)

                ForEach(certificates) { element in
                    GroupBox {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(element.name)
                                    .font(.body)
                                    .lineLimit(nil)
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if let url = element.url {
                                    Button {
                                        openLink(url: url)
                                    } label: {
                                        Image(systemName: "link")
                                    }
                                }
                            }
                            if let date = element.date {
                                Text(date.formatted(Date.FormatStyle().year().month()))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            if let issuer = element.issuer {
                                Text(issuer)
                                    .font(.callout)
                                    .lineLimit(nil)
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .backgroundStyle(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(4)
                    .shadow(radius: 4)
                }
            } label: {
                Label("Certifications", systemImage: "rosette")
                    .modifier(Heading())
            }  
            .tint(colorScheme == .dark ? .orange : .brown)
        }
        .backgroundStyle(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 4)
        .shadow(radius: 4)
    }
}

#Preview {
    CertificatesView(certificates: [
        Certificate(name: "Sun Certified Programmer", date: Date(), url: "", issuer: "Sun Microsystems"),
        Certificate(name: "Sun Certified Programmer", date: Date(), url: "", issuer: "Sun Microsystems"),
    ])
}
