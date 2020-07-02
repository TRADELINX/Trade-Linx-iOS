//
//  UIImageView+Extensions.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/19/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import Foundation
import AlamofireImage

extension UIImageView {
    func fetchImage(string: String?, placeholder: UIImage?, completion: (()->Void)? = nil) {
        guard let urlString = string, let url = URL(string: urlString) else {
            self.image = placeholder
            return
        }
        self.af.setImage(withURL: url, placeholderImage: placeholder) { (_) in
            completion?()
        }
    }
}
