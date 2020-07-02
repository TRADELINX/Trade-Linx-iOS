//
//  UserManager.swift
//  MartinsApp
//
//  Created by Neil Jain on 5/30/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import Foundation
import UIKit

class UserManager {
    typealias DependencyProvider = NavigationProvider & ViewControllerProvider & WebResourceProvider
    private let provider: DependencyProvider
    
    init(provider: DependencyProvider) {
        self.provider = provider
    }
    
    var currentUser: User? {
        return provider.webResource.currentUser
    }
    
    var isLoggedIn: Bool {
        return currentUser != .none
    }
    
    func logout() {
        DispatchQueue.main.async {
            UIApplication.shared.unregisterForRemoteNotifications()
            self.provider.webResource.logout()
            self.showLoginVC()
            // user.logout
            // stop sync
            // empty cache
        }
    }
    
    func prepareInitialViewController() {
        if isLoggedIn {
            showRootVC(currentUser!)
        } else {
            if UserDefaults.standard.isFirstLaunch {
                showOnboardingVC()
            } else {
                showLoginVC()
            }
        }
    }
    
    private func showRootVC(_ user: SingleSignOnUser) {
        // token setup
        // start sync
        let rootViewController = provider.createRootViewController()
        provider.setRoot(viewController: rootViewController)
    }
    
    private func showLoginVC() {
        let loginViewController = provider.createLoginViewController { [weak self] (user) in
            DispatchQueue.main.async { [weak self] in
                self?.showRootVC(user)
            }
        }
        provider.setRoot(viewController: loginViewController)
    }
    
    private func showOnboardingVC() {
        let vc = provider.createOnboardingViewController { [weak self] in
            UserDefaults.standard.setFirstLaunch()
            self?.prepareInitialViewController()
        }
        provider.setRoot(viewController: vc)
    }
}
