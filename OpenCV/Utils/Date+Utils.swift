//
//  Date+Utils.swift
//  TDCodeReview
//
//  Created by Paul Leo on 14/03/2022.
//  Copyright © 2022 tapdigital Ltd. All rights reserved.
//

import Foundation

extension Date {
    func toFullDateFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM dd"
        return dateFormatter.string(from: self)
    }
    
    func toShortDateFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.string(from: self)
    }
    
    func toFullDateTimeFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        return dateFormatter.string(from: self)
    }
    
    func toWeekDayFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter.string(from: self)
    }
    
    func toTimeOnlyFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
    
    func toDayOnlyFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: self)
    }
    
    func toFullChatDateTimeFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy HH:mm"
        return dateFormatter.string(from: self)
    }
    
    var yearsFromNow: Int {
        return Calendar.current.dateComponents([.year], from: self, to: Date()).year!
    }
    
    var monthsFromNow: Int {
        return Calendar.current.dateComponents([.month], from: self, to: Date()).month!
    }
    
    var weeksFromNow: Int {
        return Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear!
    }
    
    var daysFromNow: Int {
        return Calendar.current.dateComponents([.day], from: self, to: Date()).day!
    }
    
    var isInYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    var hoursFromNow: Int {
        return Calendar.current.dateComponents([.hour], from: self, to: Date()).hour!
    }
    
    var minutesFromNow: Int {
        return Calendar.current.dateComponents([.minute], from: self, to: Date()).minute!
    }
    
    var secondsFromNow: Int {
        return Calendar.current.dateComponents([.second], from: self, to: Date()).second!
    }
    
    var relativeTimeShort: String {
        if yearsFromNow > 0 { return "\(yearsFromNow)y ago" }
        if monthsFromNow > 0 { return "\(monthsFromNow)mo ago" }
        if weeksFromNow > 0 { return "\(weeksFromNow)w ago" }
        if isInYesterday { return "Yesterday" }
        if daysFromNow > 0 { return "\(daysFromNow)d ago" }
        if hoursFromNow > 0 { return "\(hoursFromNow)h ago" }
        if minutesFromNow > 0 { return "\(minutesFromNow)mi ago" }
        if secondsFromNow > 0 { return secondsFromNow < 15 ? "Just now"
            : "\(secondsFromNow)s ago" }
        return ""
    }
    
    var relativeTime: String {
        if yearsFromNow > 0 { return "\(yearsFromNow) year" + (yearsFromNow > 1 ? "s" : "") + " ago" }
        if monthsFromNow > 0 { return "\(monthsFromNow) month" + (monthsFromNow > 1 ? "s" : "") + " ago" }
        if weeksFromNow > 0 { return "\(weeksFromNow) week" + (weeksFromNow > 1 ? "s" : "") + " ago" }
        if isInYesterday { return "Yesterday" }
        if daysFromNow > 0 { return "\(daysFromNow) day" + (daysFromNow > 1 ? "s" : "") + " ago" }
        if hoursFromNow > 0 { return "\(hoursFromNow) hour" + (hoursFromNow > 1 ? "s" : "") + " ago" }
        if minutesFromNow > 0 { return "\(minutesFromNow) minute" + (minutesFromNow > 1 ? "s" : "") + " ago" }
        if secondsFromNow > 0 { return secondsFromNow < 15 ? "Just now"
            : "\(secondsFromNow) second" + (secondsFromNow > 1 ? "s" : "") + " ago" }
        return "Just now"
    }
    
    var relativeTimeFull: String {
        if yearsFromNow > 0 { return "\(yearsFromNow) year" + (yearsFromNow > 1 ? "s" : "") + " ago" }
        if monthsFromNow > 0 { return "\(monthsFromNow) month" + (monthsFromNow > 1 ? "s" : "") + " ago" }
        if weeksFromNow > 0 { return "\(weeksFromNow) week" + (weeksFromNow > 1 ? "s" : "") + " ago" }
        if isInYesterday { return "Yesterday" }
        if daysFromNow > 0 { return "\(daysFromNow) day" + (daysFromNow > 1 ? "s" : "") + " ago" }
        if hoursFromNow > 0 { return "\(hoursFromNow) hour" + (hoursFromNow > 1 ? "s" : "") + " ago" }
        if minutesFromNow > 0 { return "\(minutesFromNow) minute" + (minutesFromNow > 1 ? "s" : "") + " ago" }
        if secondsFromNow > 0 { return secondsFromNow < 15 ? "Just now"
            : "\(secondsFromNow) second" + (secondsFromNow > 1 ? "s" : "") + " ago" }
        return ""
    }
    
    var messageTime: String {
        if yearsFromNow > 0 { return toFullChatDateTimeFormat() }
        if monthsFromNow > 0 { return toFullChatDateTimeFormat() }
        if weeksFromNow > 0 { return toFullChatDateTimeFormat() }
        if isInYesterday { return "Yesterday \(toTimeOnlyFormat())" }
        if daysFromNow > 0 { return "\(toDayOnlyFormat()) \(toTimeOnlyFormat())" }
        if hoursFromNow > 0 { return toTimeOnlyFormat() }
        if minutesFromNow > 0 { return toTimeOnlyFormat() }
        if secondsFromNow > 0 { return toTimeOnlyFormat() }
        return toTimeOnlyFormat()
    }
    
    func startOfWeek() -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Use this line if you want Monday to be the start of the week
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else {
            fatalError("Date not found")
        }
        return startOfWeek
    }
    
    func startOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        guard let startOfMonth = calendar.date(from: components) else {
            fatalError("Date not found")
        }
        return startOfMonth
    }
    
    func startOfYear() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self)
        guard let startOfYear = calendar.date(from: components) else {
            fatalError("Date not found")
        }
        return startOfYear
    }
}

extension DateFormatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
}
