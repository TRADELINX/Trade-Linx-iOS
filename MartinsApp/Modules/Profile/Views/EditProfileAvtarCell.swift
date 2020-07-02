//
//  EditProfileAvtarCell.swift
//  MartinsApp
//
//  Created by Neil Jain on 10/21/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class EditProfileAvtarCell: UITableViewCell {

    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet weak var profileImageView: RemoteImageView!
    @IBOutlet weak var chooseImageButton: ShadowButton!
    
    var onProfilePhotoAction: ((Int)->Void)?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        self.shadowView.shadowOpacity = 0.3
        self.shadowView.shadowRadius = 8
        self.shadowView.cornerRadius = shadowView.frame.height/2
        
        self.profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        self.profileImageView.layer.masksToBounds = true
        self.profileImageView.contentMode = .scaleAspectFill
        
        self.chooseImageButton.shadowRadius = 4
        self.chooseImageButton.shadowOpacity = 0.3
    }
    
    @IBAction func chooseProfileAction() {
        self.onProfilePhotoAction?(0)
    }
    
    func updateProfile(with image: Image) {
        switch image {
        case .local(let image):
            self.profileImageView.image = image
        case .remote(let remoteImage):
            self.profileImageView.urlString = remoteImage.urlString
        }
    }

    
}
