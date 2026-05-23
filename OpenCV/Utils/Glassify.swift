//
//  Glassify.swift
//  PowervaultScheduler
//
//  Created by Paul Leo on 24/09/2024.
//

import SwiftUI

protocol GlassifiableViewModifier {
    var cornerRadius: CGFloat { get }
    var lightStartPoint: UnitPoint { get }
    var lightEndPoint: UnitPoint { get }
    var lightColor: Color { get }
}

extension GlassifiableViewModifier {
    var shadowOffsetX: CGFloat {
        switch lightStartPoint {
        case .topLeading, .leading, .bottomLeading:
            return 2   // Light is from left to right
        case .topTrailing, .trailing, .bottomTrailing:
            return -2  // Light is from right to left
        default:
            return 0   // No horizontal shift for top/bottom light
        }
    }
    
    var shadowOffsetY: CGFloat {
        switch lightStartPoint {
        case .topLeading, .top, .topTrailing:
            return 2    // Light is from top to bottom
        case .bottomLeading, .bottom, .bottomTrailing:
            return -2   // Light is from bottom to top
        default:
            return 0    // No vertical shift for left/right light
        }
    }
}

struct Glassify: GlassifiableViewModifier, ViewModifier {
    let cornerRadius: CGFloat
    let lightStartPoint: UnitPoint
    let lightEndPoint: UnitPoint
    let lightColor: Color
    var gradientColors: [Color] {
        [
            lightColor.opacity(0.7),
            lightColor.opacity(0.1)
        ]
    }
    
    init(_ cornerRadius: CGFloat = 8,
         lightStartPoint: UnitPoint = .topTrailing,
         lightEndPoint: UnitPoint = .bottomLeading,
         lightColor: Color = .white) {
        self.cornerRadius = cornerRadius
        self.lightStartPoint = lightStartPoint
        self.lightEndPoint = lightEndPoint
        self.lightColor = lightColor
    }
    
    func body(content: Content) -> some View {
        content
            .glassyEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(LinearGradient(colors: gradientColors,
                                           startPoint: lightStartPoint,
                                           endPoint: lightEndPoint))
            }
    }
}

struct GlassifyGroupBoxStyle: GlassifiableViewModifier, GroupBoxStyle {
    let cornerRadius: CGFloat
    let lightStartPoint: UnitPoint
    let lightEndPoint: UnitPoint
    let lightColor: Color
    var gradientColors: [Color] {
        [
            lightColor.opacity(0.7),
            lightColor.opacity(0.1)
        ]
    }
    
    init(_ cornerRadius: CGFloat = 8,
         lightStartPoint: UnitPoint = .topTrailing,
         lightEndPoint: UnitPoint = .bottomLeading,
         lightColor: Color = .white) {
        self.cornerRadius = cornerRadius
        self.lightStartPoint = lightStartPoint
        self.lightEndPoint = lightEndPoint
        self.lightColor = lightColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
        }
        .padding()
        .glassyEffect(.clear, in: RoundedRectangle(cornerRadius: cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(LinearGradient(colors: gradientColors,
                                       startPoint: lightStartPoint,
                                       endPoint: lightEndPoint))
        }
    }
}

extension View {
    func glassMorphed(cornerRadius: CGFloat = 8,
                      lightStartPoint: UnitPoint = .topTrailing,
                      lightEndPoint: UnitPoint = .bottomLeading,
                      lightColor: Color = .white) -> some View {
        modifier(Glassify(cornerRadius,
                          lightStartPoint: lightStartPoint,
                          lightEndPoint: lightEndPoint,
                          lightColor: lightColor))
    }
}
