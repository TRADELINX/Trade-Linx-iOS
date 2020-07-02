//
//  ConversationHeaderView.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/27/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class ConversationHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var decorationView: UIView!
    @IBOutlet weak var dateTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with string: String) {
        self.dateTimeLabel.text = string
    }

}
