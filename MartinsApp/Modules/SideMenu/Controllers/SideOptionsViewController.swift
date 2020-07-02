//
//  SideOptionsViewController.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/1/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class SideOptionsViewController: UIViewController {

    typealias DependencyProvider = UserManagerProvider
    var provider: DependencyProvider!
    var onItemSelection: ((SideMenuItem)->Void)?
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: [SideMenuRowType] = []
    private var selectedSideMenuItem: SideMenuItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTableView()
        setupDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let selectedIndexPath = self.tableView.indexPathForSelectedRow ?? IndexPath(row: 0, section: 0)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tableView.reloadData()
        self.tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
        if let selectedSideMenuItem = self.selectedSideMenuItem {
            self.selectSideOption(selectedSideMenuItem)
            self.selectedSideMenuItem = nil
        }
    }
    
    deinit {
        print("Deinit called from SideOptionsViewController")
    }
    
    private func prepareTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.registerNib(SideProfileCell.self)
        self.tableView.registerNib(SideMenuItemCell.self)
        self.tableView.registerNib(SideProfileHeaderView.self)
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.contentInsetAdjustmentBehavior = .never
        self.tableView.estimatedRowHeight = 102
        self.tableView.separatorStyle = .none
        self.tableView.showsVerticalScrollIndicator = false
    }
    
    private func setupDataSource() {
        self.dataSource = SideMenuRowType.dataSource(for: provider.userManager.currentUser!)
    }
    
    func selectSideOption(_ option: SideMenuItem) {
        if dataSource.count > 0 {
            guard let index = self.dataSource.firstIndex(where: {$0.sideMenuItem == option}) else { return }
            self.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
        } else {
            self.selectedSideMenuItem = option
        }
    }

}

extension SideOptionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = self.dataSource[indexPath.row]
        switch row {
        case .profile(let profileRow):
            print(profileRow.value)
        case .item(let itemRow):
            self.onItemSelection?(itemRow.value)
            DispatchQueue.main.async {
                self.navigationController?.dismiss(animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(SideProfileHeaderView.self)
        view?.configure(with: provider.userManager.currentUser!)
        view?.onTapAction = { [weak self] in
            guard let self = self else { return }
            AppLogViewController.present(using: self)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 138
    }
}

extension SideOptionsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = dataSource[indexPath.row]
        switch row {
        case .profile(let profileRow):
            let cell = profileRow.dequeueReusableCell(from: tableView, at: indexPath)!
            cell.configure(with: profileRow.value)
            return cell
        case .item(let itemRow):
            let cell = itemRow.dequeueReusableCell(from: tableView, at: indexPath)!
            cell.configure(with: itemRow.value)
            return cell
        }
    }
}

extension SideOptionsViewController {
    static func initialise(provider: DependencyProvider) -> SideOptionsViewController {
        let vc = SideOptionsViewController.instantiate(from: .main)
        vc.provider = provider
        return vc
    }
}
