//
//  LoginViewController.swift
//  MartinsApp
//
//  Created by Neil Jain on 5/30/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit

class LoginViewController: UIViewController {
    typealias DependecyProvider = WebResourceProvider
    private var provider: DependecyProvider!
    var onSuccess: ((User)->Void)!
    
    @IBOutlet weak var topTrapezoidView: TrapezoidView!
    @IBOutlet weak var bottomTrapezoidView: TrapezoidView!
    @IBOutlet weak var facebookButton: ShadowButton!
    @IBOutlet weak var googleButton: ShadowButton!
    @IBOutlet weak var emailField: UnderlineTextField!
    @IBOutlet weak var passwordField: UnderlineTextField!
    @IBOutlet weak var signInButton: IndicatorButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    private let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    static func initialise(dependencyProvider: DependecyProvider, onSuccess: @escaping (SingleSignOnUser)->Void) -> LoginViewController {
        let viewController = LoginViewController.instantiate(from: .main)
        viewController.provider = dependencyProvider
        viewController.onSuccess = onSuccess
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        decorate()
        notificationFeedbackGenerator.prepare()
        impactFeedbackGenerator.prepare()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    private func decorate() {
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
        
        self.facebookButton.shadowColor = #colorLiteral(red: 0.1568627451, green: 0.1568627451, blue: 0.1568627451, alpha: 1)
        self.facebookButton.shadowOpacity = 0.07
        self.facebookButton.shadowOffset = CGSize(width: 0, height: 5)
        self.facebookButton.shadowRadius = 5
        
        self.googleButton.shadowColor = #colorLiteral(red: 0.1568627451, green: 0.1568627451, blue: 0.1568627451, alpha: 1)
        self.googleButton.shadowOpacity = 0.07
        self.googleButton.shadowOffset = CGSize(width: 0, height: 5)
        self.googleButton.shadowRadius = 5
        
        if #available(iOS 13.0, *) {
            self.signInButton.tintColor = UIColor.grayButtonColor
            self.signInButton.setTitleColor(UIColor.grayButtonColor, for: [])
            self.signUpButton.tintColor = UIColor.grayButtonColor
            self.signUpButton.setTitleColor(UIColor.grayButtonColor, for: [])
        }
        
    }
    
    private func validate() -> (String, String)? {
        guard let email = self.emailField.text?.validOptionalString else {
            self.showAlert(message: "Please enter your email/phone number.")
            return nil
        }
        if Int(email) == nil {
            guard email.isValidEmail else {
                self.showAlert(message: "Please enter valid email string.")
                return nil
            }
        }
        
        guard let password = self.passwordField.text?.validOptionalString else {
            self.showAlert(message: "Please enter your password.")
            return nil
        }
        //        guard password.count >= 6 else {
        //            self.showAlert(message: "Password must be atleast 6 characters long."
        //            return nil
        //        }
        return (email, password)
    }
    
    private func validateControlState(enabled: Bool) {
        [
            self.googleButton,
            self.facebookButton,
            self.forgotPasswordButton,
            self.signUpButton,
            self.signInButton
        ]
        .forEach({$0?.isEnabled = enabled})
        
        if !enabled {
            self.signInButton.startAnimating()
        } else {
            self.signInButton.stopAnimating()
        }
    }
    
    private func signInWithSocialProvider(_ register: SocialRegister) {
        self.validateControlState(enabled: false)
        provider.webResource.loginWithGoogle(register: register) { [weak self] (result) in
            self?.validateControlState(enabled: true)
            switch result {
            case .success(let user):
                self?.onSuccess?(user)
                self?.notificationFeedbackGenerator.notificationOccurred(.success)
            case .failure(let error):
                self?.showAlert(for: error)
                self?.notificationFeedbackGenerator.notificationOccurred(.error)
            }
        }
    }
    
    private func fetchFacebookUserDetails() {
        let request = GraphRequest(graphPath: "me", parameters: ["fields" : "email, name"])
        self.validateControlState(enabled: false)
        request.start { [weak self] (connection, response, error) in
            self?.validateControlState(enabled: true)
            if let error = error {
                self?.showAlert(message: error.localizedDescription)
            }
            guard let userData = response as? [String: Any], let name = userData["name"] as? String, let email = userData["email"] as? String, let id = userData["id"] as? String else {
                self?.showAlert(message: "Can not get your information from Facebook.")
                return
            }
            let deviceToken = UserDefaults.standard.value(forKey: .deviceToken) as? String
            let facebookRegister = SocialRegister(full_name: name, email: email, social_provider: .facebook, social_provider_id: id, device_type: 1, device_token: deviceToken)
            self?.signInWithSocialProvider(facebookRegister)
        }
    }
    
    @IBAction func signInWithGoogleAction(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.signIn()
        impactFeedbackGenerator.impactOccurred(withIntensity: 1)
    }
    
    @IBAction func signInWithFacebook(_ sender: UIButton) {
        impactFeedbackGenerator.impactOccurred(withIntensity: 1)
        let loginManager = LoginManager()
        self.validateControlState(enabled: false)
        loginManager.logIn(permissions: [.publicProfile, .email,], viewController: self) { [weak self] loginResult in
            self?.validateControlState(enabled: true)
            switch loginResult {
            case .failed(let error):
                self?.showAlert(message: error.localizedDescription)
                self?.notificationFeedbackGenerator.notificationOccurred(.error)
                break
            case .cancelled:
                print("User cancelled login.")
                break
            case .success:
                self?.fetchFacebookUserDetails()
            }
        }
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        impactFeedbackGenerator.impactOccurred(withIntensity: 1)
        guard let (email, password) = self.validate() else { return }
        
        // logout previous user
        provider.webResource.logout()
        
        // login with new user
        self.validateControlState(enabled: false)
        provider.webResource.login(email: email, password: password) { [weak self] (result) in
            self?.validateControlState(enabled: true)
            switch result {
            case .success(let user):
                self?.onSuccess(user)
                self?.notificationFeedbackGenerator.notificationOccurred(.success)
            case .failure(let error):
                self?.showAlert(for: error)
                self?.notificationFeedbackGenerator.notificationOccurred(.error)
            }
        }
    }
    
    @IBAction func signUpAction(_ sender: UIButton) {
        impactFeedbackGenerator.impactOccurred(withIntensity: 0.5)
        let signUpVC = SignUpViewController.initialise(dependencyProvider: provider, onSuccess: { [weak self] user in
            self?.navigationController?.popViewController(animated: true)
        })
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @IBAction func forgotPasswordAction(_ sender: UIButton) {
        impactFeedbackGenerator.impactOccurred(withIntensity: 0.5)
        let forgotPasswordVC = ForgotPasswordVC.initialise(provider: provider)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.pushViewController(forgotPasswordVC, animated: true)
    }
    
}

extension LoginViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            print(error)
            self.showAlert(message: error.localizedDescription)
            self.notificationFeedbackGenerator.notificationOccurred(.error)
            return
        }
        guard let userId = user.userID, let name = user.profile.name, let email = user.profile.email else {
            self.showAlert(message: "Can not get your information from google.")
            self.notificationFeedbackGenerator.notificationOccurred(.error)
            return
        }
        let deviceToken = UserDefaults.standard.value(forKey: .deviceToken) as? String
        let googleRegister = SocialRegister(full_name: name, email: email, social_provider: .google, social_provider_id: userId, device_type: 1, device_token: deviceToken)
        self.signInWithSocialProvider(googleRegister)
    }
}
