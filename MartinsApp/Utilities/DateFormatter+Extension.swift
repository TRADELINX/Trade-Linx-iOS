//
//  DateFormatter+Extension.swift
//  MartinsApp
//
//  Created by Neil Jain on 12/1/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import Foundation

extension DateFormatter {
    func userFacingTimeString(from date: Date) -> String {
        self.locale = .current
        self.dateFormat = "hh:mm a"
        return self.string(from: date)
    }
    
    func userFacingDateString(from date: Date) -> String {
        self.locale = .current
        self.dateFormat = "dd MMM yyyy HH:mm a"
        return self.string(from: date)
    }
    
    func fixedTimeString(from date: Date) -> String {
        self.locale = Locale(identifier: "en_US_POSIX")
        self.dateFormat = "HH:mm"
        return self.string(from: date)
    }
    
    func timeFromFixedLocale(from string: String) -> Date? {
        self.locale = Locale(identifier: "en_US_POSIX")
        self.dateFormat = "HH:mm"
        return self.date(from: string)
    }
    
    func timeForUserFacingLocale(from string: String) -> Date? {
        self.locale = .current
        self.dateFormat = "hh:mm a"
        return self.date(from: string)
    }
    
    func date(fromRemote string: String) -> Date? {
        self.locale = Locale(identifier: "en_US_POSIX")
        self.timeZone = TimeZone(abbreviation: "UTC")
        self.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return self.date(from: string)
    }
}
