//
//  EditProfileQualificationCell.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/2/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class EditProfileQualificationCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var uploadButton: ShadowButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var onAddAction: ((Int)->Void)? {
        didSet {
            dataSource.onAddAction = self.onAddAction
        }
    }
    
    var onDataSourceChange: (([Image])->Void)?
    var onDeleteAction: ((IndexPath)->Void)?
    
    private lazy var dataSource: ImageCollectionDataSource = {
        let dataSource = ImageCollectionDataSource(size: CGSize(width: 100, height: 100), images: [], collectionView: self.collectionView, shouldShowAddOption: false)
        dataSource.onDataSourceChange = { [weak self] items in
            self?.collectionView.isHidden = (items.count == 0)
            self?.onDataSourceChange?(items)
        }
        dataSource.onDeleteAction = { [weak self] selectedIndexPath in
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
        self.uploadButton.color = UIColor.tintBlue
        self.uploadButton.tintColor = .white
        prepareCollectionView()
    }
    
    private func prepareCollectionView() {
       self.collectionView.delegate = dataSource
        self.collectionView.dataSource = dataSource
        self.collectionView.setCollectionViewLayout(flowLayout, animated: false)
        self.collectionView.isHidden = dataSource.dataSource.count == 0
    }
    
    func configure(with title: String, detail: String, actionTitle: String) {
        self.titleLabel.text = title
        self.detailLabel.text = detail
        self.uploadButton.setTitle(actionTitle.uppercased(), for: [])
    }
    
    func insert(image: Image) {
        dataSource.insert(image: image, at: 0)
    }
    
    func add(images: [Image]) {
        dataSource.add(images: images)
    }
    
    func delete(at indexPath: IndexPath) {
        dataSource.delete(at: indexPath)
    }
    
    @IBAction func uploadPhotoAction() {
        self.onAddAction?(dataSource.dataSource.count)
    }
    
}
