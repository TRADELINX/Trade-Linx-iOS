//
//  EditProfileImagesCell.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/3/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class EditProfileImagesCell: UITableViewCell {

    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet weak var profileImageView: RemoteImageView!
    @IBOutlet weak var chooseImageButton: ShadowButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var onProfilePhotoAction: ((Int)->Void)?
    var onAddAction: ((Int)->Void)? {
        didSet {
            dataSource.onAddAction = self.onAddAction
        }
    }
    
    var onDataSourceChanges: (([Image])->Void)?
    var onDeleteAction: ((IndexPath)->Void)?
    
    private lazy var dataSource: ImageCollectionDataSource = {
        let dataSource = ImageCollectionDataSource(size: CGSize(width: 100, height: 100),
                                                   collectionView: self.collectionView)
        dataSource.onDataSourceChange = { [weak self] (images) in
            self?.onDataSourceChanges?(images)
        }
        dataSource.onDeleteAction = { [weak self] (selectedIndexPath) in
            self?.onDeleteAction?(selectedIndexPath)
        }
        return dataSource
    }()
    
    var images: [Image] {
        return dataSource.dataSource
    }
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return layout
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.shadowView.shadowOpacity = 0.3
        self.shadowView.shadowRadius = 8
        self.shadowView.cornerRadius = shadowView.frame.height/2
        
        self.profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        self.profileImageView.layer.masksToBounds = true
        self.profileImageView.contentMode = .scaleAspectFill
        
        self.chooseImageButton.shadowRadius = 4
        self.chooseImageButton.shadowOpacity = 0.3
        
        prepareCollectionView()
    }
    
    private func prepareCollectionView() {
        self.collectionView.delegate = dataSource
        self.collectionView.dataSource = dataSource
        self.collectionView.setCollectionViewLayout(flowLayout, animated: false)
    }
    
    @IBAction func chooseProfileAction() {
        self.onProfilePhotoAction?(0)
    }
    
    func updateProfile(with image: Image) {
        switch image {
        case .local(let image):
            self.profileImageView.image = image
        case .remote(let remoteImage):
            self.profileImageView.urlString = remoteImage.urlString
        }
    }
    
    func insert(image: Image) {
        self.dataSource.insert(image: image, at: 0)
    }
    
    func add(images: [Image]) {
        self.dataSource.add(images: images)
    }
}
