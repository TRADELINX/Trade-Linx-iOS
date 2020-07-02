//
//  NavigationDropView.swift
//  MartinsApp
//
//  Created by Neil Jain on 7/7/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class NavigationDropView: UIView {
    
    var title: String = "↓ Drop here to edit ↓" {
        didSet {
            self.titleLabel.text = title
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.poppins(for: UIFont.labelFontSize, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        self.isUserInteractionEnabled = true
        self.addSubview(titleLabel)
        titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        titleLabel.text = title
        startAnimating()
    }
    
    func startAnimating() {
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: [.autoreverse, .repeat, .curveEaseInOut], animations: {
            self.titleLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: nil)
    }
    
    deinit {
        print("Deinit called from NovigationDropView")
    }
    
}
