//
//  MessageFieldView.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/5/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class MessageFieldView: UIView {
    
    @IBOutlet weak var textView: AppTextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var seperatorView: UIView!
    
    var onSendAction: ((String)->Void)?
    var onTextChange: (()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareUI()
        observeTextChanges()
    }
    
    private func prepareUI() {
        self.backgroundColor = UIColor.messageFieldColor
        self.placeholderLabel.text = "Enter your message here..."
        
        self.autoresizingMask = .flexibleHeight
        
        self.textView.isScrollEnabled = false
        self.textView.bounces = false
        self.textView.textContainerInset = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        self.seperatorView.backgroundColor = UIColor.shadowColor
    }
    
    private func observeTextChanges() {
        self.textView.onTextChange = { [weak self] (text) in
            self?.updatePlaceholderState()
            self?.updateSelfHeight()
            self?.onTextChange?()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        var textSize = self.textView.sizeThatFits(CGSize(width: self.textView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        if textSize.height >= 110 {
            textSize.height = 110
            self.textView.isScrollEnabled = true
            self.textView.bounces = true
        } else {
            self.textView.setContentOffset(CGPoint.zero, animated: false)
            self.textView.isScrollEnabled = false
            self.textView.bounces = false
        }
        return CGSize(width: self.bounds.width, height: textSize.height)
    }
    
    private func updatePlaceholderState() {
        self.layoutIfNeeded()
        self.placeholderLabel.isHidden = !(textView.text.isEmpty)
    }
    
    private func updateSelfHeight() {
        self.invalidateIntrinsicContentSize()
    }

    @IBAction func sendAction(_ sender: UIButton) {
        guard let text = textView.text.validOptionalString else {
            return
        }
        self.textView.isScrollEnabled = false
        self.textView.text = ""
        self.updateSelfHeight()
        self.updatePlaceholderState()
        self.onSendAction?(text)
    }
    
}
