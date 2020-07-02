//
//  UIColor+Constants.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/1/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

extension UIColor {
    static var tintBlue: UIColor {
        return #colorLiteral(red: 0.3803921569, green: 0.4823529412, blue: 1, alpha: 1)
    }
    
    static var selectionYellow: UIColor {
        return #colorLiteral(red: 1, green: 0.7882352941, blue: 0.3803921569, alpha: 1)
    }
    
    static var seperatorGray: UIColor {
        return #colorLiteral(red: 0.6745098039, green: 0.7058823529, blue: 0.7254901961, alpha: 1)
    }
    
    static var appBackground: UIColor {
        return UIColor(named: "AppBackground")!
    }
    
    static var messageFieldColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor {
                if $0.userInterfaceStyle == .dark {
                    return UIColor.secondarySystemGroupedBackground
                } else {
                    return UIColor.groupTableViewBackground
                }
            }
        } else {
            return UIColor.groupTableViewBackground
        }
    }
    
    static var seperatorColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor {
                if $0.userInterfaceStyle == .dark {
                    return .separator
                } else {
                    return #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
                }
            }
        } else {
            return #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
        }
    }
    
    static var shadowColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor {
                if $0.userInterfaceStyle == .dark {
                    return UIColor.darkGray
                } else {
                    return UIColor.groupTableViewBackground
                }
            }
        } else {
            return UIColor.groupTableViewBackground
        }
    }
    
    static var grayButtonColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor {
                if $0.userInterfaceStyle == .dark {
                    return UIColor.white
                } else {
                    return UIColor.darkGray
                }
            }
        } else {
            return UIColor.darkGray
        }
    }
}
