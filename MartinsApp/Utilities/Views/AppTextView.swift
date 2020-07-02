//
//  AppTextView.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/5/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class AppTextView: UITextView {
    
    var onTextChange: ((String?)->Void)?
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        observeTextChanges()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        observeTextChanges()
    }
    
    private func observeTextChanges() {
        NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification, object: nil, queue: nil) { [weak self] (notification) in
            guard let textView = notification.object as? UITextView, textView === self else { return }
            self?.onTextChange?(textView.text)
        }
    }
    
    override var canResignFirstResponder: Bool {
        return true
    }

}
