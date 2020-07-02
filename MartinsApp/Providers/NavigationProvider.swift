//
//  NavigationProvider.swift
//  MartinsApp
//
//  Created by Neil Jain on 5/30/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

protocol NavigationProvider {
    func setRoot(viewController: UIViewController)
    func present(_ viewController: UIViewController, animated: Bool, completion: @escaping ()->Void)
    func showError(title: String, description: String)
    func navigate(for notification: [AnyHashable: Any])
}
