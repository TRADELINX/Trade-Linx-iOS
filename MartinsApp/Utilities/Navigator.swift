//
//  Navigator.swift
//
//  Created by Neil Jain on 3/26/19.
//  Copyright © 2019 Neil Jain. All rights reserved.
//

import Foundation

protocol Navigator {
    associatedtype Destination
    func navigate(to destination: Destination)
}
