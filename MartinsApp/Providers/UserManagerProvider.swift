//
//  UserManager.swift
//  MartinsApp
//
//  Created by Neil Jain on 5/30/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import Foundation

protocol UserManagerProvider {
    var userManager: UserManager { get } 
}
