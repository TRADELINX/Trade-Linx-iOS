//
//  TextCell.swift
//  MartinsApp
//
//  Created by Neil Jain on 12/15/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class TextCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func configure(with description: String) {
        self.descriptionLabel.text = description
    }
    
}
