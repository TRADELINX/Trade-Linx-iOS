//
//  NotificationRow.swift
//  MartinsApp
//
//  Created by Neil Jain on 12/15/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import Foundation

protocol CompanyDetailProvider {
    var user_job_id: Int? { get }
    var profileImage: String? { get }
    var name: String { get }
    var description: String { get }
}

enum NotificationRow {
    case profile
    case description
}

enum NotificationRowType {
    case image(Row<(String?, String), ProfileCell>)
    case description(Row<String, TextCell>)
}

extension NotificationRow {
    func rowType(provider: CompanyDetailProvider) -> NotificationRowType {
        switch self {
        case .profile:
            return .image(Row<(String?, String), ProfileCell>((provider.profileImage, provider.name)))
        case .description:
            return .description(Row<String, TextCell>(provider.description))
        }
    }
}

extension NotificationRow {
    static func dataSource(for provider: CompanyDetailProvider) -> [NotificationRowType] {
        return [
            NotificationRow.profile.rowType(provider: provider),
            NotificationRow.description.rowType(provider: provider)
        ]
    }
}
