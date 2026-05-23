//
//  SwiftUI+Utils.swift
//  OpenCV
//
//  Created by Paul Leo on 30/06/2024.
//

import SwiftUI

extension View {
    
    func openLink(url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url)
        }
    }
    
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }

    @ViewBuilder
    func glassyEffect<S: Shape>(
        _ glass: Glass = .regular,
        in shape: S = DefaultGlassEffectShape()
    ) -> some View {
        if ProcessInfo.processInfo.isiOSAppOnMac || ProcessInfo.processInfo.isMacCatalystApp {
            self.background(.ultraThinMaterial, in: shape)
        } else {
            self.glassEffect(glass, in: shape)
        }
    }
    
    func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> TupleView<(Self?, Content?)> {
        if conditional {
            return TupleView((nil, content(self)))
        } else {
            return TupleView((self, nil))
        }
    }
}

enum LoadingViewState<Result> {
    case appeared
    case loading
    case loaded(Result)
    case empty(String)
    case error(String)
}

struct Heading: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .fontWeight(.bold)
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct RoundButton: View {
    let action: () -> Void
    let imageSize: CGFloat
    let icon: String
    let bgColor: Color
    @Binding var isLoading: Bool

    var body: some View {
        Button {
            self.action()
        } label: {
            ZStack {
                Circle()
                    .foregroundColor(self.bgColor)
                    .frame(width: imageSize, height: imageSize, alignment: .center)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .frame(width: floor(imageSize/2), height: floor(imageSize/2), alignment: .center)
                } else {
                    Image(systemName: self.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                        .frame(width: floor(imageSize/2), height: floor(imageSize/2), alignment: .trailing)
                }
            }
        }
        .contentShape(Circle())
    }
}

struct ToggleButton: View {
    @State var title: String
    @Binding var isOn: Bool
    @State var onColor: Color = .black
    @State var offColor: Color = .gray.opacity(0.5)
    @State var onTextColor: Color = .white
    @State var offTextColor: Color = .white
    let action: () -> Void

    var body: some View {
        Button {
            self.isOn.toggle()
            self.action()
        } label: {
            Text(self.title)
                .font(.system(size: 14))
                .foregroundColor(isOn ? onTextColor : offTextColor)
                .padding(.horizontal)
                .padding(.vertical, 2)
        }
        .buttonStyle(ToggleButtonStyle(bgColor: isOn ? onColor : offColor, fgColor: isOn ? onTextColor : offTextColor))
    }
}

struct ToggleButtonStyle: ButtonStyle {
    let bgColor: Color
    let fgColor: Color
    let borderColor: Color

    init(bgColor: Color = .white, fgColor: Color = .black, borderColor: Color = .clear) {
        self.bgColor = bgColor
        self.fgColor = fgColor
        self.borderColor = borderColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(fgColor)
            .background(
                ZStack {
                    bgColor
                    Capsule()
                        .stroke(borderColor, lineWidth: 3)
                }
            )
            .contentShape(Capsule())
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.05 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
