//
//  NotificationsViewController.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/2/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit
import FirebaseMessaging

class NotificationsViewController: UIViewController {
    
    typealias DependencyProvider = UserManagerProvider & WebResourceProvider
    var provider: DependencyProvider!
    
    @IBOutlet weak var tableView: UITableView!
    private var dataSource: [NotificationItem] = [] //{
        //didSet {
            //updateStates()
        //}
    //}
    
    private lazy var fetchingView: FetchingView = {
        let fetchingView = FetchingView(listView: self.tableView, parentView: self.view)
        return fetchingView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
        return refreshControl
    }()
    
    private lazy var deleteAllItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: #imageLiteral(resourceName: "trash"), style: .plain, target: self, action: #selector(deleteAllAction(_:)))
        return item
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTableView()
        fetchResource()
        self.requestForNotificationIfNeeded()
    }
    
    //override func viewWillAppear(_ animated: Bool) {
        //super.viewWillAppear(animated)
        //updateStates()
    //}
    
    deinit {
        print("Deinit called from NotificationsVC")
    }
    
    func prepareForBooking(with bookingItem: BookingNotification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let vc = AcceptRejectProposalVC.initialise(dependency: self.provider, notification: bookingItem)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func prepareTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 102
        self.tableView.refreshControl = self.refreshControl
        
        self.tableView.registerNib(MessageItemCell.self)
    }
    
    private func updateStates() {
        let condition = self.dataSource.count > 0
        self.parent?.navigationItem.rightBarButtonItem = condition ? deleteAllItem : nil
    }
    
    @objc private func deleteAllAction(_ sender: UIBarButtonItem) {
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            self.deleteAllNotifications()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        self.showAlert(title: "Delete All Notification", message: "Do you want to delete all notifications?", actions: deleteAction, cancelAction)
    }
    
    @objc private func refreshAction() {
        self.fetchResource(isRefreshing: true)
    }
}

// MARK: - Dependency Initialiser -
extension NotificationsViewController {
    static func initialise(provider: DependencyProvider) -> NotificationsViewController {
        let vc = NotificationsViewController.instantiate(from: .main)
        vc.provider = provider
        vc.title = "Notifications".uppercased()
        return vc
    }
}

// MARK: - UITableView Delegate -
extension NotificationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.dataSource[indexPath.row]
        guard let type = item.notification_type else { return }
        switch type {
        case .booking:
            let acceptRejectProposalVC = AcceptRejectProposalVC.initialise(dependency: self.provider, notification: item)
            self.navigationController?.pushViewController(acceptRejectProposalVC, animated: true)
        case .review:
            let ratingVC = RatingsViewController.initialise(provider: provider)
            self.navigationController?.pushViewController(ratingVC, animated: true)
            break
        case .chat:
            break
        }
    }
}

// MARK: - UITableView DataSource -
extension NotificationsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(MessageItemCell.self, for: indexPath)!
        cell.badgeLabel.isHidden = true
        cell.configure(with: dataSource[indexPath.row], dateFormatter: self.dateFormatter)
        return cell
    }
}

// MARK: - API -
extension NotificationsViewController {
    func fetchResource(isRefreshing: Bool = false) {
        guard let userId = self.provider.userManager.currentUser?.userId else { return }
        if !isRefreshing {
            self.fetchingView.fetchingState = .fetching
        }
        self.provider.webResource.notifications(userId: userId) { [weak self] (result) in
            self?.refreshControl.endRefreshing()
            switch result {
            case .success(let notifications):
                self?.dataSource = notifications
                self?.tableView.reloadData()
                self?.fetchingView.fetchingState = .fetched
            case .failure(let error):
                self?.dataSource = []
                self?.fetchingView.fetchingState = .error(error)
            }
        }
    }
    
    func deleteAllNotifications() {
        guard let userId = self.provider.userManager.currentUser?.userId else { return }
        AppHUD.shared.showHUD()
        self.provider.webResource.deleteAllNotifications(userId: userId) { [weak self] (result) in
            AppHUD.shared.hideHUD()
            switch result {
            case .success(let status):
                print(status)
                self?.fetchResource()
            case .failure(let error):
                self?.showAlert(for: error)
            }
        }
    }
}
