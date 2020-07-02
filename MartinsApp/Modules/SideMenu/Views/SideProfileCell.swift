//
//  SideProfileCell.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/1/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class SideProfileCell: UITableViewCell {

    @IBOutlet weak var dashedView: DashedBorderView!
    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.dashedView.borderColor = UIColor.tintBlue
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height/2
        self.profileImageView.layer.masksToBounds = true
        self.shadowView.cornerRadius = self.shadowView.frame.height/2
        self.selectionStyle = .none
    }
    
    func configure(with user: User) {
        
    }
    
}
