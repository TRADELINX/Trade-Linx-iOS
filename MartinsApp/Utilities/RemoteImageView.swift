//
//  RemoteImageView.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/19/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class RemoteImageView: UIImageView {
    
    var urlString: String? {
        didSet {
            fetch()
        }
    }
    
    var placeholder: UIImage?
    var shouldShowIndicator: Bool = true
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .gray)
        indicatorView.hidesWhenStopped = true
        return indicatorView
    }()
    
    init(urlString: String?, placeholder: UIImage?) {
        self.urlString = urlString
        self.placeholder = placeholder
        super.init(image: placeholder)
        prepare()
        fetch()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
    }
    
    private func prepare() {
        self.addSubview(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        indicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    func fetch() {
        if shouldShowIndicator {
            self.indicatorView.startAnimating()
        }
        self.fetchImage(string: self.urlString, placeholder: self.placeholder ?? UIImage()) { [weak self] in
            self?.indicatorView.stopAnimating()
        }
    }
    
    func cancelRequest() {
        self.af.cancelImageRequest()
        self.image = self.placeholder ?? UIImage()
    }
    
    deinit {
        print("Deinit called from Remote Image View of: \(urlString ?? "NO URL")")
    }
    
}
