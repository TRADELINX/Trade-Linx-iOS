//
//  EditProfileRowType.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/2/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

enum EditProfileRowType {
    //case profileImages(Row<String, EditProfileImagesCell>)
    case profileImages(Row<String, EditProfileAvtarCell>)
    case field(Row<(FieldValue), EditProfileFieldCell>)
    case selection(Row<String, UITableViewCell>)
    case insurance(Row<(String, String, String), EditProfileQualificationCell>)
    case accreditation(Row<(String, String, String), EditProfileQualificationCell>)
    case workExperience(Row<(String, String, String), EditProfileQualificationCell>)
    case qualificationUpload(Row<(String, String, String), EditProfileQualificationCell>)
    case updateProfile(Row<(String), EditProfileUpdateButtonCell>)
}

extension EditProfileRowType {
    static func dataSource(for user: User) -> [EditProfileRowType] {
        return EditProfileRow.allCases.map({$0.rowType(for: user)})
    }
    
    /*
    static func dataSource(for user: User) -> [EditProfileRowType] {
        
        return [
            .profileImages(Row<String, EditProfileAvtarCell>("John Doe")),
            .field(Row<(FieldValue), EditProfileFieldCell>(
                FieldValue(title: "Full Name",
                           placeholder: "Enter Full Name",
                           value: user.fullName,
                           keyboardType: .default,
                           isSelectable: false,
                           formatter: nil))
            ),
            .field(Row<(FieldValue), EditProfileFieldCell>(
                FieldValue(title: "Email Id",
                           placeholder: "Enter Email Id",
                           value: user.email,
                           keyboardType: .emailAddress,
                           isSelectable: false,
                           formatter: nil))
            ),
            .field(Row<(FieldValue), EditProfileFieldCell>(
                FieldValue(title: "About",
                           placeholder: "Enter about your self",
                           value: user.shortIntroduction,
                           keyboardType: .default,
                           isSelectable: true,
                           formatter: nil))
            ),
            .field(Row<(FieldValue), EditProfileFieldCell>(
                FieldValue(title: "Trade Type",
                           placeholder: "Select Trade Type",
                           value: user.serviceType?.name,
                           keyboardType: .default,
                           isSelectable: true,
                           formatter: nil))
            ),
            .field(Row<(FieldValue), EditProfileFieldCell>(
                FieldValue(title: "Sub Trade",
                           placeholder: "Select Sub Trade",
                           value: user.serviceSubType?.name,
                           keyboardType: .default,
                           isSelectable: true,
                           formatter: nil))
            ),
            .field(Row<(FieldValue), EditProfileFieldCell>(
                FieldValue(title: "Working Area",
                           placeholder: "Enter Working Area",
                           value: user.workingArea,
                           keyboardType: .default,
                           isSelectable: true,
                           formatter: nil))
            ),
            .field(Row<(FieldValue), EditProfileFieldCell>(
                FieldValue(title: "Payment Options",
                           placeholder: "Select Payment Option",
                           value: user.hourlyRate,
                           keyboardType: .default,
                           isSelectable: true,
                           formatter: nil))
            ),
            .insurance(Row<(String, String, String), EditProfileQualificationCell>(("Insurance", "Upload Your Insurance Photo", "Upload Insurance"))),
            //.field(Row<(FieldValue), EditProfileFieldCell>(
            //    FieldValue(title: "Insurance",
            //               placeholder: "Enter Ensurance Number",
            //               value: user.insurance,
            //               keyboardType: .numbersAndPunctuation,
            //               isSelectable: false,
            //               formatter: nil))
            //),
            
            //.accreditation(Row<(String, String, String), EditProfileQualificationCell>(("Accreditation's", "Upload Your Accreditation's Photo", "Upload Accreditation's"))),
            
            //.field(Row<(FieldValue), EditProfileFieldCell>(
            //    FieldValue(title: "Accreditation's",
            //               placeholder: "Enter Accreditation's",
            //               value: user.accreditations,
            //               keyboardType: .default,
            //               isSelectable: false,
            //               formatter: nil))
            //),
            .workExperience(Row<(String, String, String), EditProfileQualificationCell>(("Photo Gallery", "Upload photos to gallery", "Upload Photo"))),
            .qualificationUpload(Row<(String, String, String), EditProfileQualificationCell>(("Qualifications / Certificates", "Upload Your Qualificatios / Certificates Photo", "Upload Photo"))),
            .updateProfile(Row<(String), EditProfileUpdateButtonCell>("Update Profile"))
        ]
    }
     */
}
