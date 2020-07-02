//
//  ReceiveMessageCell.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/27/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class ReceiveMessageCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UITextView!
    @IBOutlet weak var decorationView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.messageLabel.textContainerInset = .zero
        self.decorationView.layer.cornerRadius = 16
        self.decorationView.layer.borderWidth = 0.2
        self.decorationView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        self.decorationView.layer.shadowColor = UIColor.groupTableViewBackground.cgColor
        self.decorationView.layer.shadowOpacity = 1
        self.decorationView.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.decorationView.layer.shadowRadius = 8
        
        self.decorationView.backgroundColor = UIColor.appBackground
        
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height/2
        self.profileImageView.layer.masksToBounds = true
        self.profileImageView.layer.borderColor = UIColor.tintBlue.cgColor
        self.profileImageView.layer.borderWidth = 1
        self.profileImageView.contentMode = .scaleAspectFill
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if #available(iOS 13.0, *) {
            self.decorationView.layer.shadowColor = UIColor.shadowColor.resolvedColor(with: self.traitCollection).cgColor
            if self.traitCollection.userInterfaceStyle == .dark {
                self.decorationView.layer.shadowOffset = CGSize(width: 0, height: 2)
                self.decorationView.layer.shadowRadius = 4
                self.decorationView.layer.borderColor = UIColor.darkGray.cgColor
                self.decorationView.layer.borderWidth = 0.4
            } else {
                self.decorationView.layer.shadowOffset = CGSize(width: 0, height: 4)
                self.decorationView.layer.shadowRadius = 8
                self.decorationView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
                self.decorationView.layer.borderWidth = 0.2
            }
        } else {
            self.decorationView.layer.shadowColor = UIColor.shadowColor.cgColor
            self.decorationView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        }
        
    }
    
    func configure(with conversation: Conversation, profileImage: String?, dateFormatter: DateFormatter) {
        self.messageLabel.text = conversation.message
        self.timeLabel.text = conversation.time(using: dateFormatter)
        self.profileImageView.fetchImage(string: profileImage, placeholder: nil)
        switch conversation.position {
        case .top:
            self.profileImageView.isHidden = false
            self.decorationView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner]
        case .middle:
            self.profileImageView.isHidden = true
            self.decorationView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        case .bottom:
            self.profileImageView.isHidden = true
            self.decorationView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        }
    }
    
}
