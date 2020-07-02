//
//  FieldValue.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/2/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

struct FieldValue {
    var title: String
    var placeholder: String?
    var value: String?
    var keyboardType: UIKeyboardType = .default
    var isSelectable: Bool = false
    var formatter: NumberFormatter? = nil
}

extension FieldValue {
    init(title: String, placeholder: String?, value: String?) {
        self.title = title
        self.placeholder = placeholder
        self.value = value
    }
}
