//
//  MessageItemCell.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/3/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class MessageItemCell: UITableViewCell {

    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var badgeLabel: BadgeLabel!
    @IBOutlet weak var updatedTimeLabel: UILabel!
    @IBOutlet weak var seperatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.shadowView.shadowOpacity = 0.3
        self.shadowView.shadowRadius = 8
        self.shadowView.cornerRadius = shadowView.frame.height/2
        
        self.profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        self.profileImageView.layer.masksToBounds = true
        self.badgeLabel.isHidden = true
        self.contentView.backgroundColor = UIColor.appBackground
        self.seperatorView.backgroundColor = UIColor.seperatorColor
        
        if #available(iOS 13.0, *) {
            self.shadowView.color = .systemBackground
        }
    }
    
    func configure(with messageItem: MessageItem, dateFormatter: DateFormatter) {
        self.nameLabel.text = messageItem.full_name
        self.lastMessageLabel.text = messageItem.message
        self.lastMessageLabel.numberOfLines = 1
        self.lastMessageLabel.lineBreakMode = .byTruncatingTail
        self.updatedTimeLabel.text = messageItem.updated_at
        self.profileImageView.fetchImage(string: messageItem.profile_image, placeholder: nil)
    }
    
    func configure(with notificationItem: NotificationItem, dateFormatter: DateFormatter) {
        self.lastMessageLabel.numberOfLines = 0
        self.lastMessageLabel.lineBreakMode = .byWordWrapping
        self.nameLabel.text = notificationItem.full_name
        self.lastMessageLabel.text = notificationItem.message
        self.profileImageView.fetchImage(string: notificationItem.profile_image, placeholder: nil)
        self.updatedTimeLabel.text = notificationItem.createdDate(dateFormatter: dateFormatter)
    }
    
}
