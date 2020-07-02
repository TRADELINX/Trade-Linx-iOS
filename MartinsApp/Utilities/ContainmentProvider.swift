//
//  ContainmentProvider.swift
//
//  Created by Neil Jain on 3/10/19.
//  Copyright © 2019 Neil Jain. All rights reserved.
//

import UIKit

protocol ContainmentProvider: class {
    func addChild(_ viewController: UIViewController, to containerView: UIView)
    func removeChild(_ viewController: UIViewController?)
}

extension ContainmentProvider where Self: UIViewController {
    func addChild(_ viewController: UIViewController, to containerView: UIView) {
        self.addChild(viewController)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(viewController.view)
        viewController.view.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        viewController.view.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        viewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        viewController.view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        viewController.didMove(toParent: self)
    }
    
    func removeChild(_ viewController: UIViewController?) {
        viewController?.willMove(toParent: nil)
        viewController?.view.removeFromSuperview()
        viewController?.removeFromParent()
        viewController?.didMove(toParent: nil)
    }
}
