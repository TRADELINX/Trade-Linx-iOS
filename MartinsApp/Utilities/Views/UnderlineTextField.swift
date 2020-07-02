//
//  UnderlineTextField.swift
//  MartinsApp
//
//  Created by Neil Jain on 5/30/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class UnderlineTextField: UITextField {
    
    var onTextChange: ((String?)->Void)?
    var onResignFirstResponder: (()->Void)?
    var onBecomeFirstResponder: (()->Void)?
    
    var numberFormatter: NumberFormatter?
    
    var lineHeight: CGFloat = 1 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var isSelectable: Bool = false {
        didSet {
            prepareForSelectable()
        }
    }
    
    var onSelection: (()->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        observeTextChanges()
        prepareForSelectable()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        observeTextChanges()
        prepareForSelectable()
    }
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .white)
        view.hidesWhenStopped = true
        view.color = self.tintColor
        return view
    }()
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(touchedUpInsideAction))
        return tapGesture
    }()
    
    lazy var shapeLayer: CAShapeLayer = {
        return CAShapeLayer()
    }()
    
    var linePath: UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: self.bounds.origin.x, y: self.bounds.height-1))
        path.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height-1))
        return path
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        shapeLayer.frame = CGRect(x: 0, y: rect.height - lineHeight, width: rect.width, height: lineHeight)
        shapeLayer.path = linePath.cgPath
        self.layer.insertSublayer(shapeLayer, at: 0)
        if #available(iOS 13.0, *) {
            shapeLayer.backgroundColor = UIColor.seperatorColor.resolvedColor(with: self.traitCollection).cgColor
        } else {
            shapeLayer.backgroundColor = UIColor.groupTableViewBackground.cgColor
        }
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.path = linePath.cgPath
        shapeLayer.frame = CGRect(x: 0, y: self.bounds.height - 1, width: self.bounds.width, height: 1)
        if #available(iOS 13.0, *) {
            shapeLayer.backgroundColor = UIColor.seperatorColor.resolvedColor(with: self.traitCollection).cgColor
        } else {
            shapeLayer.backgroundColor = UIColor.groupTableViewBackground.cgColor
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        if isSelectable {
            return false
        }
        return super.canBecomeFirstResponder
    }
    
    private func observeTextChanges() {
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: nil, queue: nil) { [weak self] (notification) in
            guard let textField = notification.object as? UITextField, textField === self else { return }
            self?.onTextChange?(textField.text)
        }
    }
    
    private func prepareForSelectable() {
        self.delegate = self
        if self.isSelectable {
            self.rightViewMode = .always
            self.rightView = UIImageView(image: #imageLiteral(resourceName: "dropdown"))
            self.addGestureRecognizer(tapGesture)
        } else {
            self.rightViewMode = .never
            self.rightView = nil
            self.removeGestureRecognizer(tapGesture)
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            self.backgroundColor = isEnabled ? UIColor.white : UIColor.groupTableViewBackground
        }
    }
    
    func startAnimating() {
        self.rightViewMode = .always
        self.rightView = indicatorView
        self.isUserInteractionEnabled = false
        indicatorView.startAnimating()
    }
    
    func stopAnimating() {
        indicatorView.stopAnimating()
        indicatorView.removeFromSuperview()
        self.isUserInteractionEnabled = true
        self.prepareForSelectable()
    }
    
    @objc func touchedUpInsideAction() {
        self.onSelection?()
    }
    
    override func resignFirstResponder() -> Bool {
        let resigns = super.resignFirstResponder()
        if resigns {
            self.onResignFirstResponder?()
        }
        return resigns
    }
    
    override func becomeFirstResponder() -> Bool {
        let becomesFirstResponder = super.becomeFirstResponder()
        if becomesFirstResponder {
            self.onBecomeFirstResponder?()
        }
        return becomesFirstResponder
    }
    
}

extension UnderlineTextField: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if isSelectable {
            //self.onSelection?()
            return false
        }
        return true
    }
}
