//
//  UIImpactFeedbackGenerator+Extension.swift
//  MartinsApp
//
//  Created by Neil on 03/04/20.
//  Copyright © 2020 Ratnesh Jain. All rights reserved.
//

import UIKit

extension UIImpactFeedbackGenerator {
    func impactOccurred(withIntensity intensity: CGFloat) {
        if #available(iOS 13, *) {
            self.impactOccurred(intensity: intensity)
        } else {
            self.impactOccurred()
        }
    }
}
