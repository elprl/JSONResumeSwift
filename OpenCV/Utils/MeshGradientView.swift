//
//  MeshGradientView.swift
//  OpenCV
//
//  Created by Paul Leo on 29/06/2024.
//
import SwiftUI

struct MeshGradientView: View {
    
    var body: some View {
        ZStack {
            if #available(iOS 18.0, *) {
                MeshGradient(width: 3, height: 3, points: [
                    .init(0, 0), .init(0.5, 0), .init(1, 0),
                    .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
                    .init(0, 1), .init(0.5, 1), .init(1, 1)
                ], colors: [
                    .logoRed, .logoGreen, .indigo,
                    .logoOrange, .logoGreen, .logoBlue,
                    .yellow, .yellow.opacity(0.7), .mint
                ], background: .black.opacity(0.7))
                .ignoresSafeArea()
            } else {
                // Fallback on earlier versions
                LinearGradient(colors: [
                    .mint, .logoGreen,
                    .logoOrange, .yellow,
                ], startPoint: .topTrailing, endPoint: .bottomLeading)
                .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    MeshGradientView()
}
