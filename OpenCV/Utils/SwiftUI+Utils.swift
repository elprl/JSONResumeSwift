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
