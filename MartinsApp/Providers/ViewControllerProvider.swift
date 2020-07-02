//
//  ViewControllerProvider.swift
//  MartinsApp
//
//  Created by Neil Jain on 5/30/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

protocol ViewControllerProvider {
    func createOnboardingViewController(success: @escaping ()->Void) -> UIViewController
    func createRootViewController() -> UIViewController
    func createLoginViewController(success: @escaping (SingleSignOnUser)->Void ) -> UINavigationController
}
