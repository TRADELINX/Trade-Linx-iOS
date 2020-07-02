//
//  OnboardingCell.swift
//  MartinsApp
//
//  Created by Neil on 11/04/20.
//  Copyright © 2020 Ratnesh Jain. All rights reserved.
//

import UIKit

class OnboardingCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with item: OnboardingItem) {
        self.imageView.image = item.image
        self.titleLabel.text = item.title
        self.subtitleLabel.text = item.subtitle
    }

}
