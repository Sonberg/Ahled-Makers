//
//  TimeAgo.swift
//  geostigen
//
//  Created by Per Sonberg on 2017-01-06.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import Foundation

public func timeAgoSince(_ date: Date) -> String {
    
    let calendar = Calendar.current
    let now = Date()
    let unitFlags: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfYear, .month, .year]
    let components = (calendar as NSCalendar).components(unitFlags, from: date, to: now, options: [])
    
    if let year = components.year, year >= 2 {
        return "\(year) år sedan"
    }
    
    if let year = components.year, year >= 1 {
        return "Förra året"
    }
    
    if let month = components.month, month >= 2 {
        return "\(month) månader sedan"
    }
    
    if let month = components.month, month >= 1 {
        return "Förra månaden"
    }
    
    if let week = components.weekOfYear, week >= 2 {
        return "\(week) veckor sedan"
    }
    
    if let week = components.weekOfYear, week >= 1 {
        return "Förra veckan"
    }
    
    if let day = components.day, day >= 2 {
        return "\(day) dagar sedan"
    }
    
    if let day = components.day, day >= 1 {
        return "Igår"
    }
    
    if let hour = components.hour, hour >= 2 {
        return "\(hour) timmar sedan"
    }
    
    if let hour = components.hour, hour >= 1 {
        return "En timme sedan"
    }
    
    if let minute = components.minute, minute >= 2 {
        return "\(minute) minuter sedan"
    }
    
    if let minute = components.minute, minute >= 1 {
        return "En minut sedan"
    }
    
    if let second = components.second, second >= 3 {
        return "\(second) sekunder sedan"
    }
    
    return "Nu"
    
}
