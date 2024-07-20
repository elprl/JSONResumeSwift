//
//  Card.swift
//  TDCodeReview
//
//  Created by Paul Leo on 29/03/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import SwiftUI

struct Card: ViewModifier {
    @Binding var isSelected: Bool
    var bgColor: Color? = Color.blue
    var shadowColor: Color = Color(.sRGBLinear, white: 0, opacity: 0.33)

    func body(content: Content) -> some View {
        content
            .cornerRadius(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(bgColor ?? .blue)
                    .cornerRadius(8)
                    .shadow(color: shadowColor, radius: isSelected ? 8 : 5, x: 0, y: 0)
                    .shadow(color: Color.logoOrange.opacity(0.5), radius: isSelected ? 4 : 0, x: 0, y: 0)
            )
    }
}

#if DEBUG

#Preview {
    VStack(spacing: 40) {
        Text("Hello world")
            .padding()
            .modifier(Card(isSelected: .constant(false), bgColor: .blue))
        
        Text("Hello world")
            .padding()
            .modifier(Card(isSelected: .constant(false), bgColor: .orange))
        
        Text("Hello world")
            .padding()
            .modifier(Card(isSelected: .constant(true)))
    }
}

#endif
