//
//  PushNotificationRequestMaker.swift
//  MartinsApp
//
//  Created by Neil Jain on 9/14/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase

protocol PushNotificationRequestMaker {
    typealias DependecyProvider = UserManagerProvider & WebResourceProvider
    var provider: DependecyProvider! { get set }
    func requestForNotificationIfNeeded()
    func registerForFCM()
}

extension PushNotificationRequestMaker where Self: UIViewController {
    func requestForNotificationIfNeeded() {
        UNUserNotificationCenter.current().delegate = UIApplication.shared.delegate as? AppDelegate
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
            if success {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func handleFCMToken(_ token: String, completion: @escaping (Result<User, ResponseError>)->Void) {
        guard let userId = provider.userManager.currentUser?.userId else { return }
        let register = Register()
        register.device_type = 1
        register.device_token = token
        register.user_id = userId
        provider.webResource.updateProfile(register: register, completion: completion)
    }
}
