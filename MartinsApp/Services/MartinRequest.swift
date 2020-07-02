//
//  MartinRequest.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/6/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import Foundation
import Alamofire

/*
 "profile_image": "cc82fc9faa1551f94e0723c68205726c.jpeg",
 "UserWorkimage": [{"image":"image1.png"},{"image":"image2.png"},{"image":"image3.png"},{"image":"image4.png"}],
 "UserQualification": [{"image":"image1.png"},{"image":"image2.png"},{"image":"image3.png"},{"image":"image4.png"}]
 */

struct Login: Encodable {
    var email: String
    var password: String
}

struct ImageParameter: Codable, Equatable {
    var image: String
}

class Register: Encodable {
    var user_id: Int?
    var full_name: String?
    var email: String?
    var short_introduction: String?
    var password: String?
    var user_mobile: String?
    var service_type: String?
    var trade_skills: String?
    var working_area: String?
    var latitude: String?
    var longitude: String?
    var city: String?
    var insurance: String?
    var accreditations: String?
    var hourly_rate: String?
    var payment_rate: String?
    var travel_cost_per_mile: String?
    var device_type: Int?
    var device_token: String?
    var profile_image: String?
    var UserWorkimage: [ImageParameter]?
    var UserQualification: [ImageParameter]?
    var is_available: String?
}

struct SocialRegister: Encodable {
    var full_name: String
    var email: String
    var social_provider: SocialProvider
    var social_provider_id: String
    var device_type: Int
    var device_token: String?
}

enum SocialProvider: String, Codable {
    case facebook = "facebook"
    case google = "google"
}

struct UserId: Encodable {
    var user_id: Int
}

struct UserJobId: Encodable {
    var user_job_id: Int
}

struct UpdateJobRequest: Encodable {
    var user_job_id: Int
    var status: JobStatus
}

struct ForgotPassword: Encodable {
    var email: String
}

struct ChangePassword: Encodable {
    var email: String
    var password: String
}

struct TimeSlotRequest: Encodable {
    var user_id: Int
    var start_time: String
    var end_time: String
    var start_date: String
    var user_timeslot_id: Int?
    var user_timeslot_time_id: Int?
}

struct DateTimeSlotRequest: Encodable {
    var user_id: Int
    var slotdate: String
}

struct DeleteTimeSlotRequest: Encodable {
    var user_id: Int
    var user_timeslot_id: Int
    var user_timeslot_time_id: Int
}

struct LastMessageRequest: Encodable {
    var chatId: String
    var textmessage: String
}

struct JobStatusUpdate: Encodable {
    var user_id: Int
    var company_id: Int
    var status: JobStatus
}

struct ProposalAction: Encodable {
    var user_job_id: Int
    var status: ProposalActionType
}

enum ProposalActionType: String, Encodable {
    case accept = "1"
    case reject = "2"
}
