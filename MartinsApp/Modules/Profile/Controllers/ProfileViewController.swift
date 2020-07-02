//
//  ProfileViewController.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/2/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    typealias DependencyProvider = UserManagerProvider & WebResourceProvider
    var provider: DependencyProvider!
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: [UserProfileRowType] = []
    
    var user: User {
        return provider.userManager.currentUser!
    }
    
    lazy var settingsItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: #imageLiteral(resourceName: "setting"), style: .plain, target: self, action: #selector(editProfileAction))
        return item
    }()
    
    lazy var activityItem: UIBarButtonItem = {
        let activityView = UIActivityIndicatorView(style: .white)
        activityView.hidesWhenStopped = true
        activityView.startAnimating()
        let item = UIBarButtonItem(customView: activityView)
        return item
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.navigationItem.rightBarButtonItem = settingsItem
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.navigationItem.rightBarButtonItem = settingsItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchDetails()
        prepareDataSource()
        self.tableView.reloadData()
    }
    
    deinit {
        print("Deinit called from ProfileViewController")
    }
    
    private func prepareDataSource() {
        self.dataSource = UserProfileRowType.dataSource(for: user)
    }
    
    private func prepareTableView() {
        self.view.backgroundColor = UIColor.tintBlue
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.registerNib(UserProfileCell.self)
        self.tableView.registerNib(UserDetailCell.self)
        self.tableView.registerNib(ProfileReadOnlyImagesCell.self)
        
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 102
        self.tableView.separatorStyle = .none
    }
    
    private func updateStates(_ isFetching: Bool) {
        // Since this is a contaiment view controller,
        // parent owns the navigation bar.
        // To manipulate the navigation item
        // need to access parent's navigation item.
        self.parent?.navigationItem.rightBarButtonItem = isFetching ? self.activityItem : self.settingsItem
        self.parent?.navigationItem.rightBarButtonItem?.isEnabled = !isFetching
    }
    
    @objc func editProfileAction() {
        let vc = EditProfileViewController.initialise(provider: self.provider)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func handlePhotosAction(sender: UIView) {
        let workImages = [user.insuranceImageURLString].compactMap({$0})
        //guard let workImages = user.userWorkImages?.compactMap({$0.image}) else { return }
        let vc = PreviewViewController(title: "Insurance",image: #imageLiteral(resourceName: "workImagePlaceholder"), items: workImages)
        vc.title = "Insurance".uppercased()
        let senderRect = sender.superview?.convert(sender.frame, to: self.tableView.window) ?? sender.frame
        let previewController = ZoomPreviewController(rootVC: vc, sourceView: sender, sourceRect: senderRect)
        self.present(previewController, animated: true, completion: nil)
    }
    
    func handleQualificationAction(sender: UIView) {
        guard let qualifications = user.userQualifications?.compactMap({$0.image}) else { return }
        let vc = PreviewViewController(title: "Qualifications", image: #imageLiteral(resourceName: "qualificationPlaceHolder"), items: qualifications)
        vc.title = "Qualifications".uppercased()
        let senderRect = sender.superview?.convert(sender.frame, to: self.tableView.window) ?? sender.frame
        let previewController = ZoomPreviewController(rootVC: vc, sourceView: sender, sourceRect: senderRect)
        self.present(previewController, animated: true, completion: nil)
    }
    
    func handleImageSelection(sender: UIView, indexPath: IndexPath, selectedIndexPath: IndexPath) {
        let item = self.dataSource[indexPath.row]
        switch item {
        case .images(let row):
            let image = row.value.1.compactMap({$0.urlString})
            let vc = PreviewViewController(title: row.value.0, image: nil, items: image, selectedItem: image[safe: selectedIndexPath.item])
            vc.title = row.value.0.uppercased()
            let senderRect = sender.superview?.convert(sender.frame, to: self.tableView.window) ?? sender.frame
            let previewController = ZoomPreviewController(rootVC: vc, sourceView: sender, sourceRect: senderRect)
            self.present(previewController, animated: true, completion: nil)

        default: break
        }
    }
    
}

// MARK: - Initialising with Dependency
extension ProfileViewController {
    static func initialise(provider: DependencyProvider) -> ProfileViewController {
        let vc = ProfileViewController.instantiate(from: .main)
        vc.provider = provider
        vc.title = "My Profile".uppercased()
        return vc
    }
}

// MARK: - TableView Delegate
extension ProfileViewController: UITableViewDelegate {
    
}

// MARK: - TableView DataSource
extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.dataSource[indexPath.row]
        switch row {
        case .profile(let profileRow):
            let cell = profileRow.dequeueReusableCell(from: tableView, at: indexPath)!
            cell.onPhotosAction = { [weak self] (sender) in
                self?.handlePhotosAction(sender: sender)
            }
            cell.onQualificationAction = { [weak self] (sender) in
                self?.handleQualificationAction(sender: sender)
            }
            cell.configure(with: profileRow.value)
            return cell
        case .detail(let detailRow):
            let cell = detailRow.dequeueReusableCell(from: tableView, at: indexPath)!
            cell.configure(with: detailRow.value.0, detail: detailRow.value.1)
            return cell
        case .images(let imagesRow):
            let cell = imagesRow.dequeueReusableCell(from: tableView, at: indexPath)!
            cell.configure(withTitle: imagesRow.value.0, images: imagesRow.value.1)
            cell.onImageSelection = { [weak self] sourceView, selectedIndexPath in
                self?.handleImageSelection(sender: sourceView, indexPath: indexPath, selectedIndexPath: selectedIndexPath)
            }
            return cell
        }
    }
}

// MARK: - API
extension ProfileViewController {
    func fetchDetails() {
        self.updateStates(true)
        provider.webResource.getProfile { [weak self] (result) in
            self?.updateStates(false)
            switch result {
            case .success(_):
                self?.prepareDataSource()
                self?.tableView.reloadData()
            case .failure(let error):
                self?.showAlert(for: error)
            }
        }
    }
}

// MARK: - Scrolling Behaviour Adjustment
extension ProfileViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        if let cell = tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? UserProfileCell {
            if yOffset < 0 {
                cell.frame.origin.y = yOffset
                cell.profileShadowView.layer.transform = CATransform3DMakeTranslation(0, -yOffset/10, 0)
                let translate = CATransform3DMakeTranslation(0, -yOffset/15, 0)
                let scale = CATransform3DMakeScale(1 + (yOffset/700), 1 + (yOffset/700), 0)
                cell.nameLabel.layer.transform = CATransform3DConcat(translate, scale)
                cell.ratingView.layer.transform = CATransform3DConcat(translate, scale)
            } else {
                let translation = CATransform3DMakeScale(1 + yOffset/500, 1 + yOffset/500, 0)
                cell.profileShadowView.layer.transform = translation
                cell.nameLabel.layer.transform = translation
                if yOffset > 145 {
                    self.parent?.navigationItem.title = user.fullName
                } else {
                    self.parent?.navigationItem.title = "MY PROFILE"
                }
            }
        }
    }
}
