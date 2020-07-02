//
//  ProfileReadOnlyImagesCell.swift
//  MartinsApp
//
//  Created by Neil Jain on 10/10/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class ProfileReadOnlyImagesCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageSelector: UIImageSelector!
    @IBOutlet weak var seperatorView: UIView!
    
    var onImageSelection: ((UIView, IndexPath)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.imageSelector.isEditing = false
        self.imageSelector.itemSize = CGSize(width: 70, height: 70)
        self.titleLabel.textColor = UIColor.seperatorGray
        self.seperatorView.backgroundColor = UIColor.seperatorColor
        self.imageSelector.shouldShowSeperator = false
        self.imageSelector.onPhotoSelection = { [weak self] sourceView, indexPath in
            self?.onImageSelection?(sourceView, indexPath)
        }
    }
    
    func configure(withTitle title: String, images: [Image]) {
        self.titleLabel.text = title.uppercased()
        self.imageSelector.dataSource.add(images: images)
    }
    
}
