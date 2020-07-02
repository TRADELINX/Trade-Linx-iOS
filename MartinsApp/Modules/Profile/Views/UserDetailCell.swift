//
//  UserDetailCell.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/2/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class UserDetailCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var seperatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.textColor = UIColor.seperatorGray
        self.selectionStyle = .none
        self.seperatorView.backgroundColor = UIColor.seperatorColor
    }
    
    func configure(with title: String, detail: String?) {
        self.titleLabel.text = title.uppercased()
        self.detailLabel.text = detail
    }
    
}
