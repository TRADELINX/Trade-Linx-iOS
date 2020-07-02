//
//  AppConfig.swift
//  MartinsApp
//
//  Created by Neil Jain on 10/12/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import Foundation

enum AppConfig {
    static let scheme: HTTPScheme = .https
    static let host: URLHost = .live
}

extension AppConfig {
    static let shouldDisplayDebugMessage = false
    static let useKeychain = false
}
