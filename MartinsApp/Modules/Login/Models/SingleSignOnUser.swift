//
//  SingleSignOnUser.swift
//  MartinsApp
//
//  Created by Neil Jain on 5/30/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import Foundation

protocol SingleSignOnUser {
    var email: String? { get }
    var avatarUrl: URL? { get }
    var fullName: String? { get }
    var userId: Int { get }
}
