//
//  PlannerFooterView.swift
//  MartinsApp
//
//  Created by Neil Jain on 7/14/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class PlannerFooterView: UIView {
    
    private lazy var decorationView: ShadowView = {
        let view = ShadowView()
        view.shadowOpacity = 0.4
        view.shadowRadius = 8
        view.shadowOffset = CGSize(width: 0, height: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = UIColor.appBackground
        return view
    }()
    
    private var activityView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .white)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = .gray
        view.hidesWhenStopped = true
        return view
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.lightGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    deinit {
        print("Deinit called from PlannerFooterView")
    }
    
    private func setupViews() {
        self.addSubview(decorationView)
        decorationView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        decorationView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        decorationView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        decorationView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        
        decorationView.addSubview(activityView)
        activityView.centerXAnchor.constraint(equalTo: self.decorationView.centerXAnchor).isActive = true
        activityView.centerYAnchor.constraint(equalTo: self.decorationView.centerYAnchor).isActive = true
        
        decorationView.addSubview(errorLabel)
        errorLabel.centerXAnchor.constraint(equalTo: self.decorationView.centerXAnchor).isActive = true
        errorLabel.leftAnchor.constraint(equalTo: self.decorationView.leftAnchor, constant: 8).isActive = true
        errorLabel.topAnchor.constraint(equalTo: self.decorationView.topAnchor, constant: 8).isActive = true
        errorLabel.bottomAnchor.constraint(greaterThanOrEqualTo: self.decorationView.bottomAnchor, constant: -8).isActive = true
        
        errorLabel.isHidden = true
    }
    
    func startAnimating() {
        errorLabel.isHidden = true
        self.activityView.startAnimating()
    }
    
    func stopAnimating() {
        errorLabel.isHidden = true
        self.activityView.stopAnimating()
    }
    
    func stop(error: ResponseError) {
        errorLabel.isHidden = false
        self.activityView.stopAnimating()
        self.errorLabel.text = error.message
    }
}
