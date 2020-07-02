//
//  UnderlineTextField.swift
//
//  Created by Neil Jain on 3/24/19.
//  Copyright © 2019 Neil Jain. All rights reserved.
//

import UIKit

class UnderlineTextField: UITextField {

    var onTextChange: ((String?)->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        observeTextChanges()
        setupPlaceholder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        observeTextChanges()
        setupPlaceholder()
    }
    
    lazy var line: CAShapeLayer = {
        let line = CAShapeLayer()
        return line
    }()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.line.path = UIBezierPath(rect: CGRect(x: 0, y: rect.height, width: rect.width, height: 1)).cgPath
        self.line.fillColor = UIColor.white.cgColor
        self.layer.addSublayer(line)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.line.path = UIBezierPath(rect: CGRect(x: 0, y: bounds.height, width: bounds.width, height: 1)).cgPath
    }
    
    override var placeholder: String? {
        didSet {
            setupPlaceholder()
        }
    }
    
    private func setupPlaceholder() {
        let placeholder = self.placeholder ?? ""
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.8)])
    }
    
    private func observeTextChanges() {
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: nil, queue: nil) { (notification) in
            guard notification.name == UITextField.textDidChangeNotification, let textField = notification.object as? UITextField, textField === self else {
                return
            }
            self.onTextChange?(textField.text)
        }
    }

}
