//
//  DateCell.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/22/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DateCell: JTACDayCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var mainSelectionView: UIView!
    @IBOutlet weak var rightSelectionView: UIView!
    @IBOutlet weak var leftSelectionView: UIView!
    @IBOutlet weak var dotView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainSelectionView.layer.cornerRadius = 44/2
        mainSelectionView.layer.masksToBounds = true
        dotView.layer.cornerRadius = dotView.frame.height/2
        dotView.layer.masksToBounds = true
        mainSelectionView.isHidden = true
        rightSelectionView.isHidden = true
        dotView.isHidden = true
    }
    
    func configure(with text: String, cellState: CellState, startDate: Date?) {
        if cellState.dateBelongsTo == .thisMonth && cellState.day != .sunday {
            if #available(iOS 13.0, *) {
                self.label.textColor = UIColor.label
            } else {
                self.label.textColor = UIColor.black
            }
        } else {
            self.label.textColor = UIColor.lightGray
        }
        if let startDate = startDate, cellState.date.removingTimeComponent < startDate.removingTimeComponent {
            self.label.textColor = UIColor.lightGray
        }
        self.label.text = text
        select(for: cellState)
    }
    
    func handleEvents(cellState: CellState, isSlotAvailable: Bool) {
        if isSlotAvailable {
            self.dotView.isHidden = false
        } else {
            self.dotView.isHidden = true
        }
    }
    
    private func select(for cellState: CellState) {
        self.mainSelectionView.isHidden = !cellState.isSelected
        self.leftSelectionView.isHidden = true
        self.rightSelectionView.isHidden = true
        
        switch cellState.selectedPosition() {
        case .left:
            self.label.textColor = .white
            self.mainSelectionView.isHidden = false
            self.leftSelectionView.isHidden = true
            self.rightSelectionView.isHidden = false
        case .middle:
            self.label.textColor = .black
            self.mainSelectionView.isHidden = true
            self.leftSelectionView.isHidden = false
            self.rightSelectionView.isHidden = false
        case .right:
            self.label.textColor = .white
            self.mainSelectionView.isHidden = false
            self.rightSelectionView.isHidden = true
            self.leftSelectionView.isHidden = false
            break
        case .full:
            self.label.textColor = .white
            self.mainSelectionView.isHidden = false
            self.leftSelectionView.isHidden = true
            self.rightSelectionView.isHidden = true
            break
        case .none:
            break
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

}
