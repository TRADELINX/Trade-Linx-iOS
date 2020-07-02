//
//  ServiceTradeList.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/8/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import Foundation

struct ServiceTradeList: Decodable {
    var service: [ServiceType]?
}

struct ServiceType: Codable {
    var category_id: Int
    var name: String
    var SubCategory: [SubCategory]?
}

extension ServiceType: Equatable {
    static func == (lhs: ServiceType, rhs: ServiceType) -> Bool {
        return lhs.category_id == rhs.category_id && lhs.name == rhs.name
    }
}

extension ServiceType: CustomStringConvertible {
    var description: String {
        return name
    }
}

struct SubCategory: Codable, Equatable {
    var sub_category_id: Int
    var category_id: Int?
    var name: String
    
    static func ==(lhs: SubCategory, rhs: SubCategory) -> Bool {
        return lhs.sub_category_id == rhs.sub_category_id
    }
}

extension SubCategory: CustomStringConvertible {
    var description: String {
        return name
    }
}

struct WorkingPlace: Codable {
    var workingArea: String
    var city: String?
    var latitude: String?
    var longitude: String?
}
