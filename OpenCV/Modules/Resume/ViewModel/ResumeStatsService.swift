//
//  ResumeStatsService.swift
//  OpenCV
//
//  Created by Paul Leo on 10/08/2024.
//

import Foundation

protocol ResumeStatsServiceProtocol {
    var resume: Resume { get }
    func calculateTotalExperience() -> TimeInterval
    func calculateAverageJobDuration() -> TimeInterval
    func calculateTotalProjects() -> Int
    func calculateTotalSkills() -> Int
    func calculateTotalCerts() -> Int
    func calculateTotalJobs() -> Int
}

struct Job {
    let startDate: Date
    var endDate: Date
}

extension ResumeStatsServiceProtocol {
    func calculateTotalExperience() -> TimeInterval {
        guard let works = resume.work else { return 0 }
        // convert Work to Jobs
        let jobs: [Job] = works.compactMap { work in
            guard let startDate = work.startDateTime else { return nil }
            if let endDate = work.endDateTime {
                return Job(startDate: startDate, endDate: endDate)
            } else {
                return Job(startDate: startDate, endDate: Date.now)
            }
        }
        
        // Sort the jobs by start date
        let sortedJobs = jobs.sorted { $0.startDate < $1.startDate }
        
        var mergedRanges: [Job] = []
        
        for job in sortedJobs {
            if let lastJob = mergedRanges.last, lastJob.endDate >= job.startDate {
                // Overlap found, merge the current job with the last one
                mergedRanges[mergedRanges.count - 1].endDate = max(lastJob.endDate, job.endDate)
            } else {
                // No overlap, add the current job to merged ranges
                mergedRanges.append(job)
            }
        }
        
        // Calculate total duration from merged ranges
        let totalDuration = mergedRanges.reduce(0) { sum, job in
            sum + job.endDate.timeIntervalSince(job.startDate)
        }
        
        return totalDuration
    }
    
    func calculateAverageJobDuration() -> TimeInterval {
        guard let works = resume.work else { return 0 }
        // convert Work to Jobs
        let jobs: [Job] = works.compactMap { work in
            guard let startDate = work.startDateTime else { return nil }
            if let endDate = work.endDateTime {
                return Job(startDate: startDate, endDate: endDate)
            } else {
                return Job(startDate: startDate, endDate: Date.now)
            }
        }
        
        let total = jobs.reduce(0) { sum, job in
            return sum + job.endDate.timeIntervalSince(job.startDate)
        }
        
        return total / Double(jobs.count)
    }
    
    func calculateTotalProjects() -> Int {
        return resume.projects?.count ?? 0
    }
    
    func calculateTotalSkills() -> Int {
        return resume.skills?.count ?? 0
    }
    
    func calculateTotalCerts() -> Int {
        return resume.certificates?.count ?? 0
    }
    
    func calculateTotalJobs() -> Int {
        return resume.work?.count ?? 0
    }
}
