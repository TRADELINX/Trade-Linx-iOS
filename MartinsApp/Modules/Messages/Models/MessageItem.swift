//
//  MessageItem.swift
//  MartinsApp
//
//  Created by Neil Jain on 9/16/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import Foundation

struct MessageItem: Decodable {
    var id: Int
    var message: String?
    var user_id1_read: Int?
    var user_id2_read: Int?
    var created_at: String?
    var updated_at: String?
    var full_name: String?
    /// userId
    var user_id: Int
    /// receptorId
    var company_id: Int
    var profile_image: String?
}

extension MessageItem {
    init?(payload: [AnyHashable: Any], userId: Int) {
        guard let id = payload["chatId"] as? String,
            let companyId = payload["companyId"] as? String,
            let validChatId = Int(id),
            let validCompanyId = Int(companyId)
        else { return nil }
        
        self.id = validChatId
        self.user_id = userId
        self.company_id = validCompanyId
        self.profile_image = payload["companyImage"] as? String
        self.full_name = payload["companyName"] as? String
    }
}

extension MessageItem {
    func formattedTimeString(using dateFormatter: DateFormatter) -> String? {
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let updatedDate = dateFormatter.date(from: self.updated_at ?? "") {
            dateFormatter.locale = .current
            dateFormatter.dateFormat = "dd-MMM-yyyy hh:mm a"
            return dateFormatter.string(from: updatedDate)
        }
        return nil
    }
}

extension MessageItem: CustomStringConvertible {
    var description: String {
        return """
        id: \(self.id)
        message: \(self.message ?? "--NO-Message--")
        fullName: \(self.full_name ?? "--NO-FULLNAME--")
        """
    }
}
