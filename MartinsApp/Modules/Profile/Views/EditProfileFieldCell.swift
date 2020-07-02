//
//  EditProfileFieldCell.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/2/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class EditProfileFieldCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UnderlineTextField!
    
    var indexPath: IndexPath?
    var onTextChange: ((IndexPath, String?) -> Void)?
    var onSelection: ((IndexPath)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        self.textField.onTextChange = { [weak self] (text) in
            guard let indexPath = self?.indexPath else { return }
            self?.onTextChange?(indexPath, text)
        }
        
        self.textField.onSelection = { [weak self] in
            guard let indexPath = self?.indexPath else { return }
            self?.onSelection?(indexPath)
        }
    }
    
    func configure(with fieldValue: FieldValue, value: String?, indexPath: IndexPath) {
        self.titleLabel.text = fieldValue.title
        self.textField.placeholder = fieldValue.placeholder
        self.textField.keyboardType = fieldValue.keyboardType
        self.textField.isSelectable = fieldValue.isSelectable
        self.indexPath = indexPath
        self.textField.numberFormatter = fieldValue.formatter
        self.textField.text = value ?? fieldValue.value
    }
    
}
