//
//  NotificationType.swift
//  MartinsApp
//
//  Created by Neil Jain on 12/15/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import Foundation

enum NotificationType: String, Codable {
    case booking = "1"
    case review = "2"
    case chat = "3"
}

struct BookingNotification: Codable {
    var user_job_id: Int?
    var company_name: String?
    var company_image: String?
    var description: String
}

extension BookingNotification {
    init?(payload: [AnyHashable: Any]) {
        guard let jobIdString = payload["user_job_id"] as? String, let jobId = Int(jobIdString) else { return nil }
        self.user_job_id = jobId
        self.company_name = payload["company_name"] as? String
        self.company_image = payload["company_image"] as? String
        self.description = payload["body"] as? String ?? "-"
    }
}

extension BookingNotification: CompanyDetailProvider {
    
    var profileImage: String? {
        company_image ?? "-"
    }
    
    var name: String {
        company_name ?? "-"
    }
}
