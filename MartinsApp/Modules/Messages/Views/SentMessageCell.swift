//
//  SentMessageCell.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/27/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class SentMessageCell: UITableViewCell {

    @IBOutlet weak var decorationView: UIView!
    @IBOutlet weak var messageLabel: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.decorationView.layer.cornerRadius = 16
        self.messageLabel.textContainerInset = .zero
    }
    
    func configure(with conversation: Conversation, dateFormatter: DateFormatter) {
        self.messageLabel.text = conversation.message
        self.timeLabel.text = conversation.time(using: dateFormatter)
        switch conversation.position {
        case .top:
            self.decorationView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        case .middle:
            self.decorationView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        case .bottom:
            self.decorationView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    
}
