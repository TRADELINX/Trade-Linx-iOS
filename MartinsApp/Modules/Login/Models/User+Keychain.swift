//
//  User+Keychain.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/1/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import Foundation

fileprivate let USER_KEY = "com.martins.martinsApp.sso_user"

internal extension User {
    
    @discardableResult
    func persistToKeychain() -> Bool {
        let encoder = JSONEncoder()
        guard let encoded = try? encoder.encode(self) else {
            return false
        }
        if AppConfig.useKeychain {
            let keychain = KeychainSwift()
            return keychain.set(encoded, forKey: USER_KEY, withAccess: .accessibleAfterFirstUnlock)
        } else {
            let userDefaults = UserDefaults.standard
            userDefaults.set(encoded, forKey: USER_KEY)
            return userDefaults.synchronize()
        }
    }
    
    static func restoreFromKeychain() -> User? {
        if AppConfig.useKeychain {
            let keychain = KeychainSwift()
            guard let encoded = keychain.getData(USER_KEY) else {
                return .none
            }
            let decoder = JSONDecoder()
            return try? decoder.decode(self, from: encoded)
        } else {
            let userDefaults = UserDefaults.standard
            guard let encoded = userDefaults.value(forKey: USER_KEY) as? Data else {
                return .none
            }
            let decoder = JSONDecoder()
            return try? decoder.decode(self, from: encoded)
        }
    }
    
    @discardableResult
    static func removeFromKeychain() -> Bool {
        if AppConfig.useKeychain {
            let keychain = KeychainSwift()
            return keychain.delete(USER_KEY)
        } else {
            UserDefaults.standard.set(nil, forKey: USER_KEY)
            return UserDefaults.standard.synchronize()
        }
    }
    
}
