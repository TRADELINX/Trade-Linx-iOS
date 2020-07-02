//
//  UIImageSelector.swift
//  MartinsApp
//
//  Created by Neil Jain on 10/10/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class UIImageSelector: UIView {
    
    var onPhotoUploadAction: (()->Void)?
    var onPhotoSelection: ((UIView, IndexPath)->Void)?
    
    var itemSize: CGSize = CGSize(width: 50, height: 50) {
        didSet {
            self.dataSource.size = self.itemSize
        }
    }
    
    var shouldShowSeperator: Bool = true {
        didSet {
            self.seperatorLine.isHidden = !self.shouldShowSeperator
        }
    }
    
    var isEditing: Bool = true {
        didSet {
            self.uploadButton.isHidden = !self.isEditing
            self.collectionView.isHidden = !self.isEditing
            self.dataSource.isEditing = self.isEditing
        }
    }
    
    var images: [UIImage] {
        return self.dataSource.dataSource.compactMap({$0.renderImage})
    }

    lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 8
        flowLayout.minimumInteritemSpacing = 8
        return flowLayout
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.appBackground
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return collectionView
    }()
    
    lazy var uploadButton: ShadowButton = {
        let button = ShadowButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("UPLOAD PHOTO", for: [])
        button.addTarget(self, action: #selector(uploadPhotoAction), for: .touchUpInside)
        button.color = UIColor.tintBlue
        button.tintColor = .white
        button.isCircular = false
        button.cornerRadius = 4
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return button
    }()
    
    lazy var seperatorLine: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.backgroundColor = UIColor.seperatorColor
        return view
    }()
    
    fileprivate func updateUIState(for images: [Image]) {
        let condition = images.count > 0
        self.uploadButton.isHidden = condition
        self.collectionView.isHidden = !condition
    }
    
    lazy var dataSource: ImageCollectionDataSource = {
        let dataSource = ImageCollectionDataSource(
            size: self.itemSize,
            images: [],
            collectionView: self.collectionView,
            shouldShowAddOption: false,
            deleteImage: #imageLiteral(resourceName: "cancel_filled").withRenderingMode(.alwaysTemplate),
            deleteButtonWidth: 18
        )
        dataSource.isEditing = self.isEditing
        dataSource.onAddAction = { [weak self] itemsCount in
            self?.onPhotoUploadAction?()
        }
        dataSource.onDataSourceChange = { [weak self] items in
            self?.updateUIState(for: items)
        }
        dataSource.onDeleteAction = { [weak self] _ in
            self?.updateUIState(for: self?.dataSource.dataSource ?? [])
        }
        dataSource.onItemSelection = { [weak self] (sourceView, indexPath) in
            self?.onPhotoSelection?(sourceView, indexPath)
        }
        return dataSource
    }()
    
    @objc func uploadPhotoAction(_ sender: IndicatorButton) {
        self.onPhotoUploadAction?()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.addSubview(collectionView)
        collectionView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        self.addSubview(uploadButton)
        uploadButton.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        uploadButton.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor).isActive = true
        uploadButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        uploadButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        uploadButton.widthAnchor.constraint(equalToConstant: 140).isActive = true
        
        self.addSubview(seperatorLine)
        seperatorLine.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        seperatorLine.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        seperatorLine.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        self.collectionView.isHidden = true
        self.collectionView.delegate = dataSource
        self.collectionView.dataSource = dataSource
        self.seperatorLine.isHidden = self.shouldShowSeperator
    }
    
    func addImage(_ image: UIImage) {
        self.dataSource.insert(image: Image.local(image), at: 0)
    }
    
    func removeImage(at index: Int) {
        self.dataSource.delete(at: IndexPath(row: index, section: 0))
    }

}
