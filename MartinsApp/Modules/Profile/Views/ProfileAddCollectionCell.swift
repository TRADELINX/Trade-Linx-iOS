//
//  ProfileAddCollectionCell.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/3/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class ProfileAddCollectionCell: UICollectionViewCell {

    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet weak var addButton: ShadowButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.shadowView.cornerRadius = 8
        self.shadowView.shadowOpacity = 0.3
        self.shadowView.shadowRadius = 6
        
        self.addButton.isUserInteractionEnabled = false
    }

}
