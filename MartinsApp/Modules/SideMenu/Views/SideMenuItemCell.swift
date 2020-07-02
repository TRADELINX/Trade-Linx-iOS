//
//  SideMenuItemCell.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/1/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class SideMenuItemCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectionIndicator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.selectionIndicator.layer.cornerRadius = self.selectionIndicator.frame.height/2
        self.selectionIndicator.layer.masksToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionIndicator.isHidden = !selected
    }
    
    func configure(with item: SideMenuItem) {
        self.itemImageView.image = item.image
        self.titleLabel.text = item.name
    }
    
}
