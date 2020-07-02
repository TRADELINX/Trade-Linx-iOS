//
//  UserProfileCell.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/2/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class UserProfileCell: UITableViewCell {

    @IBOutlet weak var profileImageView: RemoteImageView!
    @IBOutlet weak var profileShadowView: ShadowView!
    @IBOutlet weak var photosButton: ShadowButton!
    @IBOutlet weak var certificateButton: ShadowButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var ratingLabel: UILabel!
    
    var onPhotosAction: ((UIView)->Void)?
    var onQualificationAction: ((UIView)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.contentView.backgroundColor = UIColor.tintBlue
        self.clipsToBounds = true
        decorate()
    }
    
    fileprivate func decorate() {
        self.nameLabel.textColor = .white
        
        self.ratingView.layer.cornerRadius = self.ratingView.frame.height/2
        self.ratingView.layer.masksToBounds = true
        
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height/2
        self.profileImageView.layer.masksToBounds = true
        self.profileImageView.shouldShowIndicator = false
        self.profileImageView.placeholder = #imageLiteral(resourceName: "userPlaceholder")
        
        self.profileShadowView.shadowColor = #colorLiteral(red: 0.09411764706, green: 0.1294117647, blue: 0.3098039216, alpha: 1)
        self.profileShadowView.shadowOpacity = 0.3
        self.profileShadowView.shadowRadius = 10
        self.profileShadowView.cornerRadius = self.profileShadowView.frame.height/2
        
        self.certificateButton.shadowColor = #colorLiteral(red: 0.09411764706, green: 0.1294117647, blue: 0.3098039216, alpha: 1)
        self.certificateButton.shadowOpacity = 0.3
        self.certificateButton.shadowRadius = 8
        
        self.photosButton.shadowColor = #colorLiteral(red: 0.09411764706, green: 0.1294117647, blue: 0.3098039216, alpha: 1)
        self.photosButton.shadowOpacity = 0.3
        self.photosButton.shadowRadius = 8
        
        self.photosButton.cornerRadius = self.photosButton.frame.height/2
        self.certificateButton.cornerRadius = self.certificateButton.frame.height/2
    }
    
    func configure(with user: User) {
        self.profileImageView.urlString = user.profileImage
        self.nameLabel.text = user.fullName
        self.ratingLabel.text = "⭐️ \(user.rating ?? "0.0")"
    }
    
    @IBAction func photosAction(_ sender: UIButton) {
        print("Source rect when button pressed: \(sender.frame)")
        self.onPhotosAction?(sender)
    }
    
    @IBAction func qualificationAction(_ sender: UIButton) {
        self.onQualificationAction?(sender)
    }
    
}
