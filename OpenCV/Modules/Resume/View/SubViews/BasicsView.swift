//
//  BasicsView.swift
//  OpenCV
//
//  Created by Paul Leo on 30/06/2024.
//

import SwiftUI

struct BasicsView: View {
    @Environment(\.colorScheme) private var colorScheme
    let basics: Basics
    
    var body: some View {
        GroupBox {
            HStack(alignment: .center, spacing: 2) {
                AsyncImage(url: URL(string: basics.image ?? "")) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                .shadow(radius: 4)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(basics.name)
                        .font(.title2)
                        .foregroundStyle(.primary)
                    Text(basics.label ?? "")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text(basics.location?.region ?? "")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.leading)
                Spacer()
            }
        }
        .backgroundStyle(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 4)
        .shadow(radius: 4)
        .padding(.top)
        
        GroupBox {
            DisclosureGroup {
                Rectangle().frame(width: 0, height: 0).padding(.top)
                GroupBox {
                    Text(basics.summary)
                        .font(.body)
                        .lineLimit(nil)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(1.5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .backgroundStyle(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(4)
                .shadow(radius: 4)
            } label: {
                Label("Summary", systemImage: "person")
                    .modifier(Heading())
            }
            .tint(colorScheme == .dark ? .orange : .brown)
        }
        .padding(.top)
        .backgroundStyle(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 4)
        .shadow(radius: 4)
    }
}

#Preview {
    BasicsView(basics: Basics(name: "Paul Leo", label: "Vice President", image: "", email: "paul@tapdigital.com", phone: "0567678356345", url: "https://s3.eu-west-2.amazonaws.com/www.tapdigital.com/assets/images/cdv_avatar.jpeg", summary: "Mobile Architect", location: Location(address: nil, postalCode: nil, city: nil, countryCode: "UK", region: "Durham"), profiles: []))
}
