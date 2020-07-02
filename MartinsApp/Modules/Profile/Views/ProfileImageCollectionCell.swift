//
//  ProfileImageCollectionCell.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/3/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class ProfileImageCollectionCell: UICollectionViewCell {

    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet weak var imageView: RemoteImageView!
    @IBOutlet weak var deleteButton: ShadowButton!
    @IBOutlet var buttonWidthConstraint: NSLayoutConstraint!
    @IBOutlet var buttonTopConstraint: NSLayoutConstraint!
    @IBOutlet var buttonRightConstraint: NSLayoutConstraint!
    @IBOutlet var imageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var imageTopConstraint: NSLayoutConstraint!
    
    var indexPath: IndexPath?
    var onDeleteAction: ((IndexPath)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.shadowView.cornerRadius = 8
        self.shadowView.shadowOpacity = 0.5
        self.shadowView.shadowRadius = 6
        
        self.imageView.layer.cornerRadius = 8
        self.imageView.layer.masksToBounds = true
        self.deleteButton.imageView?.tintColor = UIColor.tintBlue
    }
    
    func configure(with image: Image, indexPath: IndexPath, deleteImage: UIImage, deleteButtonWidth: CGFloat, isEditing: Bool) {
        self.deleteButton.setImage(deleteImage, for: [])
        let buttonWidth = isEditing ? deleteButtonWidth : 0
        self.buttonWidthConstraint.constant = buttonWidth
        self.buttonTopConstraint.constant = -(buttonWidth/2)
        self.buttonRightConstraint.constant = (buttonWidth/2)
        self.imageLeadingConstraint.constant = buttonWidth/2
        self.imageTopConstraint.constant = buttonWidth/2
        self.deleteButton.isHidden = !isEditing
        if let renderImage = image.renderImage {
            self.imageView.image = renderImage
        } else if let urlString = image.urlString {
            self.imageView.urlString = urlString
        }
        self.indexPath = indexPath
    }
    
    @IBAction func deleteAction() {
        guard let indexPath = self.indexPath else { return }
        self.onDeleteAction?(indexPath)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.cancelRequest()
    }
    
}
