//
//  UserProfileRowType.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/2/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import Foundation

enum UserProfileRowType {
    case profile(Row<User, UserProfileCell>)
    case detail(Row<(String, String?), UserDetailCell>)
    case images(Row<(String,[Image]), ProfileReadOnlyImagesCell>)
}

extension UserProfileRowType {
    static func dataSource(for user: User) -> [UserProfileRowType] {
        
        var rate = (user.paymentRate?.validOptionalString ?? "-")
        let paymentOption = PaymentOption(rawValue: user.hourlyRate ?? "") ?? .perDay
        rate.append(" \(paymentOption.postFixUnit)")

        // user.serviceSubType?.compactMap({$0.name}).joined(separator: ", ").validOptionalString ?? "-")
        var rows: [UserProfileRowType] = [
            .profile(Row<User, UserProfileCell>(user)),
            .detail(Row<(String, String?), UserDetailCell>(("Email Id", user.email))),
            .detail(Row<(String, String?), UserDetailCell>(("Phone Number", user.userMobile?.validOptionalString ?? "-"))),
            .detail(Row<(String, String?), UserDetailCell>(("About", user.shortIntroduction?.validOptionalString ?? "-"))),
            .detail(Row<(String, String?), UserDetailCell>(("Trade Type", user.serviceType?.name.validOptionalString ?? "-"))),
            .detail(Row<(String, String?), UserDetailCell>(("Sub Trade", user.serviceSubType?.compactMap({$0.name}).joined(separator: ", ").validOptionalString ?? "-"))),
            .detail(Row<(String, String?), UserDetailCell>(("Working Area", user.workingArea?.validOptionalString ?? "-"))),
        ]
        
        let workInages = user.workImages.map({Image.remote($0)})
        if workInages.count > 0 {
            rows.append(.images(Row<(String, [Image]), ProfileReadOnlyImagesCell>(("Photo Gallery", user.workImages.map{Image.remote($0)}))))
        }
        
        rows.append(.detail(Row<(String, String?), UserDetailCell>(("Rate", rate))))
        rows.append(.detail(Row<(String, String?), UserDetailCell>(("Travel Cost Per Mile", user.travelCostPerMile?.validOptionalString ?? "-"))))
        
        //.images(Row<(String, [Image]), ProfileReadOnlyImagesCell>(("Insurance", [Image.remote(RemoteImage(urlString: user.insuranceImageURLString ?? "", id: user.id, table: TableName.userWorkImage))]))),
        //.images(Row<(String, [Image]), ProfileReadOnlyImagesCell>(("Accreditation's", [Image.remote(RemoteImage(urlString: user.accreditationImageURLString ?? "", id: user.id, table: .userWorkImage))]))),
        //.detail(Row<(String, String?), UserDetailCell>(("Payment Option", user.hourlyRate?.validOptionalString ?? "-"))),
        
        return rows
    }
}
