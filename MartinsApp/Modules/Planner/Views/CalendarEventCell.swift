//
//  CalendarEventCell.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/24/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class CalendarEventCell: UITableViewCell {

    @IBOutlet weak var decorationView: ShadowView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        self.indicatorView.layer.cornerRadius = self.indicatorView.frame.width/2
        self.indicatorView.layer.masksToBounds = true
        self.decorationView.shadowOpacity = 0.4
        self.decorationView.shadowRadius = 8
        self.decorationView.shadowOffset = CGSize(width: 0, height: 1)
        self.decorationView.color = UIColor.appBackground
    }
    
    func configure(with event: Event) {
        self.indicatorView.backgroundColor = event.color
        self.dateLabel.text = event.date
        self.descriptionLabel.text = event.description
        self.startTimeLabel.text = event.startTime
        self.endTimeLabel.text = event.endTime
    }
    
}
