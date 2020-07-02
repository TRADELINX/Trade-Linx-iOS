//
//  SideMenuItem.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/1/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

enum SideMenuItem {
    case planner
    case notifications
    case chat
    case rating
    case myProfile
    case logout
}

extension SideMenuItem {
    var image: UIImage {
        switch self {
        case .planner:
            return #imageLiteral(resourceName: "menuCalendar")
        case .notifications:
            return #imageLiteral(resourceName: "menuNotification")
        case .chat:
            return #imageLiteral(resourceName: "menuChat")
        case .rating:
            return #imageLiteral(resourceName: "menuRating")
        case .myProfile:
            return #imageLiteral(resourceName: "menuMyProfile")
        case .logout:
            return #imageLiteral(resourceName: "menuLogout")
        }
    }
    
    var name: String {
        switch self {
        case .planner:
            return "Diary".uppercased()
        case .notifications:
            return "Notifications".uppercased()
        case .chat:
            return "Messages".uppercased()
        case .rating:
            return "Ratings".uppercased()
        case .myProfile:
            return "Profile".uppercased()
        case .logout:
            return "Log Out".uppercased()
        }
    }
}

enum SideMenuRowType {
    case profile(Row<User, SideProfileCell>)
    case item(Row<SideMenuItem, SideMenuItemCell>)
}

extension SideMenuRowType {
    static func dataSource(for user: User) -> [SideMenuRowType] {
        return [
            //.profile(Row<User, SideProfileCell>(user)),
            .item(Row<SideMenuItem, SideMenuItemCell>(.planner)),
            .item(Row<SideMenuItem, SideMenuItemCell>(.notifications)),
            .item(Row<SideMenuItem, SideMenuItemCell>(.chat)),
            .item(Row<SideMenuItem, SideMenuItemCell>(.rating)),
            .item(Row<SideMenuItem, SideMenuItemCell>(.myProfile)),
            .item(Row<SideMenuItem, SideMenuItemCell>(.logout))
        ]
    }
    
    var sideMenuItem: SideMenuItem? {
        switch self {
        case .item(let row):
            return row.value
        default:
            return nil
        }
    }
}
