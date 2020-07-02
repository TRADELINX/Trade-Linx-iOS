//
//  AddEventRowType.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/30/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import Foundation

enum AddEventRowType {
    case timeField(Row<(String, FieldValue, FieldValue), AddEventCell>)
    case button(Row<String, EditProfileUpdateButtonCell>)
}

extension AddEventRowType {
    static func dataSource() -> [AddEventRowType] {
        let fromTimeValue = FieldValue(title: "From", placeholder: "00:00", value: nil)
        let toTimeValue = FieldValue(title: "To", placeholder: "00:00", value: nil)
        return [
            AddEventRowType.timeField(Row<(String, FieldValue, FieldValue), AddEventCell>(("Available Times", fromTimeValue, toTimeValue))),
            .button(Row<String, EditProfileUpdateButtonCell>("SAVE AVAILABILITY"))
        ]
    }
}
