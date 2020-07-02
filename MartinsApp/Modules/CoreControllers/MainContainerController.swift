//
//  MainContainerController.swift
//  MartinsApp
//
//  Created by Neil Jain on 5/30/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit
import SideMenu
import FirebaseMessaging
import UserNotifications

class MainContainerController: UIViewController, ContainmentProvider {
    typealias DependencyProvider = UserManagerProvider & WebResourceProvider
    var provider: DependencyProvider!
    
    private lazy var containerView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    private weak var currentVisibleController: UIViewController?
    
    var sideMenuItem: SideMenuItem = .planner {
        didSet {
            handleItemSelection(for: sideMenuItem)
        }
    }
    
    weak var plannerController: PlannerViewController?
    weak var notificationsController: NotificationsViewController?
    weak var profileController: ProfileViewController?
    weak var messagesController: MessagesViewController?
    weak var ratingsController: RatingsViewController?
    
    lazy var menuItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), style: .plain, target: self, action: #selector(menuAction))
        return item
    }()
    
    private lazy var sideOptionVC: SideOptionsViewController = {
        let leftVC = SideOptionsViewController.initialise(provider: self.provider)
        leftVC.onItemSelection = { [weak self] (selectedItem) in
            self?.sideMenuItem = selectedItem
        }
        return leftVC
    }()
    
    private lazy var sideMenuVC: SideMenuNavigationController = {
        let navigationVC = SideMenuNavigationController(rootViewController: self.sideOptionVC)
        navigationVC.view.clipsToBounds = false
        navigationVC.menuWidth = 102 + 32
        navigationVC.pushStyle = .default
        navigationVC.statusBarEndAlpha = 0
        return navigationVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        prepareNavigationItems()
        self.handleItemSelection(for: self.sideMenuItem)
        self.registerForFCM()
        self.requestForNotificationIfNeeded()
        feedbackGenerator.prepare()
    }
    
    deinit {
        print("Deinit called from MainContainerController")
    }
    
    private func setupViews() {
        self.view.addSubview(containerView)
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    private func prepareNavigationItems() {
        self.navigationItem.leftBarButtonItem = menuItem
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.view.clipsToBounds = false
    }
    
    private func handleItemSelection(for item: SideMenuItem) {
        self.removeChild(currentVisibleController)
        self.title = nil
        self.navigationItem.rightBarButtonItems = nil
        switch item {
        case .planner:
            let vc = plannerController ?? plannerVC()
            self.title = vc.title
            self.addChild(vc, to: self.containerView)
            self.currentVisibleController = vc
        case .notifications:
            let vc = notificationsController ?? notificatiosVC()
            self.title = vc.title
            self.addChild(vc, to: self.containerView)
            self.currentVisibleController = vc
        case .chat:
            let vc = messagesController ?? messagesVC()
            self.title = vc.title
            self.addChild(vc, to: self.containerView)
            self.currentVisibleController = vc
        case .rating:
            let vc = ratingsController ?? ratingsVC()
            self.title = vc.title
            self.addChild(vc, to: self.containerView)
            self.currentVisibleController = vc
        case .myProfile:
            let vc = profileController ?? profileVC()
            self.title = vc.title
            self.navigationItem.rightBarButtonItem = vc.navigationItem.rightBarButtonItem
            self.addChild(vc, to: self.containerView)
            self.currentVisibleController = vc
        case .logout:
            self.sideMenuVC.dismiss(animated: true) {
                self.provider.userManager.logout()
            }
            sideOptionVC.selectSideOption(item)
        }
        feedbackGenerator.impactOccurred(withIntensity: 1)
    }
    
    @objc func menuAction() {
        feedbackGenerator.impactOccurred(withIntensity: 1)
        sideMenuVC.leftSide = true
        self.present(sideMenuVC, animated: true, completion: nil)
    }
    
    func prepareForChat(with messageItem: MessageItem) {
        AppLog.print(messageItem.description)
        if self.sideMenuItem != .chat {
            self.sideOptionVC.selectSideOption(.chat)
            self.sideMenuItem = .chat
        }
        if let messageNavController = self.messagesController?.navigationController {
            if let conversationVC = messageNavController.topViewController as? ConversationViewController,
                conversationVC.messageItem.company_id == messageItem.company_id {
                return
            } else {
                let conversationVC = ConversationViewController.initialise(provider: self.provider)
                conversationVC.messageItem = messageItem
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    messageNavController.popToRootViewController(animated: false)
                    messageNavController.pushViewController(conversationVC, animated: false)
                }
            }
        } else {
            AppLog.print("Cannot get messageController so, returning...")
        }
    }
    
    func prepareForBooking(with bookingItem: BookingNotification) {
        AppLog.print(bookingItem)
        if self.sideMenuItem != .notifications {
            self.sideOptionVC.selectSideOption(.notifications)
            self.sideMenuItem = .notifications
        }
        if let notificationVC = self.notificationsController {
            notificationVC.prepareForBooking(with: bookingItem)
        }
    }
    
}

// MARK: - Child ViewControllers
extension MainContainerController {
    static func initialise(provider: DependencyProvider) -> MainContainerController {
        let vc = MainContainerController.instantiate(from: .main)
        vc.provider = provider
        return vc
    }
    
    func plannerVC() -> PlannerViewController {
        let vc = PlannerViewController.initialise(provider: self.provider)
        self.plannerController = vc
        return vc
    }
    
    func notificatiosVC() -> NotificationsViewController {
        let vc = NotificationsViewController.initialise(provider: self.provider)
        self.notificationsController = vc
        return vc
    }
    
    func profileVC() -> ProfileViewController {
        let vc = ProfileViewController.initialise(provider: self.provider)
        self.profileController = vc
        return vc
    }
    
    func messagesVC() -> MessagesViewController {
        let vc = MessagesViewController.initialise(provider: self.provider)
        self.messagesController = vc
        return vc
    }
    
    func ratingsVC() -> RatingsViewController {
        let vc = RatingsViewController.initialise(provider: self.provider)
        self.ratingsController = vc
        return vc
    }
}

// MARK: - FCM Notification Messageing Delegate
extension MainContainerController: PushNotificationRequestMaker, MessagingDelegate {
    func registerForFCM() {
        Messaging.messaging().isAutoInitEnabled = true
        Messaging.messaging().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
        if let fcmToken = Messaging.messaging().fcmToken ?? UserDefaults.standard.value(forKey: .deviceToken) as? String {
            self.updateToken(fcmToken)
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("FCMToken recieved")
        print(fcmToken)
        UserDefaults.standard.setValue(fcmToken, forKey: .deviceToken)
        self.updateToken(fcmToken)
    }
    
    private func updateToken(_ token: String) {
        self.handleFCMToken(token) { (result) in
            switch result {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error)
            }
        }
    }
}
