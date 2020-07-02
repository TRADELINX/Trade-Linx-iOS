//
//  ThemedNavigationController.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/1/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class ThemedNavigationController: UINavigationController {

    var barTintColor: UIColor = UIColor.tintBlue
    var tintColor: UIColor = .white
    var isTranslucent = false
    var barStyle: UIBarStyle = .black
    var titleFont: UIFont = UIFont.poppins(for: 17, weight: .semibold)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        decorateTheme()
    }
    
    private func decorateTheme() {
        self.view.backgroundColor = .white
        self.navigationBar.barTintColor = self.barTintColor
        self.navigationBar.tintColor = self.tintColor
        self.navigationBar.isTranslucent = self.isTranslucent
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.barStyle = self.barStyle
        self.navigationBar.titleTextAttributes = [.font: self.titleFont,
                                                  .foregroundColor: self.tintColor]
    }

}
