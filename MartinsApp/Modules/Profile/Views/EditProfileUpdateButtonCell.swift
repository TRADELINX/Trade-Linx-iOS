//
//  EditProfileUpdateButtonCell.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/2/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class EditProfileUpdateButtonCell: UITableViewCell {

    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet weak var updateButton: IndicatorButton!
    
    var onAction: ((IndicatorButton)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        shadowView.shadowOpacity = 0.3
        shadowView.shadowRadius = 8
        shadowView.shadowOffset = CGSize(width: 0, height: 2)
        updateButton.layer.cornerRadius = shadowView.cornerRadius
        updateButton.layer.masksToBounds = true
        shadowView.color = UIColor.appBackground
        if #available(iOS 13.0, *) {
            updateButton.setTitleColor(UIColor.label, for: [])
            updateButton.tintColor = UIColor.label
        }
    }
    
    func configure(with title: String) {
        self.updateButton.setTitle(title.uppercased(), for: [])
    }
    
    @IBAction func updateAction(_ sender: IndicatorButton) {
        self.onAction?(sender)
    }
    
}
