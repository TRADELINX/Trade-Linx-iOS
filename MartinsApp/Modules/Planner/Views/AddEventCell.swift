//
//  AddEventCell.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/30/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class AddEventCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var fromTimeField: UnderlineTextField!
    @IBOutlet weak var toTimeField: UnderlineTextField!
    
    var onStartTimeChange: ((String)->Void)?
    var onEndTimeChange: ((String)->Void)?
    
    var minimumDate: Date?
    var shouldApplyMinDate: Bool = false
    private var selectedFromDate: Date?
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.addTarget(self, action: #selector(dateAction), for: .valueChanged)
        return picker
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter
    }()
    
    func formattedDate(_ date: Date) -> String {
        return dateFormatter.fixedTimeString(from: date)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.fromTimeField.lineHeight = 2
        self.toTimeField.lineHeight = 2
        self.fromTimeField.inputView = datePicker
        self.toTimeField.inputView = datePicker
        
        self.fromTimeField.onResignFirstResponder = { [weak self] in
            guard let `self` = self else { return }
            `self`.datePicker.minimumDate = self.selectedFromDate
        }
        self.toTimeField.onResignFirstResponder = { [weak self] in
            guard let `self` = self else { return }
            `self`.datePicker.minimumDate = nil
        }
        self.fromTimeField.onBecomeFirstResponder = { [weak self] in
            guard let `self` = self else { return }
            `self`.fromTimeField.text = `self`.dateFormatter.userFacingTimeString(from: `self`.datePicker.date)
            `self`.onStartTimeChange?(`self`.formattedDate(`self`.datePicker.date))
        }
        self.toTimeField.onBecomeFirstResponder = { [weak self] in
            guard let `self` = self else { return }
            `self`.toTimeField.text = self.dateFormatter.userFacingTimeString(from: `self`.datePicker.date)
            `self`.onEndTimeChange?(`self`.formattedDate(`self`.datePicker.date))
        }
    }
    
    func set(fromTime: String, toTime: String) {
        if let fromDate = dateFormatter.timeForUserFacingLocale(from: fromTime) {
            fromTimeField.text = fromTime
            self.onStartTimeChange?(formattedDate(fromDate))
        }
        if let toDate = dateFormatter.timeForUserFacingLocale(from: toTime) {
            toTimeField.text = toTime
            self.onEndTimeChange?(formattedDate(toDate))
        }
    }
    
    func configure(with title: String, fromValue: FieldValue, toValue: FieldValue) {
        self.titleLabel.text = title
        self.fromTimeField.placeholder = fromValue.placeholder
        self.fromTimeField.text = fromValue.value
        self.toTimeField.placeholder = toValue.placeholder
        self.toTimeField.text = toValue.value
    }
    
    @objc func dateAction(_ sender: UIDatePicker) {
        if fromTimeField.isFirstResponder {
            self.selectedFromDate = sender.date
            fromTimeField.text = self.dateFormatter.userFacingTimeString(from: sender.date)
            self.onStartTimeChange?(formattedDate(sender.date))
        }
        if toTimeField.isFirstResponder {
            toTimeField.text = self.dateFormatter.userFacingTimeString(from: sender.date)
            self.onEndTimeChange?(formattedDate(sender.date))
        }
    }
    
}
