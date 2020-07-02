//
//  AppDelegate.swift
//  MartinsApp
//
//  Created by Neil Jain on 5/30/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit
import IQKeyboardManager
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseMessaging
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var dependencyContainer: DependencyContainer?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        AppLog.print("Application started")
        AppLog.print("Launch Options are: \(launchOptions ?? [:])")
        // Google Sign In
        //"842121899339-osj51ckre1ca8uibohfgrkugdp6fom8h.apps.googleusercontent.com"
        //"842121899339-sk0t0dts87e52e3e2i7jnvebilgmuefc.apps.googleusercontent.com" - com.martine-martin
        GIDSignIn.sharedInstance()?.clientID = "842121899339-osj51ckre1ca8uibohfgrkugdp6fom8h.apps.googleusercontent.com"
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Google Places
        GMSPlacesClient.provideAPIKey("AIzaSyCRM6CksJONVacNQgr7t1Hkt9rf9R64gr4")
        
        // Firebase configuration
        FirebaseApp.configure()
        
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().toolbarTintColor = UIColor.grayButtonColor
        
        if #available(iOS 13.0, *) {
            
        } else {
            window = UIWindow()
            guard let window = window else { return false }
            
            UINavigationBar.appearance().backIndicatorImage = #imageLiteral(resourceName: "navigationBack")
            UINavigationBar.appearance().backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "navigationBack")
            
            //sleep(2)
            
            let dependencyContainer = DependencyContainer(window: window)
            self.dependencyContainer = dependencyContainer
            dependencyContainer.userManager.prepareInitialViewController()
            
            window.makeKeyAndVisible()
            
            if let notificationUserInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any] {
                AppLog.print(notificationUserInfo.description)
                guard let dependencyContainer = self.dependencyContainer else { return true }
                dependencyContainer.navigate(for: notificationUserInfo)
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        AppLog.print("Application enters in background")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        AppLog.print("Application enters in Forground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        AppLog.print("Application Became Active")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        AppLog.print("Application Terminates")
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let result = GIDSignIn.sharedInstance()?.handle(url) {
            return result
        }
        else {
            return ApplicationDelegate.shared.application(app, open: url, options: options)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        defer { completionHandler() }
        let userInfo = response.notification.request.content.userInfo
        AppLog.print(userInfo.description)
        guard let dependencyContainer = self.dependencyContainer else { return }
        dependencyContainer.navigate(for: userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        AppLog.print(userInfo.description)
        guard let dependencyContainer = self.dependencyContainer else {
            completionHandler(.noData)
            return
        }
        dependencyContainer.navigate(for: userInfo)
        completionHandler(.noData)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        AppLog.print("Device Token Register = ")
        AppLog.print(deviceTokenString)
        Messaging.messaging().apnsToken = deviceToken
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        if self.dependencyContainer?.isConversationOpen(for: userInfo) ?? false {
            completionHandler([])
        } else {
            completionHandler([.alert, .badge, .sound])
        }
    }
}
