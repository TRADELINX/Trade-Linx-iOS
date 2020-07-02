//
//  MessageTextView.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/29/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class MessageTextView: UITextView {
    
    var maxHeight: CGFloat = 117
    var onTextChange: ((String?)->Void)?
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToBottom), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
            
            // This eliminates a weird UI glitch where inserting a new line sometimes causes there to be a
            // content offset when self.bounds == self.contentSize causing the text at the top to be snipped
            // and a gap at the bottom.
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let width = super.intrinsicContentSize.width
        return CGSize(width: width, height: contentSize.height)
    }
    
    @objc func scrollToBottom() {
        // This needs to happen so the superview updates the bounds of this text view from its new intrinsicContentSize
        // If not called, the bounds will be smaller than the contentSize at this moment, causing the guard to not be triggered.
        superview?.layoutIfNeeded()
        
        // Prevent scrolling if the textview is large enough to show all its content. Otherwise there is a jump.
        guard contentSize.height > bounds.size.height else {
            return
        }
        
        let offsetY = (contentSize.height + contentInset.top) - maxHeight
        UIView.animate(withDuration: 0.125) {
            self.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
        }
        self.onTextChange?(self.text)
    }
}
