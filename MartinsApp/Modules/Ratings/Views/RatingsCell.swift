//
//  RatingsCell.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/3/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit
import Cosmos

class RatingsCell: UITableViewCell {
    
    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ratingsView: CosmosView!
    
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var timeKeepingRatingLabel: UILabel!
    @IBOutlet weak var timeKeepingRatingView: CosmosView!
    
    @IBOutlet weak var workmanShipRatingLabel: UILabel!
    @IBOutlet weak var workmanShipRatingView: CosmosView!
    
    @IBOutlet weak var communiationRatingLabel: UILabel!
    @IBOutlet weak var communicationRatingView: CosmosView!
    
    @IBOutlet weak var valueRatingLabel: UILabel!
    @IBOutlet weak var valueRatingView: CosmosView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        self.shadowView.shadowOpacity = 0.3
        self.shadowView.shadowRadius = 8
        self.shadowView.cornerRadius = shadowView.frame.height/2
        
        self.profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        self.profileImageView.layer.masksToBounds = true
        self.ratingsView.isUserInteractionEnabled = false
        self.separatorView.backgroundColor = UIColor.seperatorColor
    }
    
    func configure(with rating: Rating, dateFormatter: DateFormatter, formatter: DateComponentsFormatter) {
        self.ratingsView.isHidden = true
        self.nameLabel.text = rating.full_name
        self.descriptionLabel.text = rating.commnet
        self.profileImageView.fetchImage(string: rating.profile_image, placeholder: nil)
        self.ratingsView.rating = Double(rating.rating ?? "0") ?? 0
        self.dateLabel.text = rating.createdAgo(dateFormatter: dateFormatter, formatter: formatter)
        
        self.timeKeepingRatingLabel.text = "Time Keeping :"
        self.workmanShipRatingLabel.text = "Workmanship :"
        self.communiationRatingLabel.text = "Communication :"
        self.valueRatingLabel.text = "Value :"
        
        self.timeKeepingRatingView.rating = Double(rating.time_keeping ?? 0)
        self.workmanShipRatingView.rating = Double(rating.workman_ship ?? 0)
        self.communicationRatingView.rating = Double(rating.communiation ?? 0)
        self.valueRatingView.rating = Double(rating.value ?? 0)
    }
    
}
