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

final class ResumeViewModel: ObservableObject, ResumeStatsServiceProtocol {    
    let resumeUrl: String
    let resume: Resume
    @Published var showAIChat: Bool = false

    init(resumeUrl: String, resume: Resume) {
        self.resumeUrl = resumeUrl
        self.resume = resume
    }
    
    var totalExperience: String {
        let timeItv = calculateTotalExperience()
        return formatDuration(timeItv)
    }
    
    // Helper function to create a readable string from the duration
    private func formatDuration(_ duration: TimeInterval) -> String {
        let totalDays = Int(duration / (24 * 3600))
        let years = totalDays / 365
        let months = (totalDays % 365) / 30
        
        return "\(years) yr, \(months) mo"
    }
    
    var averageJobDuration: String {
        let timeItv = calculateAverageJobDuration()
        return formatDuration(timeItv)
    }
    
    var totalJobs: String {
        return "\(calculateTotalJobs())"
    }
    
    var totalSkills: String {
        return "\(calculateTotalSkills())"
    }
    
    var totalCerts: String {
        return "\(calculateTotalCerts())"
    }
    
    var totalProjects: String {
        return "\(calculateTotalProjects())"
    }
}

