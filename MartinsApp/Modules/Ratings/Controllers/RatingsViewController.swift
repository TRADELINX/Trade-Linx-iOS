//
//  RatingsViewController.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/3/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class RatingsViewController: UIViewController {
    typealias DependencyProvider = UserManagerProvider & WebResourceProvider
    var provider: DependencyProvider!
    private var dataSource: [Rating] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var fetchingView: FetchingView = {
        let fetchingView = FetchingView(listView: self.tableView, parentView: self.view)
        return fetchingView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
        return refreshControl
    }()
    
    private let dateFormatter: DateFormatter = {
        return DateFormatter()
    }()
    
    private let dateComponentFormatter: DateComponentsFormatter = {
        return DateComponentsFormatter()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTableView()
        fetchRatings()
    }
    
    private func prepareTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 102
        
        self.tableView.registerNib(RatingsCell.self)
        self.tableView.refreshControl = refreshControl
    }
    
    @objc private func refreshAction() {
        self.fetchRatings(isRefreshing: true)
    }
    
    deinit {
        AppLog.print("Deinit called from RatingsViewController")
    }

}

extension RatingsViewController: UITableViewDelegate {
    
}

extension RatingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(RatingsCell.self, for: indexPath)!
        cell.configure(with: dataSource[indexPath.row],
                       dateFormatter: self.dateFormatter,
                       formatter: dateComponentFormatter)
        return cell
    }
}

// MARK: - API

extension RatingsViewController {
    private func fetchRatings(isRefreshing: Bool = false) {
        if !isRefreshing {
            self.fetchingView.fetchingState = .fetching
        }
        provider.webResource.ratings { [weak self] (result) in
            self?.refreshControl.endRefreshing()
            switch result {
            case .success(let ratings):
                self?.dataSource = ratings
                self?.tableView.reloadData()
                self?.fetchingView.fetchingState = .fetched
            case .failure(let error):
                self?.fetchingView.fetchingState = .error(error)
            }
        }
    }
}
