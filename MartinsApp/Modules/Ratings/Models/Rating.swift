//
//  Rating.swift
//  MartinsApp
//
//  Created by Neil Jain on 12/7/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import Foundation

struct Rating: Codable {
    var user_review_id: Int?
    var user_job_id: Int?
    var company_id: Int?
    var user_id: Int?
    var rating: String?
    var time_keeping: Int?
    var workman_ship: Int?
    var communiation: Int?
    var value: Int?
    var commnet: String?
    var status: String?
    var full_name: String?
    var email: String?
    var user_mobile: String?
    var profile_image: String?
    var created_at: String?
    var updated_at: String?
}

extension Rating {
    func createdAgo(dateFormatter: DateFormatter, formatter: DateComponentsFormatter) -> String? {
        guard let createAtString = self.created_at else { return nil }
        return dateFormatter
            .date(fromRemote: createAtString)?
            .formattedElapsedTime(dateFormatter: dateFormatter, formatter: formatter)
    }
}
