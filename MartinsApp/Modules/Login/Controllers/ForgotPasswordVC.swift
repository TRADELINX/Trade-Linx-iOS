//
//  ForgotPasswordVC.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/17/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {
    typealias DependecyProvider = WebResourceProvider
    private var provider: DependecyProvider!
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator()
    
    @IBOutlet weak var emailField: UnderlineTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        decorateNavigationBar()
        impactFeedbackGenerator.prepare()
    }
    
    deinit {
        print("Deinit called from ForgotPasswordVC")
    }
    
    private func decorateNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func validate() -> String? {
        guard let email = emailField.text?.validOptionalString else {
            self.showAlert(message: "Please enter your email.")
            return nil
        }
        guard email.isValidEmail else {
            self.showAlert(message: "Please enter valid email.")
            return nil
        }
        return email
    }

    @IBAction func sendAction(_ sender: IndicatorButton) {
        impactFeedbackGenerator.impactOccurred(withIntensity: 0.5)
        guard let email = self.validate() else { return }
        sender.startAnimating()
        provider.webResource.forgotPassword(passwordRequest: ForgotPassword(email: email)) { [weak self] (result) in
            sender.stopAnimating()
            switch result {
            case .success(let response):
                if let message = response.message, response.status == 1 {
                    self?.showAlert(title: nil, message: message, okAction: {
                        self?.navigationController?.popViewController(animated: true)
                    })
                } else if let message = response.message {
                    self?.showAlert(message: message)
                }
            case .failure(let error):
                self?.showAlert(for: error)
            }
        }
    }
    
}

extension ForgotPasswordVC {
    static func initialise(provider: DependecyProvider) -> ForgotPasswordVC {
        let vc = ForgotPasswordVC.instantiate(from: .main)
        vc.provider = provider
        return vc
    }
}
