//
//  Date+Extensions.swift
//  MartinsApp
//
//  Created by Neil Jain on 7/5/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import Foundation

extension Date {
    var removingTimeComponent: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    func formattedElapsedTime(dateFormatter: DateFormatter, formatter: DateComponentsFormatter) -> String? {
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.calendar = Calendar.autoupdatingCurrent
        
        var dateString: String?
        let interval = Calendar.current.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute, .second], from: self, to: Date())
        if let year = interval.year, year > 0 {
            formatter.allowedUnits = .year
        } else if let month = interval.month, month > 0 {
            formatter.allowedUnits = .month
        } else if let week = interval.weekOfYear, week > 0 {
            formatter.allowedUnits = .weekOfMonth
        } else if let day = interval.day, day > 0 {
            formatter.allowedUnits = .day
        } else if let hour = interval.hour, hour > 0 {
            formatter.allowedUnits = .hour
        } else if let minute = interval.minute, minute > 0 {
            formatter.allowedUnits = .minute
        } else if let seconds = interval.second, seconds > 0 {
            formatter.allowedUnits = .second
        } else {
            dateFormatter.locale = Calendar.autoupdatingCurrent.locale
            dateFormatter.dateStyle = .medium
            dateFormatter.doesRelativeDateFormatting = true
            
            dateString = dateFormatter.string(from: self)
        }
        
        if dateString == nil {
            dateString = formatter.string(from: self, to: Date())
        }
        
        return dateString?.appending(" ago")
    }
}
