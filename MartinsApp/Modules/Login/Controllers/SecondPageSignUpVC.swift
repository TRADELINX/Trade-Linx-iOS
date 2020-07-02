//
//  SecondPageSignUpVC.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/1/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class SecondPageSignUpVC: UIViewController, ImagePickerDiplaying {
    
    enum ImageSelectionState {
        case insurance
        case accreditation
    }
    
    typealias DependencyProvider = WebResourceProvider
    var provider: DependencyProvider!
    var parameter: Register!

    @IBOutlet weak var insuranceImageSelector: UIImageSelector!
    @IBOutlet weak var accreditationImageSelector: UIImageSelector!
    @IBOutlet weak var hourlyRateField: UnderlineTextField!
    @IBOutlet weak var passowdField: UnderlineTextField!
    @IBOutlet weak var confirmPasswordField: UnderlineTextField!
    @IBOutlet weak var phoneNumberField: UnderlineTextField!
    
    private var imageSelectionState: ImageSelectionState = .insurance
    var insuranceImageTrack: [String] = []
    var accreditationImageTrack: [String] = []
    var paymentOption: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //prepareFields()
    }
    
    private func prepareFields() {
        self.hourlyRateField.isSelectable = true
        self.hourlyRateField.onSelection = { [weak self] in
            self?.handleHourlyRateSelection()
        }
        
        self.insuranceImageSelector.onPhotoUploadAction = { [weak self] in
            self?.imageSelectionState = .insurance
            self?.showMediaPickerOptions()
        }
        
        self.accreditationImageSelector.onPhotoUploadAction = { [weak self] in
            self?.imageSelectionState = .accreditation
            self?.showMediaPickerOptions()
        }
    }
    
    private func handleHourlyRateSelection() {
        let items: [String] = ["Hourly Rate(£)", "Day Rate(£)"]
        var selectedItems: [String] = []
        if let selectedPaymentOption = self.paymentOption {
            selectedItems = [selectedPaymentOption]
        }
        let selectionVC = SelectionViewController(items: items, selectedItems: selectedItems, allowsMultipleSelection: false, style: .plain, shouldDismiss: true) { [weak self] (selectedOption) in
            self?.paymentOption = selectedOption.first
            self?.hourlyRateField.text = selectedOption.first
        }
        selectionVC.title = "Payment Options"
        let previewController = PreviewController(rootVC: selectionVC, mode: .picker)
        self.present(previewController, animated: true, completion: nil)
    }
    
    func validate() -> [String: UIImage]? {
        /*
        guard insuranceImageSelector.images.count > 0 else {
            self.showAlert(message: "Please enter insurance document image.")
            return nil
        }
        //parameter.insurance = insurance
        
        guard accreditationImageSelector.images.count > 0 else {
            self.showAlert(message: "Please enter accreditation.")
            return nil
        }
        
        parameter.accreditations = ""
        guard let hourlyRate = self.paymentOption?.validOptionalString else {
            self.showAlert(message: "Please enter hourly rate.")
            return nil
        }
        parameter.hourly_rate = "\(hourlyRate)"
        */
        
        guard let phoneNumber = self.phoneNumberField.text?.validOptionalString else {
            self.showAlert(message: "Please enter phone number.")
            return nil
        }
        parameter.user_mobile = phoneNumber
        
        guard let password = self.passowdField.text?.validOptionalString else {
            self.showAlert(message: "Please enter password.")
            return nil
        }
        
        guard password.isValidPassword else {
            self.showAlert(message: String.passwordPolicy)
            return nil
        }
        
        guard let confirmPassword = self.confirmPasswordField.text?.validOptionalString else {
            self.showAlert(message: "Please enter confirmation password.")
            return nil
        }
        guard password == confirmPassword else {
            self.showAlert(message: "Your passwords do not match.")
            return nil
        }
        parameter.password = password
        return prepareImageNames(for: self.insuranceImageSelector.images, accreditationImages: self.accreditationImageSelector.images)
    }
    
    private func prepareImageNames(for insuranceImages: [UIImage], accreditationImages: [UIImage]) -> [String: UIImage] {
        var images: [String: UIImage] = [:]
        var cursor: Int = 0
        for image in insuranceImages {
            if cursor > 0 {
                let name = "image\(cursor)"
                images[name] = image
                self.insuranceImageTrack.append(name)
            } else {
                let name = "image"
                images[name] = image
                self.insuranceImageTrack.append(name)
            }
            cursor += 1
        }
        for image in accreditationImages {
            let name = "image\(cursor)"
            images[name] = image
            self.accreditationImageTrack.append(name)
            cursor += 1
        }
        return images
    }

}

extension SecondPageSignUpVC {
    static func initialise(provider: DependencyProvider, parameter: Register) -> SecondPageSignUpVC {
        let vc = SecondPageSignUpVC.instantiate(from: .main)
        vc.parameter = parameter
        vc.provider = provider
        return vc
    }
}

extension SecondPageSignUpVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            picker.dismiss(animated: true, completion: nil)
        }
        guard let image = info[.originalImage] as? UIImage else { return }
        switch self.imageSelectionState {
        case .insurance:
            self.insuranceImageSelector.addImage(image)
        case .accreditation:
            self.accreditationImageSelector.addImage(image)
        }
    }
}
