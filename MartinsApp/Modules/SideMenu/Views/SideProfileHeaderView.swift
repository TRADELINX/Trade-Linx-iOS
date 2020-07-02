//
//  SideProfileHeaderView.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/5/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class SideProfileHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var dashedView: DashedBorderView!
    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet weak var profileImageView: RemoteImageView!
    @IBOutlet weak var seperatorView: UIView!
    
    var onTapAction: (()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.dashedView.borderColor = UIColor.tintBlue
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height/2
        self.profileImageView.layer.masksToBounds = true
        self.profileImageView.shouldShowIndicator = false
        self.shadowView.cornerRadius = self.shadowView.frame.height/2
        if #available(iOS 13.0, *) {
            self.contentView.backgroundColor = UIColor.systemBackground
            self.shadowView.color = UIColor.systemBackground
            self.seperatorView.backgroundColor = UIColor.shadowColor
        }
        
        if AppConfig.shouldDisplayDebugMessage {
            self.profileImageView.isUserInteractionEnabled = true
            self.profileImageView.addGestureRecognizer(tapGesture)
        }
    }
    
    func configure(with user: User) {
        self.profileImageView.placeholder = #imageLiteral(resourceName: "userPlaceholder")
        self.profileImageView.urlString = user.profileImage
    }
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tapGesture.numberOfTapsRequired = 7
        return tapGesture
    }()
    
    @objc private func tapAction() {
        self.onTapAction?()
    }

}
