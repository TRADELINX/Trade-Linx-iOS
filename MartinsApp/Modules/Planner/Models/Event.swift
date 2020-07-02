//
//  Event.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/24/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

struct Event {
    var id: Int
    var dateId: Int
    var date: String
    var description: String
    var startTime: String
    var endTime: String
    var color: UIColor
}

extension Event {
    static var dataSource: [Event] {
        return [
            Event(id: 13, dateId: 1, date: "9 Apr 2019", description: "Service Type: Air-Conditioning Engineer", startTime: "09:30 am", endTime: "11:30 am", color: #colorLiteral(red: 0.9936838746, green: 0.7903504968, blue: 0.3803099692, alpha: 1)),
            Event(id: 2, dateId: 1,  date: "12 Apr 2019", description: "Service Type: Paste Control", startTime: "12:30 am", endTime: "01:30 pm", color: #colorLiteral(red: 0.3768250644, green: 0.4824897051, blue: 0.997379005, alpha: 1))
        ]
    }
}

extension Event {
    func formattedDate(using formatter: DateFormatter) -> Date? {
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.date(from: date)
    }
    
    func formattedStartTime(using formatter: DateFormatter) -> Date? {
        formatter.dateFormat = "hh:mm a"
        return formatter.date(from: startTime)
    }
    
    func formattedEndTime(using formatter: DateFormatter) -> Date? {
        formatter.dateFormat = "hh:mm a"
        return formatter.date(from: endTime)
    }
}
