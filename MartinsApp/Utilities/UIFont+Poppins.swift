//
//  UIFont+Poppins.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/1/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

extension UIFont {
    enum PoppinsWeight {
        case regular
        case medium
        case semibold
        
        var fontName: String {
            switch self {
            case .regular:
                return "Poppins-Regular"
            case .medium:
                return "Poppins-Medium"
            case .semibold:
                return "Poppins-SemiBold"
            }
        }
    }
    static func poppins(for size: CGFloat = UIFont.labelFontSize, weight: PoppinsWeight = .regular) -> UIFont {
        guard let regularFont = UIFont(name: weight.fontName, size: size) else {
            fatalError("""
        Failed to load the "Poppins-Regular" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        return regularFont
    }
}
