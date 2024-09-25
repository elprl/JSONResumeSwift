//
//  BasicsView.swift
//  OpenCV
//
//  Created by Paul Leo on 30/06/2024.
//

import SwiftUI
import NukeUI

struct BasicsView: View {
    @Environment(\.colorScheme) private var colorScheme
    let basics: Basics
    
    var body: some View {
        GroupBox {
            HStack(alignment: .center, spacing: 2) {
                LazyImage(url: URL(string: basics.image ?? "")) { state in
                    if let image = state.image {
                        image.resizable().aspectRatio(contentMode: .fit)
                    } else if state.error != nil {
                        Image(systemName: "exclamationmark.triangle.fill") // Indicates an error
                    } else {
                        placeholderImage // Acts as a placeholder
                    }
                }
                .transition(.opacity)
                .animation(.easeInOut, value: basics.image)
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                .shadow(radius: 4)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(basics.name ?? "")
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
                VStack(alignment: .trailing, spacing: 8) {
                    if let phone = basics.phone {
                        Button {
                            openLink(url: "tel://\(phone)")
                        } label: {
                            Image(systemName: "phone")
                        }
                    }
                    if let email = basics.email {
                        Button {
                            openLink(url: "mailto:\(email)")
                        } label: {
                            Image(systemName: "mail")
                        }
                    }
                    if let url = basics.url {
                        Button {
                            openLink(url: url)
                        } label: {
                            Image(systemName: "link")
                        }
                    }
                }
                .tint(colorScheme == .dark ? .orange : .brown)
            }
        }
        .groupBoxStyle(GlassifyGroupBoxStyle(lightStartPoint: .bottomLeading, lightEndPoint: .topTrailing, lightColor: .yellow))
        .padding(.horizontal, 4)
        .padding(.top)
        
        summary
    }
    
    @ViewBuilder
    private var summary: some View {
        GroupBox {
            DisclosureGroup {
                Rectangle().frame(width: 0, height: 0).padding(.top)
                GroupBox {
                    Text(basics.summary ?? "")
                        .font(.body)
                        .lineLimit(nil)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(1.5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .groupBoxStyle(GlassifyGroupBoxStyle(lightStartPoint: .bottomLeading, lightEndPoint: .topTrailing, lightColor: .yellow))
                .padding(4)
            } label: {
                Label("Summary", systemImage: "person")
                    .modifier(Heading())
            }
            .tint(colorScheme == .dark ? .orange : .brown)
        }
        .groupBoxStyle(GlassifyGroupBoxStyle(lightStartPoint: .bottomLeading, lightEndPoint: .topTrailing, lightColor: .yellow))
        .padding(.top)
        .padding(.horizontal, 4)
    }
    
    @ViewBuilder
    private var placeholderImage: some View {
        Image(systemName: "person.circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 54, height: 54)
    }
}

#Preview {
    BasicsView(basics: Basics(name: "Paul Leo", label: "Vice President", image: "", email: "paul@tapdigital.com", phone: "0567678356345", url: "https://s3.eu-west-2.amazonaws.com/www.tapdigital.com/assets/images/cdv_avatar.jpeg", summary: "Mobile Architect", location: Location(address: nil, postalCode: nil, city: nil, countryCode: "UK", region: "Durham"), profiles: []))
}
