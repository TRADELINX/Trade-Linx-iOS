//
//  RemoteSelectionViewController.swift
//
//  Created by Neil Jain on 3/30/19.
//  Copyright © 2019 Neil Jain. All rights reserved.
//

import UIKit

//class RemoteSelectionViewController<A: SelectionProvider & Codable>: SelectionViewController<A> {
//    typealias DependencyProvider = WebResourceProvider
//    var provider: DependencyProvider!
//
//    var shouldSort: Bool = true
//
//    private lazy var loginButton: LoginButton = {
//        let loginButton = LoginButton()
//        loginButton.coordinator = self.coordinator
//        return loginButton
//    }()
//
//    private lazy var retryButton: RefreshButton = {
//        let retryButton = RefreshButton()
//        retryButton.addTarget(self, action: #selector(fetchDataSource), for: .touchUpInside)
//        return retryButton
//    }()
//
//    init(provider: DependencyProvider, selectedItems: [A]?, allowsMultipleSelection: Bool = false, selectionHandler: @escaping (([A])->Void)) {
//        self.provider = provider
//        super.init(items: [], selectedItems: selectedItems, allowsMultipleSelection: allowsMultipleSelection, style: UITableView.Style.plain, selectionHandler: selectionHandler)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//
//    private var fetchingState: FetchingState<[A]> = .request(.fetching) {
//        didSet {
//            self.validate(fetchingState)
//        }
//    }
//
//    private lazy var fetchingView: FetchingView = {
//        return FetchingView(listView: self.tableView, parentView: self.view)
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.fetchDataSource()
//    }
//
//    deinit {
//        print("Deinit called from Remote Selection View Controller")
//    }
//
//    @objc func fetchDataSource() {
//        guard let resource = self.resource else { return }
//        self.fetchingState = .fetching
//        self.requestToken?.cancel()
//        requestToken = resource.request(completion: { [weak self] (result) in
//            guard let weakSelf = self else { return }
//            switch result {
//            case .value(let response):
//                if var data = response.data, data.count > 0 {
//                    if weakSelf.shouldSort {
//                        data.sort(by: { (item1, item2) -> Bool in
//                            return item1.description < item2.description
//                        })
//                    }
//                    weakSelf.fetchingState = .fetched(data)
//                } else {
//                    weakSelf.fetchingState = .error(AppError.noRecords(image: nil, title: "No records founds", message: nil))
//                }
//            case .error(let error):
//                weakSelf.fetchingState = .error(error)
//            }
//        })
//    }
//
//    private func validate(_ state: FetchingState<[A]>) {
//        switch state {
//        case .fetching:
//            self.fetchingView.fetchingState = .fetching
//        case .fetched(let dataSource):
//            self.fetchingView.fetchingState = .fetched
//            self.items = dataSource
//            self.setupForAlreadySelectedData()
//            self.tableView.reloadData()
//        case .error(let error):
//            self.fetchingView.fetchingState = .error(error)
//            if error == AppError.sessionExpired {
//                self.fetchingView.add([self.loginButton])
//            } else {
//                self.fetchingView.add([self.retryButton])
//            }
//        case .refreshing:
//            break
//        }
//    }
//
//}
