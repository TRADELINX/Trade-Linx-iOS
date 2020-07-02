//
//  Array+Extensions.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/30/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import Foundation

extension Array {
    subscript(safe index: Array.Index) -> Element? {
        if index < 0 || index >= self.count { return nil }
        return self[index]
    }
}
