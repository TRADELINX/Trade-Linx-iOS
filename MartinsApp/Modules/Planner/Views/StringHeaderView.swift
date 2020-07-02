//
//  StringHeaderView.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/24/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class StringHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var headerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with title: String) {
        self.headerLabel.text = title
    }

}
