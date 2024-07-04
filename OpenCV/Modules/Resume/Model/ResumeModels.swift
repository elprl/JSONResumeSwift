//
//  Resume.swift
//  OpenCV
//
//  Created by Paul Leo on 28/06/2024.
//
import Foundation
import SwiftUI

/// Represents a resume with various sections such as basics, work, education, etc.
struct Resume: Codable {
    /// Link to the version of the schema that can validate the resume.
    let schema: String?
    let basics: Basics
    let work: [Work]?
    let volunteer: [Volunteer]?
    let education: [Education]?
    let awards: [Award]?
    let certificates: [Certificate]?
    let publications: [Publication]?
    let skills: [Skill]?
    let languages: [Language]?
    let interests: [Interest]?
    let references: [Reference]?
    let projects: [Project]?
    let meta: Meta?
}

extension Resume: Hashable {
    static func == (lhs: Resume, rhs: Resume) -> Bool {
        return lhs.basics.name == rhs.basics.name
    }
    
    var hashValue: Int {
        return basics.name.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(basics.name)
    }
}

/// Contains basic information about the individual.
struct Basics: Codable {
    /// Full name of the individual.
    let name: String
    /// Professional label or title, e.g., Web Developer.
    let label: String?
    /// URL to an image in JPEG or PNG format.
    let image: String?
    /// Email address, e.g., thomas@gmail.com.
    let email: String?
    /// Phone number in any format, e.g., 712-117-2923.
    let phone: String?
    /// URL to personal website, e.g., personal homepage.
    let url: String?
    /// Short 2-3 sentence biography about the individual.
    let summary: String?
    let location: Location?
    /// Social networks the individual participates in.
    let profiles: [Profile]?
}

extension Basics: Identifiable {
    var id: String {
        return name
    }
}

/// Represents the location details.
struct Location: Codable {
    /// Address with multiple lines separated by \n.
    let address: String?
    let postalCode: String?
    let city: String?
    /// Country code as per ISO-3166-1 ALPHA-2, e.g., US, AU, IN.
    let countryCode: String?
    /// General region where the individual lives, e.g., US state or province.
    let region: String?
}

//extension Location: Identifiable {
//    var id: String {
//        return countryCode + region
//    }
//}

/// Represents a social network profile.
struct Profile: Codable {
    /// Name of the network, e.g., Facebook or Twitter.
    let network: String
    /// Username on the network, e.g., neutralthoughts.
    let username: String
    /// URL to the profile, e.g., http://twitter.example.com/neutralthoughts.
    let url: String
}

extension Profile: Identifiable {
    var id: String {
        return network + username + url
    }
}

/// Represents a work experience.
struct Work: Codable, PeriodProtocol {
    /// Name of the company, e.g., Facebook.
    let name: String
    /// Location of the company, e.g., Menlo Park, CA.
    let location: String?
    /// Description of the company, e.g., Social Media Company.
    let description: String?
    /// Position held, e.g., Software Engineer.
    let position: String?
    /// URL to the company, e.g., http://facebook.example.com.
    let url: String?
    /// Start date of the work experience in ISO 8601 format (see schema.json).
    let startDate: String?
    /// End date of the work experience in ISO 8601 format (see schema.json).
    let endDate: String?
    /// Overview of responsibilities at the company.
    let summary: String?
    /// Multiple accomplishments.
    let highlights: [String]?
}

extension Work: Identifiable, Hashable {
    var id: String {
        return name + (summary ?? "") + (startDate ?? "")
    }
}

/// Represents a volunteer experience.
struct Volunteer: Codable, PeriodProtocol, Hashable {
    /// Name of the organization, e.g., Facebook.
    let organization: String
    /// Position held, e.g., Software Engineer.
    let position: String?
    /// URL to the organization, e.g., http://facebook.example.com.
    let url: String?
    /// Start date of the volunteer experience in ISO 8601 format (see schema.json).
    let startDate: String?
    /// End date of the volunteer experience in ISO 8601 format (see schema.json).
    let endDate: String?
    /// Overview of responsibilities at the organization.
    let summary: String?
    /// Accomplishments and achievements.
    let highlights: [String]?
}

extension Volunteer: Identifiable {
    var id: String {
        return organization + (position ?? "") + (startDate ?? "")
    }
}

/// Represents an educational background.
struct Education: Codable, PeriodProtocol {
    /// Name of the institution, e.g., Massachusetts Institute of Technology.
    let institution: String
    /// URL to the institution, e.g., http://facebook.example.com.
    let url: String?
    /// Area of study, e.g., Arts.
    let area: String
    /// Type of study, e.g., Bachelor.
    let studyType: String?
    /// Start date of the education in ISO 8601 format (see schema.json).
    let startDate: String?
    /// End date of the education in ISO 8601 format (see schema.json).
    let endDate: String?
    /// Grade point average, e.g., 3.67/4.0.
    let score: String?
    /// Notable courses/subjects.
    let courses: [String]?
}

extension Education: Identifiable {
    var id: String {
        return institution + area + (startDate ?? "")
    }
}

/// Represents an award received.
struct Award: Codable {
    /// Title of the award, e.g., One of the 100 greatest minds of the century.
    let title: String
    /// Date of the award in ISO 8601 format (see schema.json).
    let date: String?
    /// Awarder, e.g., Time Magazine.
    let awarder: String?
    /// Summary of the award, e.g., Received for my work with Quantum Physics.
    let summary: String?
}

extension Award: Identifiable {
    var id: String {
        return title
    }
}

/// Represents a certificate received.
struct Certificate: Codable {
    /// Name of the certificate, e.g., Certified Kubernetes Administrator.
    let name: String
    /// Date of the certificate in ISO 8601 format (see schema.json).
    let date: String?
    /// URL to the certificate, e.g., http://example.com.
    let url: String?
    /// Issuer of the certificate, e.g., CNCF.
    let issuer: String?
}

extension Certificate: Identifiable {
    var id: String {
        return name
    }
}

/// Represents a publication.
struct Publication: Codable {
    /// Name of the publication, e.g., The World Wide Web.
    let name: String
    /// Publisher, e.g., IEEE, Computer Magazine.
    let publisher: String?
    /// Release date of the publication in ISO 8601 format (see schema.json).
    let releaseDate: String?
    /// URL to the publication, e.g., http://www.computer.org.example.com/csdl/mags/co/1996/10/rx069-abs.html.
    let url: String?
    /// Short summary of the publication.
    let summary: String?
}

extension Publication: Identifiable {
    var id: String {
        return name
    }
}

/// Represents a professional skill.
struct Skill: Codable {
    /// Name of the skill, e.g., Web Development.
    let name: String
    /// Level of expertise, e.g., Master.
    let level: String?
    /// Keywords pertaining to this skill, e.g., HTML.
    let keywords: [String]?
}

extension Skill: Identifiable {
    var id: String {
        return name
    }
    
    var skillLevel: LocalizedStringKey {
        guard let level else { return "" }
        switch level.lowercased() {
        case "beginner": return "\(Image(systemName: "star"))"
        case "intermediate": return "\(Image(systemName: "star"))\(Image(systemName: "star"))"
        case "advanced": return "\(Image(systemName: "star"))\(Image(systemName: "star"))\(Image(systemName: "star"))"
        case "expert", "master": return "\(Image(systemName: "star"))\(Image(systemName: "star"))\(Image(systemName: "star"))\(Image(systemName: "star"))"
        default:
            return "\(level)"
        }
    }
}

/// Represents a language spoken.
struct Language: Codable {
    /// Name of the language, e.g., English, Spanish.
    let language: String
    /// Fluency level, e.g., Fluent, Beginner.
    let fluency: String
}

extension Language: Identifiable {
    var id: String {
        return language
    }
}

/// Represents an interest.
struct Interest: Codable, Hashable {
    /// Name of the interest, e.g., Philosophy.
    let name: String
    /// Keywords related to the interest, e.g., Friedrich Nietzsche.
    let keywords: [String]?
}

extension Interest: Identifiable {
    var id: String {
        return name
    }
}

/// Represents a reference.
struct Reference: Codable {
    /// Name of the reference, e.g., Timothy Cook.
    let name: String
    /// Reference description, e.g., Joe blogs was a great employee, who turned up to work at least once a week. He exceeded my expectations when it came to doing nothing.
    let reference: String
}

extension Reference: Identifiable {
    var id: String {
        return name
    }
}

/// Represents a project.
struct Project: Codable, PeriodProtocol, Hashable {
    /// Name of the project, e.g., The World Wide Web.
    let name: String
    /// Short summary of the project.
    let description: String?
    /// Multiple features or highlights of the project.
    let highlights: [String]?
    /// Special elements involved in the project.
    let keywords: [String]?
    /// Start date of the project in ISO 8601 format (see schema.json).
    let startDate: String?
    /// End date of the project in ISO 8601 format (see schema.json).
    let endDate: String?
    /// URL to the project, e.g., http://www.computer.org/csdl/mags/co/1996/10/rx069-abs.html.
    let url: String?
    /// Roles played in the project or company.
    let roles: [String]?
    /// Relevant company/entity affiliations, e.g., 'greenpeace', 'corporationXYZ'.
    let entity: String?
    /// Type of project, e.g., 'volunteering', 'presentation', 'talk', 'application', 'conference'.
    let type: String?
}

extension Project: Identifiable {
    var id: String {
        return name
    }
}

/// Represents metadata about the resume.
struct Meta: Codable {
    /// URL to the latest version of this document.
    let canonical: String?
    /// Version field following semver, e.g., v1.0.0.
    let version: String?
    /// Last modified date in ISO 8601 format.
    let lastModified: String?
    /// theme
    let theme: String?
}

//extension Meta: Identifiable {
//    var id: String {
//        return version
//    }
//}

protocol PeriodProtocol {
    var startDate: String? { get }
    var endDate: String? { get }
}
 
extension PeriodProtocol {
    var dates: String {
        guard let start = formatDate(from: startDate) else {
            return ""
        }
        guard let end = formatDate(from: endDate) else {
            return start + " - Present"
        }
        if start == end {
            return start
        }
        return start + " - " + end
    }
    
    func date(from isoDateString: String) -> Date? {
        let pattern = /^(\d{4})(?:-(\d{2}))?(?:-(\d{2}))?$/
        guard let matches = try? pattern.wholeMatch(in: isoDateString) else { return nil }
        
        let year: Int? = Int(matches.1)
        let month: Int? = matches.2.flatMap( { Int($0) } )
        let day: Int? = matches.3.flatMap( { Int($0) } )
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month ?? 1 // Default to January if month is not specified
        dateComponents.day = day ?? 1 // Default to 1st if day is not specified
        
        return Calendar.current.date(from: dateComponents)
    }
    
    func formatDate(from isoDateString: String?) -> String? {
        guard let isoDateString else { return nil }
        let pattern = /^(\d{4})(?:-(\d{2}))?(?:-(\d{2}))?$/
        guard let matches = try? pattern.wholeMatch(in: isoDateString) else { return nil }
        
        let year: Int? = Int(matches.1)
        let month: Int? = matches.2.flatMap( { Int($0) } )
        let day: Int? = matches.3.flatMap( { Int($0) } )
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month ?? 1 // Default to January if month is not specified
        dateComponents.day = day ?? 1 // Default to 1st if day is not specified
        let date = Calendar.current.date(from: dateComponents)
        
        if day != nil {
            return date?.formatted(Date.FormatStyle().year().month().day())
        }

        if month != nil {
            return date?.formatted(Date.FormatStyle().year().month())
        }
        
        if year != nil {
            return date?.formatted(Date.FormatStyle().year())
        }
        
        return "Present"
    }
}
