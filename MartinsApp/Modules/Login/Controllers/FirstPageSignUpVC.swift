//
//  FirstPageSignUpVC.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/1/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit
import GooglePlaces

class FirstPageSignUpVC: UIViewController {
    
    typealias DependencyProvider = WebResourceProvider
    var provider: DependencyProvider!
    var registerParameter: Register!
    
    lazy var resource = provider.webResource
    
    private var serviceTradeList: ServiceTradeList?
    private var selectedService: [ServiceType]?
    private var selectedTradeSkills: [SubCategory]?
    private var selectedWorkingPlace: GMSPlace?

    @IBOutlet weak var fullNameField: UnderlineTextField!
    @IBOutlet weak var emailIdField: UnderlineTextField!
    @IBOutlet weak var serviceTypeField: UnderlineTextField!
    @IBOutlet weak var tradeSkillsField: UnderlineTextField!
    @IBOutlet weak var workingAreaField: UnderlineTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareFields()
        fetchList()
    }
    
    private func prepareFields() {
        self.serviceTypeField.isSelectable = true
        self.tradeSkillsField.isSelectable = true
        self.workingAreaField.isSelectable = true
        
        self.serviceTypeField.onSelection = { [weak self] in
            self?.handleServiceTypeSelection()
        }
        
        self.tradeSkillsField.onSelection = { [weak self] in
            self?.handleTradeSkillsSelection()
        }
        
        self.workingAreaField.onSelection = { [weak self] in
            self?.handleWorkingAreaSelection()
        }
    }
    
    var allFieldsValid: Bool {
        return fullNameField.text != nil
            && emailIdField.text != nil
            && serviceTypeField.text != nil
            && tradeSkillsField.text != nil
            && workingAreaField.text != nil
    }
    
    private func handleServiceTypeSelection() {
        guard let serviceTypes = self.serviceTradeList?.service, serviceTypes.count > 0 else { return }
        let selectionVC = SelectionViewController(items: serviceTypes, selectedItems: selectedService, allowsMultipleSelection: false, shouldDismiss: true) { [weak self] (selectedItems) in
            self?.selectedService = selectedItems
            self?.serviceTypeField.text = selectedItems.first?.name
            self?.tradeSkillsField.text = nil
        }
        selectionVC.title = "Select Trade Type"
        let previewController = PreviewController(rootVC: selectionVC, mode: .picker)
        self.view.endEditing(true)
        self.present(previewController, animated: true, completion: nil)
    }
    
    private func handleTradeSkillsSelection() {
        guard let subCategories = self.selectedService?.first?.SubCategory, subCategories.count > 0 else { return }
        let selectionVC = SelectionViewController(items: subCategories, selectedItems: selectedTradeSkills, allowsMultipleSelection: true, shouldDismiss: true) { [weak self] (selectedItems) in
            self?.selectedTradeSkills = selectedItems
            self?.tradeSkillsField.text = selectedItems.map{$0.name}.joined(separator: ", ")
        }
        selectionVC.title = "Select Sub Trade"
        let previewController = PreviewController(rootVC: selectionVC, mode: .picker)
        self.view.endEditing(true)
        self.present(previewController, animated: true, completion: nil)
    }
    
    private func handleWorkingAreaSelection() {
        let placesViewController = GMSAutocompleteViewController()
        placesViewController.delegate = self
        placesViewController.placeFields = .all
        placesViewController.tableCellBackgroundColor = UIColor.appBackground
        placesViewController.tableCellSeparatorColor = UIColor.grayButtonColor
        self.present(placesViewController, animated: true, completion: nil)
    }
    
    private func validateControlState(enabled: Bool) {
        [self.serviceTypeField,
         self.tradeSkillsField
        ].forEach({
            if enabled {
                $0?.stopAnimating()
            } else {
                $0?.startAnimating()
            }
        })
    }
    
    func validate() -> Bool {
        guard let fullName = self.fullNameField.text?.validOptionalString else {
            self.showAlert(message: "Please enter your full name.")
            return false
        }
        registerParameter.full_name = fullName
        guard let email = self.emailIdField.text?.validOptionalString else {
            self.showAlert(message: "Please enter your email.")
            return false
        }
        guard email.isValidEmail else {
            self.showAlert(message: "Please enter valid email address.")
            return false
        }
        registerParameter.email = email
        guard let serviceType = self.selectedService?.first?.category_id else {
            self.showAlert(message: "Please select a service type.")
            return false
        }
        registerParameter.service_type = "\(serviceType)"
        guard (self.tradeSkillsField.text?.validOptionalString) != nil else {
            self.showAlert(message: "Please select your trade skill.")
            return false
        }
        registerParameter.trade_skills = self.selectedTradeSkills?.compactMap({$0.sub_category_id}).compactMap({"\($0)"}).joined(separator: ",")
        guard let workingPlace = self.selectedWorkingPlace else {
            self.showAlert(message: "Please selecte your working area.")
            return false
        }
        registerParameter.working_area = workingPlace.formattedAddress
        registerParameter.latitude = "\(workingPlace.coordinate.latitude)"
        registerParameter.longitude = "\(workingPlace.coordinate.longitude)"
        registerParameter.city = workingPlace.city
        return true
    }

}

extension FirstPageSignUpVC {
    static func initialise(provider: DependencyProvider, parameter: Register) -> FirstPageSignUpVC {
        let vc = FirstPageSignUpVC.instantiate(from: .main)
        vc.provider = provider
        vc.registerParameter = parameter
        return vc
    }
}

extension FirstPageSignUpVC: GMSAutocompleteViewControllerDelegate {
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.selectedWorkingPlace = place
        self.workingAreaField.text = place.formattedAddress
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print(error)
        viewController.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - API
extension FirstPageSignUpVC {
    func fetchList() {
        self.validateControlState(enabled: false)
        resource.serviceAndTradeList { [weak self] (result) in
            self?.validateControlState(enabled: true)
            switch result {
            case .success(let list):
                self?.serviceTradeList = list
            case .failure(let error):
                self?.showAlert(for: error)
            }
        }
    }
}

extension GMSPlace {
    var city: String? {
        return self.addressComponents?.filter({$0.types.contains("locality") || $0.types.contains("administrative_area_level_1") || $0.types.contains("country")}).first?.name
    }
}
