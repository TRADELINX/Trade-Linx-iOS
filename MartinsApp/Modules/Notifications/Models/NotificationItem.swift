//
//  NotificationItem.swift
//  MartinsApp
//
//  Created by Neil Jain on 12/15/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import Foundation

struct NotificationItem: Codable {
    var notification_id: Int?
    var company_id: Int?
    var user_id: Int?
    var user_job_id: Int?
    var user_review_id: Int?
    var title: String?
    var message: String?
    var booking_date: String?
    var notification_type: NotificationType?
    var status: String?
    var created_at: String?
    var updated_at: String?
    var id: Int?
    var full_name: String?
    var profile_image: String?
}

extension NotificationItem {
    func createdDate(dateFormatter: DateFormatter) -> String? {
        guard let createdDateString = self.created_at else { return nil }
        guard let date = dateFormatter.date(fromRemote: createdDateString) else { return nil }
        return dateFormatter.userFacingDateString(from: date)
    }
}

extension NotificationItem: CompanyDetailProvider {
    
    var profileImage: String? {
        self.profile_image
    }
    
    var name: String {
        self.full_name ?? "-"
    }
    
    var description: String {
        self.message ?? "-"
    }
}
