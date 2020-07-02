//
//  MessagesViewController.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/3/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class MessagesViewController: UIViewController {
    typealias DependencyProvider = UserManagerProvider & WebResourceProvider
    
    var provider: DependencyProvider!
    
    var user: User {
        guard let user = provider.userManager.currentUser else {
            fatalError()
        }
        return user
    }
    
    var dataSource: [MessageItem] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var dateFormatter: DateFormatter = {
        return DateFormatter()
    }()
    
    private lazy var fetchingView: FetchingView = {
        return FetchingView(listView: self.tableView, parentView: self.view)
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItems()
        prepareTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchResource(isRefreshing: false)
    }
    
    deinit {
        print("Deinit called from Messages View Controller")
    }
    
    private func setupNavigationItems() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
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
    
    @objc func refreshAction(_ sender: UIRefreshControl) {
        self.fetchResource(isRefreshing: true)
    }

}

extension MessagesViewController {
    static func initialise(provider: DependencyProvider) -> MessagesViewController {
        let vc = MessagesViewController.instantiate(from: .main)
        vc.provider = provider
        vc.title = "Messages".uppercased()
        return vc
    }
}

extension MessagesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ConversationViewController.initialise(provider: self.provider)
        let message = self.dataSource[indexPath.item]
        vc.messageItem = message
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension MessagesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
}

// MARK: API
extension MessagesViewController {
    func fetchResource(isRefreshing: Bool) {
        let userId = self.user.userId
        if !isRefreshing {
            self.fetchingView.fetchingState = .fetching
        }
        self.provider.webResource.messages(for: userId) { [weak self] (result) in
            self?.refreshControl.endRefreshing()
            switch result {
            case .success(let messages):
                self?.fetchingView.fetchingState = .fetched
                self?.dataSource = messages
                self?.tableView.reloadData()
            case .failure(let error):
                self?.fetchingView.fetchingState = .error(error)
            }
        }
    }
}
