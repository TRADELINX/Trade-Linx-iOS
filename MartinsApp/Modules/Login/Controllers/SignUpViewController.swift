//
//  SignUpViewController.swift
//  MartinsApp
//
//  Created by Neil Jain on 5/31/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, ContainmentProvider {

    private var provider: WebResourceProvider!
    var onSuccess: ((User)->Void)!
    
    var page: Page = .firstPage {
        didSet {
            self.validate(page: page)
        }
    }
    
    @IBOutlet weak var topTrapezoidView: TrapezoidView!
    @IBOutlet weak var bottomTrapezoidView: TrapezoidView!
    @IBOutlet weak var containerView: ShadowView!
    @IBOutlet weak var actionButton: IndicatorButton!
    
    @IBOutlet weak var firstPageButton: UIButton!
    @IBOutlet weak var secondPageButton: UIButton!
    
    private var firstPageController: FirstPageSignUpVC?
    private var secondPageController: SecondPageSignUpVC?
    
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator()
    
    let registerParameters = Register()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        decorateView()
        self.page = .firstPage
        impactFeedbackGenerator.prepare()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        decorateNavigationBar()
    }
    
    private func decorateView() {
        self.topTrapezoidView.direction = .topRight
        self.topTrapezoidView.shadowOpacity = 0.15
        self.topTrapezoidView.shadowColor = #colorLiteral(red: 0.1568627451, green: 0.1568627451, blue: 0.1568627451, alpha: 1)
        self.topTrapezoidView.shadowRadius = 10
        self.topTrapezoidView.shadowOffset = CGSize(width: 0, height: 8)
        
        self.bottomTrapezoidView.direction = .bottomLeft
        self.bottomTrapezoidView.shadowOpacity = 0.07
        self.bottomTrapezoidView.shadowColor = #colorLiteral(red: 0.1568627451, green: 0.1568627451, blue: 0.1568627451, alpha: 1)
        self.bottomTrapezoidView.shadowRadius = 10
        self.bottomTrapezoidView.shadowOffset = CGSize(width: 0, height: 8)
        
        if #available(iOS 13.0, *) {
            self.actionButton.tintColor = UIColor.grayButtonColor
            self.actionButton.setTitleColor(UIColor.grayButtonColor, for: [])
        }
        
        self.firstPageButton.layer.cornerRadius = self.firstPageButton.frame.height/2
        self.firstPageButton.layer.masksToBounds = true
        self.firstPageButton.layer.borderWidth = 2
        self.firstPageButton.layer.borderColor = UIColor.selectionYellow.cgColor
        
        self.secondPageButton.layer.cornerRadius = self.firstPageButton.frame.height/2
        self.secondPageButton.layer.masksToBounds = true
        self.secondPageButton.layer.borderColor = UIColor.selectionYellow.cgColor
    }
    
    private func decorateNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func validate(page: Page) {
        switch page {
        case .firstPage:
            self.actionButton.setTitle("Continue".uppercased(), for: [])

            self.firstPageButton.setTitle("1", for: [])
            self.firstPageButton.setImage(nil, for: [])
            self.secondPageButton.layer.borderWidth = 0
            
            self.removeChild(secondPageController)
            self.addChild(firstPageController ?? firstPageVC(), to: containerView)
        case .secondPage:
            self.actionButton.setTitle("Sign Up".uppercased(), for: [])
            self.firstPageButton.setTitle(nil, for: [])
            self.firstPageButton.setImage(#imageLiteral(resourceName: "tick").withRenderingMode(.alwaysOriginal), for: [])
            self.secondPageButton.layer.borderWidth = 2
            
            self.removeChild(firstPageController)
            self.addChild(secondPageController ?? secondPageVC(), to: containerView)
        }
    }
    
    @IBAction func firstPageAction(_ sender: UIButton) {
        guard page != .firstPage else { return }
        self.page = .firstPage
    }
    
    @IBAction func signUpAction(_ sender: IndicatorButton) {
        impactFeedbackGenerator.impactOccurred(withIntensity: 0.5)
        switch page {
        case .firstPage:
            guard firstPageController?.validate() ?? false else { return }
            self.page = .secondPage
        case .secondPage:
            guard let imagesToUpload = secondPageController?.validate() else { return }
            provider.webResource.logout()
            sender.startAnimating()
            self.registerUser(for: imagesToUpload, sender: sender)
        }
    }
    
    private func registerUser(for imagesToUpload: [String: UIImage], sender: IndicatorButton) {
        if imagesToUpload.isEmpty {
            self.completeRegistration(sender: sender)
        } else {
            self.uploadImages(images: imagesToUpload, sender: sender) { [weak self] (success) in
                if success {
                    self?.completeRegistration(sender: sender)
                }
            }
        }
    }
    
    private func completeRegistration(sender: IndicatorButton) {
        sender.startAnimating()
        self.registerParameters.device_token = UserDefaults.standard.value(forKey: .deviceToken) as? String
        provider.webResource.register(registerParameters) { [weak self] (result) in
            sender.stopAnimating()
            switch result {
            case .success(let user):
                if let message = user.message, let userData = user.data {
                    self?.showAlert(message: message) {
                        self?.onSuccess(userData)
                    }
                } else if let message = user.message {
                    self?.showAlert(message: message)
                }
            case .failure(let error):
                self?.showAlert(for: error)
            }
        }
    }
 
    private func uploadImages(images: [String: UIImage], sender: IndicatorButton, completion: @escaping (Bool)->Void) {
        provider.webResource.upload(images: images, progress: { [weak sender] (percentage) in
            print(percentage)
            sender?.updateProgress(progress: 0)
        }) { [weak self] (result) in
            sender.updateProgress(progress: 0)
            sender.stopAnimating()
            switch result {
            case .success(let response):
                if let uploadedImages = response.data {
                    self?.registerParameters.insurance = uploadedImages["image"]
                    self?.registerParameters.accreditations = uploadedImages["image1"] ?? "abc.png"
                    completion(true)
                }
            case .failure(let error):
                self?.showAlert(for: error)
                completion(false)
            }
        }
    }

}

extension SignUpViewController {
    static func initialise(dependencyProvider: WebResourceProvider, onSuccess: @escaping (User)->Void) -> SignUpViewController {
        let viewController = SignUpViewController.instantiate(from: .main)
        viewController.provider = dependencyProvider
        viewController.onSuccess = onSuccess
        return viewController
    }
    
    func firstPageVC() -> FirstPageSignUpVC {
        let firstVC = FirstPageSignUpVC.initialise(provider: self.provider,
                                                   parameter: self.registerParameters)
        self.firstPageController = firstVC
        return firstVC
    }
    
    func secondPageVC() -> SecondPageSignUpVC {
        let secondVC = SecondPageSignUpVC.initialise(provider: self.provider,
                                                     parameter: self.registerParameters)
        self.secondPageController = secondVC
        return secondVC
    }
}

extension SignUpViewController {
    enum Page {
        case firstPage
        case secondPage
    }
}
