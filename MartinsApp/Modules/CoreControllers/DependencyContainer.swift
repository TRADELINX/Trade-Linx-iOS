//
//  DependencyContainer.swift
//  MartinsApp
//
//  Created by Neil Jain on 5/30/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class DependencyContainer: UserManagerProvider, WebResourceProvider {
    let window: UIWindow
    
    private(set) lazy var userManager: UserManager = UserManager(provider: self)
    let webResource = WebResource()
    
    init(window: UIWindow) {
        self.window = window
    }
}

extension DependencyContainer: NavigationProvider {
    func setRoot(viewController: UIViewController) {
        guard window.rootViewController != nil else {
            self.window.rootViewController = viewController
            return
        }
        
        self.window.rootViewController = viewController
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {}, completion: nil)
    }
    
    func present(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        window.rootViewController?.present(viewController, animated: true, completion: completion)
    }
    
    func showError(title: String, description: String) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: .none))
        present(alert, animated: true, completion: {})
    }
    
    func navigate(for notification: [AnyHashable : Any]) {
        // Check if the root viewController is Container other wise there is no current logged in user.
        AppLog.print(notification.description)
        guard let rootViewController = (self.window.rootViewController as? ThemedNavigationController)?.viewControllers.first as? MainContainerController,
            let userId = self.userManager.currentUser?.userId
        else {
            AppLog.print("Can not find RootViewController as MainContainerController, or user is not logged in, or payload is not proper, so returning...")
            return
        }
        if let messageItem = MessageItem(payload: notification, userId: userId) {
            rootViewController.prepareForChat(with: messageItem)
        } else if let bookingItem = BookingNotification(payload: notification) {
            rootViewController.prepareForBooking(with: bookingItem)
        }
    }
    
    func isConversationOpen(for userInfo: [AnyHashable: Any]) -> Bool {
        guard let rootViewController = (self.window.rootViewController as? ThemedNavigationController)?.viewControllers.first as? MainContainerController else {
            return false
        }
        guard let companyIdString = userInfo["companyId"] as? String, let companyId = Int(companyIdString)  else { return false }
        if let conversationViewController = rootViewController.messagesController?.navigationController?.topViewController as? ConversationViewController {
            return conversationViewController.messageItem.company_id == companyId
        }

        return false
    }
    
}

extension DependencyContainer: ViewControllerProvider {
    func createRootViewController() -> UIViewController {
        let mainViewController = MainContainerController.initialise(provider: self)
        let navigationController = ThemedNavigationController(rootViewController: mainViewController)
        return navigationController
    }
    
    func createLoginViewController(success: @escaping (SingleSignOnUser) -> Void) -> UINavigationController {
        let loginVC = LoginViewController.initialise(dependencyProvider: self, onSuccess: success)
        return UINavigationController(rootViewController: loginVC)
    }
    
    func createOnboardingViewController(success: @escaping () -> Void) -> UIViewController {
        let onboardingVC = OnboardingViewController.instantiate(from: .main)
        onboardingVC.onCompletion = success
        return onboardingVC
    }
}
