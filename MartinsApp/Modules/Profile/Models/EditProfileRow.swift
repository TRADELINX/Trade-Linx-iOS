//
//  EditProfileRow.swift
//  MartinsApp
//
//  Created by Neil Jain on 10/26/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import Foundation

enum EditProfileRow: Int, CaseIterable {
    case profileImage
    case fullName
    case email
    case phoneNumber
    case about
    case tradeType
    case subtrade
    case workingArea
    case paymentOption
    case rate
    case travelCostPerMile
    case insurance
    case photoGallery
    case qualification
    case updateButton
    
    var indexPath: IndexPath {
        return IndexPath(row: self.rawValue, section: 0)
    }
}

extension EditProfileRow {
    func rowType(for user: User) -> EditProfileRowType {
        switch self {
        case .profileImage:
            return .profileImages(Row<String, EditProfileAvtarCell>("")
            )
            
        case .fullName:
            return .field(Row<(FieldValue), EditProfileFieldCell>(
                FieldValue(title: "Full Name",
                           placeholder: "Enter Full Name",
                           value: user.fullName,
                           keyboardType: .default,
                           isSelectable: false,
                           formatter: nil))
            )
            
        case .email:
            return .field(Row<(FieldValue), EditProfileFieldCell>(
                FieldValue(title: "Email Id",
                           placeholder: "Enter Email Id",
                           value: user.email,
                           keyboardType: .emailAddress,
                           isSelectable: false,
                           formatter: nil))
            )
        case .phoneNumber:
            return .field(Row<(FieldValue), EditProfileFieldCell>(
                FieldValue(title: "Phone Number", placeholder: "Enter Phone Number", value: user.userMobile, keyboardType: .phonePad, isSelectable: false, formatter: nil))
            )
            
        case .about:
            return .field(Row<(FieldValue), EditProfileFieldCell>(
                FieldValue(title: "About",
                           placeholder: "Enter about your self",
                           value: user.shortIntroduction,
                           keyboardType: .default,
                           isSelectable: true,
                           formatter: nil))
            )
            
        case .tradeType:
            return .field(Row<(FieldValue), EditProfileFieldCell>(
                FieldValue(title: "Trade Type",
                           placeholder: "Select Trade Type",
                           value: user.serviceType?.name,
                           keyboardType: .default,
                           isSelectable: true,
                           formatter: nil))
            )
            
        case .subtrade:
            // user.serviceSubType?.compactMap({$0.name}).joined(separator: ",").validOptionalString,
            return .field(Row<(FieldValue), EditProfileFieldCell>(
                FieldValue(title: "Sub Trade",
                           placeholder: "Select Sub Trade",
                           value: user.serviceSubType?.compactMap({$0.name}).joined(separator: ", ").validOptionalString,
                           keyboardType: .default,
                           isSelectable: true,
                           formatter: nil))
            )
            
        case .workingArea:
            return .field(Row<(FieldValue), EditProfileFieldCell>(
                FieldValue(title: "Working Area",
                           placeholder: "Enter Working Area",
                           value: user.workingArea,
                           keyboardType: .default,
                           isSelectable: true,
                           formatter: nil))
            )
        case .paymentOption:
            return .field(Row<(FieldValue), EditProfileFieldCell>(
                FieldValue(title: "Payment Options",
                           placeholder: "Select Payment Option",
                           value: user.hourlyRate,
                           keyboardType: .default,
                           isSelectable: true,
                           formatter: nil))
            )
            
        case .rate:
            let currencyFormatter = NumberFormatter()
            currencyFormatter.numberStyle = .currency
            currencyFormatter.currencyGroupingSeparator = ","
            
            return .field(Row<(FieldValue), EditProfileFieldCell>(
                FieldValue(title: "Rate",
                           placeholder: "Enter rate", value: user.paymentRate, keyboardType: .default, isSelectable: false, formatter: currencyFormatter))
            )
            
        case .travelCostPerMile:
            let currencyFormatter = NumberFormatter()
            currencyFormatter.numberStyle = .currency
            currencyFormatter.currencyGroupingSeparator = ","
            currencyFormatter.currencySymbol = "£"
            
            return .field(Row<(FieldValue), EditProfileFieldCell>(
                FieldValue(title: "Travel Cost Per Mile", placeholder: "Enter travel cost per mile", value: user.travelCostPerMile, keyboardType: .default, isSelectable: false, formatter: currencyFormatter))
            )
            
        case .insurance:
            return .insurance(Row<(String, String, String), EditProfileQualificationCell>(("Insurance", "Upload Your Insurance Photo", "Upload Insurance"))
            )
            
        case .photoGallery:
            return .workExperience(Row<(String, String, String), EditProfileQualificationCell>(("Photo Gallery", "Upload photos to gallery", "Upload Photo"))
            )
            
        case .qualification:
            return .qualificationUpload(Row<(String, String, String), EditProfileQualificationCell>(("Qualifications / Certificates", "Upload Your Qualificatios / Certificates Photo", "Upload Photo"))
            )
            
        case .updateButton:
            return .updateProfile(Row<(String), EditProfileUpdateButtonCell>("Update Profile")
            )
        }
    }
}
