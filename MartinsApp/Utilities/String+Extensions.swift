//
//  String+Extensions.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/8/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import Foundation

extension String {
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    var isValidPassword: Bool {
        var returnValue = true
        let passwordExpression = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{6,}$"
        
        do {
            let regex = try NSRegularExpression(pattern: passwordExpression)
            let results = regex.matches(in: self, range: NSRange(location: 0, length: self.count))
            
            if results.count == 0 {
                returnValue = false
            }
        } catch let error as NSError {
            debugPrint("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        return  returnValue
    }
    
    static let passwordPolicy = "The password must contain at least one (1) character from three (3) of the following categories:\nUppercase letter (A-Z) \nLowercase letter (a-z)\nDigit (0-9)."
}
