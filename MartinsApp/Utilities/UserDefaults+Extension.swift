//
//  UserDefaults+Extension.swift
//  MartinsApp
//
//  Created by Neil Jain on 12/20/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    enum Key: String {
        case firstLaunch = "com.martin.firstLaunch"
        case deviceToken = "com.martin.fcmtoken"
    }
    
    func setValue(_ value: Any, forKey key: Key) {
        self.set(value, forKey: key.rawValue)
    }
    
    func value(forKey key: Key) -> Any? {
        return value(forKey: key.rawValue)
    }
    
    
}

extension UserDefaults {
    var isFirstLaunch: Bool {
        return !((UserDefaults.standard.value(forKey: .firstLaunch) as? Bool) ?? false)
    }
    
    func setFirstLaunch() {
        UserDefaults.standard.setValue(true, forKey: .firstLaunch)
    }
}
