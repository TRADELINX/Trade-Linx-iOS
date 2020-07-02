//
//  OnboardingItem.swift
//  MartinsApp
//
//  Created by Neil on 11/04/20.
//  Copyright © 2020 Ratnesh Jain. All rights reserved.
//

import UIKit

struct OnboardingItem {
    var title: String
    var subtitle: String
    var image: UIImage
    var nextButtonTitle: String
}

extension OnboardingItem {
    static var dataSource: [OnboardingItem] {
        return [
            OnboardingItem(
                title: "Welcome to Tradelinx",
                subtitle: "Specialist in finding you work.",
                image: #imageLiteral(resourceName: "Welcome"),
                nextButtonTitle: "Skip"
            ),
            OnboardingItem(
                title: "Create Profile",
                subtitle: "Create your own unique profile.",
                image: #imageLiteral(resourceName: "Create Profile"),
                nextButtonTitle: "Skip"
            ),
            OnboardingItem(
                title: "Update Diary",
                subtitle: "Update you own tailored diary! Subcontracting is easier than ever.",
                image: #imageLiteral(resourceName: "Update Diary"),
                nextButtonTitle: "Skip"
            ),
            OnboardingItem(
                title: "Get Hired",
                subtitle: "Receive immediate alerts for work and book within seconds.",
                image: #imageLiteral(resourceName: "Get-Hired"),
                nextButtonTitle: "Continue"
            ),
        ]
    }
}
