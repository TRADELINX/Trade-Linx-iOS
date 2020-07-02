//
//  JobStatus.swift
//  MartinsApp
//
//  Created by Neil Jain on 12/7/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import SwiftUI

enum JobStatus: String, Codable {
    case start = "1"
    case complete = "2"
    case approve = "3"
    case rating = "4"
}
