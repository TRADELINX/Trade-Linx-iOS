//
//  ImageCollectionDataSource.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/5/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class ImageCollectionDataSource: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var dataSource: [Image] = []
    var onAddAction: ((Int)->Void)?
    var shouldShowAddOption: Bool = true
    var onDataSourceChange: (([Image])->Void)?
    var onDeleteAction: ((IndexPath)->Void)?
    var onItemSelection: ((UIView, IndexPath)->Void)?
    
    var size: CGSize = .zero
    private weak var collectionView: UICollectionView?
    private var deleteImage: UIImage
    private var deleteButtonWidth: CGFloat
    
    var isEditing: Bool = true
    
    init(size: CGSize, images: [Image] = [], collectionView: UICollectionView, shouldShowAddOption: Bool = true, deleteImage: UIImage = #imageLiteral(resourceName: "delete"), deleteButtonWidth: CGFloat = 30) {
        self.size = size
        self.dataSource = images
        self.collectionView = collectionView
        self.shouldShowAddOption = shouldShowAddOption
        self.deleteImage = deleteImage
        self.deleteButtonWidth = deleteButtonWidth
        super.init()
        collectionView.registerNib(ProfileAddCollectionCell.self)
        collectionView.registerNib(ProfileImageCollectionCell.self)
    }
    
    func insert(image: Image, at index: Int) {
        self.dataSource.insert(image, at: index)
        let indexPath = IndexPath(item: index, section: 0)
        self.collectionView?.performBatchUpdates({
            self.collectionView?.insertItems(at: [indexPath])
        }, completion: { (_) in
            self.collectionView?.reloadData()
            self.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        })
        self.onDataSourceChange?(dataSource)
    }
    
    func add(images: [Image]) {
        self.dataSource = images
        self.collectionView?.reloadData()
        self.onDataSourceChange?(dataSource)
    }
    
    func delete(at indexPath: IndexPath) {
        self.dataSource.remove(at: indexPath.item)
        self.collectionView?.performBatchUpdates({
            self.collectionView?.deleteItems(at: [indexPath])
        }, completion: { (_) in
            self.collectionView?.reloadData()
        })
        self.onDataSourceChange?(dataSource)
    }
    
    func handleDelete(at indexPath: IndexPath) {
        let item = dataSource[indexPath.item]
        switch item {
        case .local:
            self.delete(at: indexPath)
            self.onDeleteAction?(indexPath)
        case .remote:
            self.onDeleteAction?(indexPath)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if shouldShowAddOption {
            return dataSource.count + 1
        }
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if shouldShowAddOption {
            if indexPath.item == dataSource.count {
                let cell = collectionView.dequeueReusableCell(ProfileAddCollectionCell.self, for: indexPath)!
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(ProfileImageCollectionCell.self, for: indexPath)!
                cell.configure(with: dataSource[indexPath.item], indexPath: indexPath, deleteImage: self.deleteImage, deleteButtonWidth: self.deleteButtonWidth, isEditing: self.isEditing)
                cell.onDeleteAction = { [weak self] (selectedIndexPath) in
                    self?.handleDelete(at: selectedIndexPath)
                }
                return cell
            }
        } else {
            let cell = collectionView.dequeueReusableCell(ProfileImageCollectionCell.self, for: indexPath)!
            cell.configure(with: dataSource[indexPath.item], indexPath: indexPath, deleteImage: self.deleteImage, deleteButtonWidth: self.deleteButtonWidth, isEditing: self.isEditing)
            cell.onDeleteAction = { [weak self] (selectedIndexPath) in
                self?.handleDelete(at: selectedIndexPath)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == dataSource.count, shouldShowAddOption {
            self.onAddAction?(dataSource.count)
        } else {
            guard let cell = collectionView.cellForItem(at: indexPath) else { return }
            self.onItemSelection?(cell, indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.size
    }
}
