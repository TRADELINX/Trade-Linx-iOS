//
//  User.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/6/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import Foundation
import UIKit

/*
 {
 "status": 1,
 "message": "Login Success",
 "data": {
    "id": 81,
    "full_name": "ABC",
    "email": "abc@daymail.life",
    "email_verified_at": "2019-06-18 15:53:45",
    "user_mobile": "",
    "social_provider_id": "",
    "social_provider": "normal",
    "service_type": "Massage at Home",
    "trade_skills": "Trade 3, Trade 4",
    "working_area": "Market Research",
    "insurance": "Yes",
    "accreditations": "Definetly",
    "hourly_rate": "$ 25000",
    "gender": "",
    "profile_image": "http://139.59.35.213/martin/public/uploads",
    "dob": "",
    "education": "",
    "work": "",
    "short_introduction": "",
    "device_type": 1,
    "device_token": "",
    "created_at": "2019-06-18 15:53:14",
    "updated_at": "2019-06-18 15:53:45",
    "UserWorkimages": [],
    "UserQualifications": []
 }
 }
 */

struct User: Codable {
    var id: Int
    var fullName: String?
    var email: String?
    var emailVerifiedAt: String?
    var userMobile: String?
    var socialProviderId: String?
    var socialProvider: String?
    var serviceType: ServiceType?
    var serviceSubType: [SubCategory]?
    var tradeSkills: String?
    var workingArea: String?
    var insurance: String?
    var accreditations: String?
    var hourlyRate: String?
    var gender: String?
    var profileImage: String?
    var dob: String?
    var education: String?
    var work: String?
    var shortIntroduction: String?
    var deviceType: Int?
    var deviceToken: String?
    var createdAt: String?
    var updatedAt: String?
    var userWorkImages: [WorkImage]?
    var userQualifications: [QualificationImage]?
    var city: String?
    var latitude: String?
    var longitude: String?
    var paymentRate: String?
    var travelCostPerMile: String?
    var rating: String?
    var isAvailable: String?
    
    init(userId: Int, email: String?, fullName: String?) {
        self.id = userId
        self.email = email
        self.fullName = fullName
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}

extension User: SingleSignOnUser {
    var userId: Int {
        return id
    }
    
    var avatarUrl: URL? {
        return nil
    }
}

extension User {
    var workImages: [RemoteImage] {
        self.userWorkImages?.compactMap({$0.remoteImage}) ?? []
    }
    
    var qualificationImages: [RemoteImage] {
        self.userQualifications?.compactMap({$0.remoteImage}) ?? []
    }
    
    var insuranceImageURLString: String? {
        guard let insurance = self.insurance?.validOptionalString else { return nil }
        return AppConfig.host.imageURL(for: insurance)
    }
    
    var accreditationImageURLString: String? {
        guard let accreditations = self.accreditations?.validOptionalString else { return nil }
        return AppConfig.host.imageURL(for: accreditations)
    }
    
    var isAvailableForBooking: Bool {
        return (isAvailable ?? "0") == "1"
    }
}


extension User {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case fullName = "full_name"
        case email = "email"
        case emailVerifiedAt = "email_verified_at"
        case userMobile = "user_mobile"
        case socialProviderId = "social_provider_id"
        case socialProvider = "social_provider"
        case serviceType = "serviceType"
        case serviceSubType = "serviceSubType"
        case tradeSkills = "trade_skills"
        case workingArea = "working_area"
        case insurance = "insurance"
        case accreditations = "accreditations"
        case hourlyRate = "hourly_rate"
        case gender = "gender"
        case profileImage = "profile_image"
        case dob = "dob"
        case education = "education"
        case work = "work"
        case shortIntroduction = "short_introduction"
        case deviceType = "device_type"
        case deviceToken = "device_token"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userWorkImages = "UserWorkimages"
        case userQualifications = "UserQualifications"
        case city = "city"
        case latitude = "latitude"
        case longitude = "longitude"
        case paymentRate = "payment_rate"
        case travelCostPerMile = "travel_cost_per_mile"
        case rating = "rating"
        case isAvailable = "is_available"
    }
}

struct QualificationImage: Codable, Equatable {
    var user_qualification_id: Int?
    var image: String?
}

struct WorkImage: Codable, Equatable {
    var user_workimage_id: Int?
    var image: String?
}

extension QualificationImage {
    var remoteImage: RemoteImage? {
        guard let id = self.user_qualification_id, let image = self.image else { return nil }
        return RemoteImage(urlString: image, id: id, table: .userQualifications)
    }
}

extension WorkImage {
    var remoteImage: RemoteImage? {
        guard let id = self.user_workimage_id, let image = self.image else { return nil }
        return RemoteImage(urlString: image, id: id, table: .userWorkImage)
    }
}

struct DateSlotResponse: Codable {
    var user_timeslot_id: Int
    var user_id: Int
    var slotdate: String
    var company_name: String?
    var status: String?
}

/*
{
    "status": 1,
    "message": "Time slot list",
    "data": {
        "user_id": 89,
        "slotdate": "2019-07-15",
        "checkUserDate": {
            "user_timeslot_id": 16,
            "user_id": 89,
            "slotdate": "2019-07-15"
        },
        "checkUserTimeslot": [
        {
            "user_timeslot_time_id": 21,
            "user_timeslot_id": 16,
            "start_time": "18:00:00",
            "end_time": "22:00:00"
        }
        ]
    }
}
*/

struct PlanResponse: Codable {
    var user_id: Int
    var slotdate: String
    var checkUserTimeslot: [TimeSlotResponse]
}

struct TimeSlotResponse: Codable {
    var user_timeslot_time_id: Int
    var user_timeslot_id: Int
    var start_time: String
    var end_time: String
}

extension TimeSlotResponse {
    func event(dateFormatter: DateFormatter, serviceType: ServiceType?) -> Event? {
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "HH:mm:ss"
        guard let startDate = dateFormatter.date(from: start_time),
            let endDate = dateFormatter.date(from: end_time) else { return nil }
        
        let startString = dateFormatter.userFacingTimeString(from: startDate)
        let endString = dateFormatter.userFacingTimeString(from: endDate)
        return Event(
            id: user_timeslot_time_id,
            dateId: user_timeslot_id,
            date: "",
            description: "Service Type: \(serviceType?.name ?? "-")",
            startTime: startString,
            endTime: endString,
            color: UIColor.colors.randomElement() ?? UIColor.tintBlue
        )
    }
}

private extension UIColor {
    static var colors: [UIColor] {
        return [UIColor.tintBlue, UIColor.selectionYellow]
    }
}

extension PlanResponse {
    func events(dateFormatter: DateFormatter, serviceType: ServiceType?) -> [Event]? {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let dateString = dateFormatter.date(from: slotdate) else { return nil }
        dateFormatter.dateFormat = "dd MMM yyyy"
        let dateOfSlot = dateFormatter.string(from: dateString)
        var events = [Event]()
        for slots in self.checkUserTimeslot {
            if var event = slots.event(dateFormatter: dateFormatter, serviceType: serviceType) {
                event.date = dateOfSlot
                events.append(event)
            }
        }
        return events
    }
}

enum PaymentOption: String {
    case perDay = "Day Rate(£)"
    case perHour = "Hourly Rate(£)"
    
    var postFixUnit: String {
        switch self {
        case .perDay:
            return "Per Day"
        case .perHour:
            return "Per Hour"
        }
    }
}
