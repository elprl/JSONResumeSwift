//
//  ResumeViewModel.swift
//  OpenCV
//
//  Created by Paul Leo on 28/06/2024.
//
import Foundation
import Combine
import SwiftUI
import SwiftData

final class ResumeViewModel: ObservableObject {
    let resumeUrl: String

    init(resumeUrl: String) {
        self.resumeUrl = resumeUrl
    }
}

