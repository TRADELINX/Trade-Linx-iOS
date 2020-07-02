//
//  EditProfileViewController.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/2/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit
import GooglePlaces

// MARK: - EditProfile Image Picker Source -
extension EditProfileViewController {
    enum ImageDestination {
        case profile
        case photos
        case certificates
        case insurance
        case accreditation
        
        var limit: Int {
            switch self {
            case .profile:
                return 1
            case .photos:
                return 5
            case .certificates:
                return 5
            case .insurance:
                return 1
            case .accreditation:
                return 1
            }
        }
    }
}

class EditProfileViewController: UIViewController {
    typealias DependencyProvider = UserManagerProvider & WebResourceProvider
    var provider: DependencyProvider!
    
    @IBOutlet weak var tableView: UITableView!
    private var uploadingState: Bool = false
    
    private var dataSource: [EditProfileRowType] = []
    private var valueCache: [IndexPath: String] = [:]
    private var serviceList: [ServiceType] = []
    private var tradeList: [SubCategory] = []
    
    private var selectedService: [ServiceType]?
    private var selectedTrades: [SubCategory]?
    private var selectedWorkingPlace: WorkingPlace?
    
    private var workImagesTrack: [String] = []
    private var qualificationImagesTrack: [String] = []
    private var insuranceImageTrack: [String] = []
    private var accrediationImageTrack: [String] = []
    
    var imageDestination: ImageDestination = .photos
    
    lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        return numberFormatter
    }()
    
    private var profileImage: UIImage?
    private var workPhotos: [Image] = []
    private var qualificationPhotos: [Image] = []
    private var insurancePhotos: [Image] = []
    private var accreditationsPhotos: [Image] = []
    
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator()
    
    var user: User {
        return provider.userManager.currentUser!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTableView()
        setupDataSource()
        fetchServiceTradeList()
        impactFeedbackGenerator.prepare()
    }
    
    private func prepareTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 102
        self.tableView.separatorStyle = .none
        
        self.tableView.registerNib(EditProfileFieldCell.self)
        self.tableView.registerNib(EditProfileUpdateButtonCell.self)
        self.tableView.registerNib(EditProfileQualificationCell.self)
        self.tableView.registerNib(EditProfileImagesCell.self)
        self.tableView.registerNib(EditProfileAvtarCell.self)
    }
    
    private func setupDataSource() {
        self.dataSource = EditProfileRowType.dataSource(for: provider.userManager.currentUser!)
        self.workPhotos = user.workImages.compactMap({.remote($0)})
        self.qualificationPhotos = user.qualificationImages.compactMap({.remote($0)})
        if let insuranceImageURLString = user.insuranceImageURLString {
            self.insurancePhotos = [Image.remote(RemoteImage(urlString: insuranceImageURLString, id: user.id, table: .userWorkImage))]
        } else {
            self.insurancePhotos = []
        }
        if let accreditationImageURLString = user.accreditationImageURLString {
            self.accreditationsPhotos = [Image.remote(RemoteImage(urlString: accreditationImageURLString, id: user.id, table: .userWorkImage))]
        } else {
            self.accreditationsPhotos = []
        }
        updateSelectedItems()
    }
    
    private func updateSelectedItems() {
        guard let user = provider.userManager.currentUser else { return }
        if let serviceType = user.serviceType {
            self.selectedService = [serviceType]
        }
        self.selectedWorkingPlace = WorkingPlace(with: user)
    }
    
    private func updateTradeSkills() {
        guard let user = provider.userManager.currentUser else { return }
        self.selectedTrades = user.serviceSubType
        //if let selectedServiceType = self.serviceList.filter({$0.category_id == user.serviceType?.category_id}).first {
        //    self.selectedTrades = selectedServiceType.SubCategory?.filter({$0.sub_category_id == user.serviceSubType?.sub_category_id})
        //}
    }
    
    private func handleSelection(at indexPath: IndexPath) {
        let isIntroductionRow = indexPath == EditProfileRow.about.indexPath
        let isServiceRow = indexPath == EditProfileRow.tradeType.indexPath
        let isTradeRow = indexPath == EditProfileRow.subtrade.indexPath
        let isWorkingPlace = indexPath == EditProfileRow.workingArea.indexPath
        let isPaymentOption = indexPath == EditProfileRow.paymentOption.indexPath
        if isIntroductionRow {
            self.handleIntroductionSelection(at: indexPath)
        }
        if isServiceRow {
            self.handleServiceSelection()
        }
        if isTradeRow {
            self.handleTradeSelection()
        }
        if isWorkingPlace {
            self.handleWorkingPlaceSelection()
        }
        if isPaymentOption {
            self.handlePaymentOptionSelection()
        }
    }
    
    private func handleIntroductionSelection(at indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? EditProfileFieldCell else { return }
        let commentCache = self.valueCache[indexPath]
        let sourceRect = cell.superview?.convert(cell.frame, to: self.tableView.window)
        let introVC = AddIntroductionController.instantiate(from: .main)
        introVC.defaultText = commentCache
        introVC.onSaveAction = { [weak self] intro in
            self?.valueCache[indexPath] = intro
            self?.tableView.reloadData()
        }
        let commentsVC = CommentsController(rootViewController: introVC)
        commentsVC.sourceView = cell
        commentsVC.sourceRect = sourceRect
        self.present(commentsVC, animated: true, completion: nil)
    }
    
    private func handleServiceSelection() {
        let indexPath = EditProfileRow.tradeType.indexPath
        let nextIndexPath = EditProfileRow.subtrade.indexPath
        let selectionVC = SelectionViewController(items: self.serviceList, selectedItems: self.selectedService, allowsMultipleSelection: false, shouldDismiss: true) { [weak self] (selectedItems) in
            self?.selectedService = selectedItems
            self?.valueCache[indexPath] = selectedItems.map{$0.description}.joined(separator: ", ")
            self?.valueCache[nextIndexPath] = ""
            self?.tableView.reloadRows(at: [indexPath, nextIndexPath], with: .none)
        }
        selectionVC.title = "Select Service Type"
        let previewController = PreviewController(rootVC: selectionVC, mode: .popup)
        self.present(previewController, animated: true, completion: nil)
    }
    
    private func handleTradeSelection() {
        let indexPath = EditProfileRow.subtrade.indexPath
        self.tradeList = self.serviceList.filter({$0.category_id == self.selectedService?.first?.category_id}).first?.SubCategory ?? []
        let selectionVC = SelectionViewController(items: self.tradeList, selectedItems: self.selectedTrades, allowsMultipleSelection: true, shouldDismiss: true) { [weak self] (selectedItems) in
            self?.selectedTrades = selectedItems
            self?.valueCache[indexPath] = selectedItems.map{$0.description}.joined(separator: ", ")
            self?.tableView.reloadRows(at: [indexPath], with: .none)
        }
        selectionVC.title = "Select Trade Skills"
        let previewController = PreviewController(rootVC: selectionVC, mode: .popup)
        self.present(previewController, animated: true, completion: nil)
    }
    
    private func handleWorkingPlaceSelection() {
        let placesViewController = GMSAutocompleteViewController()
        placesViewController.delegate = self
        placesViewController.placeFields = .all
        placesViewController.tableCellBackgroundColor = UIColor.appBackground
        placesViewController.tableCellSeparatorColor = UIColor.grayButtonColor
        self.present(placesViewController, animated: true, completion: nil)
    }
    
    private func handlePaymentOptionSelection() {
        let indexPath = EditProfileRow.paymentOption.indexPath
        //["Hourly Rate(£)", "Day Rate(£)", "Price Work(£)", "Travel cost Per mile(£)"]
        let items: [String] = ["Hourly Rate(£)", "Day Rate(£)"]
        var selectedItems: [String] = []
        if let selectedPaymentOption = valueCache[indexPath] {
            selectedItems = [selectedPaymentOption]
        }
        let selectionVC = SelectionViewController(items: items, selectedItems: selectedItems, allowsMultipleSelection: false, style: .plain, shouldDismiss: true) { [weak self] (selectedOption) in
            self?.valueCache[indexPath] = selectedOption.first
            self?.tableView.reloadRows(at: [indexPath], with: .none)
        }
        selectionVC.title = "Payment Options"
        let previewController = PreviewController(rootVC: selectionVC, mode: .picker)
        self.present(previewController, animated: true, completion: nil)
    }
    
    private func handlePicker(for source: ImageDestination, count: Int) {
        guard source.limit > count else {
            let alert = UIAlertController(title: "Limit Reached", message: "You can only add \(source.limit) images", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        self.showMediaPickerOptions()
    }
    
    private func insertImage(_ image: UIImage) {
        switch imageDestination {
        case .profile:
            guard let cell = tableView.cellForRow(at: EditProfileRow.profileImage.indexPath) as? EditProfileAvtarCell else { return }
            self.profileImage = image
            cell.updateProfile(with: .local(image))
        case .photos:
            guard let cell = tableView.cellForRow(at: EditProfileRow.photoGallery.indexPath) as? EditProfileQualificationCell else { return }
            self.workPhotos.insert(.local(image), at: 0)
            cell.insert(image: .local(image))
        case .certificates:
            guard let cell = tableView.cellForRow(at: EditProfileRow.qualification.indexPath) as? EditProfileQualificationCell else { return }
            self.qualificationPhotos.insert(.local(image), at: 0)
            cell.insert(image: .local(image))
        case .insurance:
            guard let cell = tableView.cellForRow(at: EditProfileRow.insurance.indexPath) as? EditProfileQualificationCell else {
                return
            }
            self.insurancePhotos.insert(.local(image), at: 0)
            cell.insert(image: .local(image))
        case .accreditation:
            // TODO: Clean accreditation.
            guard let cell = tableView.cellForRow(at: IndexPath(item: dataSource.count - 4, section: 0)) as? EditProfileQualificationCell else {
                return
            }
            self.accreditationsPhotos.insert(.local(image), at: 0)
            cell.insert(image: .local(image))
        }
    }
    
    // MARK: - Form Validation -
    private func validate() -> Register? {
        guard let alreadyUser = provider.userManager.currentUser else { return nil }
        let register = Register()
        register.user_id = alreadyUser.userId
        guard let fullName = (valueCache[EditProfileRow.fullName.indexPath])?.validOptionalString else {
            self.showAlert(message: "Please enter your full name.")
            return nil
        }
        register.full_name = fullName
        guard let email = (valueCache[EditProfileRow.email.indexPath])?.validOptionalString else {
            self.showAlert(message: "Please enter email.")
            return nil
        }
        guard email.isValidEmail else {
            self.showAlert(message: "Please enter valid email.")
            return nil
        }
        register.email = email
        guard let phoneNumber = valueCache[EditProfileRow.phoneNumber.indexPath]?.validOptionalString else {
            self.showAlert(message: "Please enter phone number.")
            return nil
        }
        register.user_mobile = phoneNumber
        
        guard let introduction = valueCache[EditProfileRow.about.indexPath]?.validOptionalString else {
            self.showAlert(message: "Please enter abount your self.")
            return nil
        }
        register.short_introduction = introduction
        
        guard let serviceType = valueCache[EditProfileRow.tradeType.indexPath]?.validOptionalString else {
            self.showAlert(message: "Please select service type.")
            return nil
        }
        let id = serviceList.first(where: {$0.name == serviceType})?.category_id ?? 0
        register.service_type = "\(id)"
        
        guard (valueCache[EditProfileRow.subtrade.indexPath]?.validOptionalString) != nil else {
            self.showAlert(message: "Please select sub trades.")
            return nil
        }
        register.trade_skills = selectedTrades?.compactMap({"\($0.sub_category_id)"}).joined(separator: ",")
        //register.trade_skills = "\(selectedTrades?.first?.sub_category_id ?? 0)"
        
        guard let workingPlace = self.selectedWorkingPlace else {
            self.showAlert(message: "Please selected your working area.")
            return nil
        }
        register.working_area = workingPlace.workingArea
        register.latitude = workingPlace.latitude
        register.longitude = workingPlace.longitude
        register.city = workingPlace.city
        
        guard let hourlyRate = valueCache[EditProfileRow.paymentOption.indexPath]?.validOptionalString else {
            self.showAlert(message: "Please select payment option.")
            return nil
        }
        register.hourly_rate = hourlyRate
        
        guard let paymentRate = valueCache[EditProfileRow.rate.indexPath]?.validOptionalString else {
            self.showAlert(message: "Please enter your rate.")
            return nil
        }
        register.payment_rate = paymentRate
        
        guard let travelCostPerMile = valueCache[EditProfileRow.travelCostPerMile.indexPath]?.validOptionalString else {
            self.showAlert(message: "Please enter Travel Cost Per Mile.")
            return nil
        }
        register.travel_cost_per_mile = travelCostPerMile
        
        guard self.qualificationPhotos.count > 0 else {
            self.showAlert(message: "Please upload your Qualifications/Certificates.")
            return nil
        }
        
        /*
        guard self.insurancePhotos.count > 0 else {
            self.showAlert(message: "Please upload your insurance photo.")
            return nil
        }
        
        guard self.workPhotos.count > 0 else {
            self.showAlert(message: "Please upload photos to Photo Gallery.")
            return nil
        }
        
        
        guard self.accreditationsPhotos.count > 0 else {
            self.showAlert(message: "Please upload accreditations photo.")
            return nil
        }
        */
        //register.insurance = insurance
        //register.accreditations = accreditation
        
        return register
    }
    
    // MARK: - Image Upload Preparation Logic. -
    private func prepareImages() -> [String: UIImage]? {
        var cursor = 0
        var items = [String: UIImage]()
        if let profileImage = self.profileImage {
            items["image"] = profileImage
            cursor += 1
        }
        let validWorkPhotos = workPhotos.compactMap({$0.renderImage})
        if validWorkPhotos.count != 0 {
            for (index, workPhoto) in validWorkPhotos.enumerated() {
                var name = "image"
                if cursor > 0 {
                    name += "\(index + cursor)"
                }
                self.workImagesTrack.append(name)
                items[name] = workPhoto
                cursor += 1
            }
        }
        
        let validQualificationPhotos = qualificationPhotos.compactMap({$0.renderImage})
        if validQualificationPhotos.count != 0 {
            for (index, qualification) in validQualificationPhotos.enumerated() {
                var name = "image"
                if cursor > 0 {
                    name += "\(index + cursor)"
                }
                self.qualificationImagesTrack.append(name)
                items[name] = qualification
                cursor += 1
            }
        }
        
        let validInsurancePhotos = insurancePhotos.compactMap({$0.renderImage})
        if validInsurancePhotos.count != 0 {
            for (index, insurance) in validInsurancePhotos.enumerated() {
                var name = "image"
                if cursor > 0 {
                    name += "\(index + cursor)"
                }
                self.insuranceImageTrack.append(name)
                items[name] = insurance
                cursor += 1
            }
        }
        
        let validAccreditationPhotos = accreditationsPhotos.compactMap({$0.renderImage})
        if validAccreditationPhotos.count != 0 {
            for (index, accreditation) in validAccreditationPhotos.enumerated() {
                var name = "image"
                if cursor > 0 {
                    name += "\(index + cursor)"
                }
                self.accrediationImageTrack.append(name)
                items[name] = accreditation
                cursor += 1
            }
        }
        
        return items.count == 0 ? nil : items
    }
    
    func updateImagesValues(in register: Register, from uploadedImages: [String: String]) {
        if workImagesTrack.count > 0 {
            var workImageParameters = [ImageParameter]()
            for imageName in workImagesTrack {
                if let uploadedName = uploadedImages[imageName] {
                    workImageParameters.append(ImageParameter(image: uploadedName))
                }
            }
            register.UserWorkimage = workImageParameters
        }
        
        if qualificationImagesTrack.count > 0 {
            var qualificationParameters = [ImageParameter]()
            for imageName in qualificationImagesTrack {
                if let uploadedName = uploadedImages[imageName] {
                    qualificationParameters.append(ImageParameter(image: uploadedName))
                }
            }
            register.UserQualification = qualificationParameters
        }
        if insuranceImageTrack.count > 0 {
            register.insurance = uploadedImages[insuranceImageTrack.first ?? ""] ?? ""
        }
        if accrediationImageTrack.count > 0 {
            register.accreditations = uploadedImages[accrediationImageTrack.first ?? ""] ?? ""
        }
    }
    
    func deleteWorkImages(at indexPath: IndexPath) {
        if workPhotos[indexPath.item].renderImage != nil {
            self.workPhotos.remove(at: indexPath.item)
            return
        }
        guard let remoteImage = workPhotos[indexPath.row].remoteImage else { return }
        let deleteRequest = DeleteImageRequest(image_id: remoteImage.id, tablename: .userWorkImage)
        AppHUD.shared.showHUD()
        provider.webResource.deleteImage(request: deleteRequest) { [weak self] (result) in
            AppHUD.shared.hideHUD()
            switch result {
            case .success:
                self?.workPhotos.remove(at: indexPath.item)
                self?.tableView.reloadData()
            case .failure(let error):
                self?.showAlert(for: error)
            }
        }
    }
    
    func deleteQualificationImage(at indexPath: IndexPath) {
        if qualificationPhotos[indexPath.item].renderImage != nil {
            self.qualificationPhotos.remove(at: indexPath.item)
            return
        }
        guard let remoteImage = qualificationPhotos[indexPath.row].remoteImage else { return }
        let deleteRequest = DeleteImageRequest(image_id: remoteImage.id, tablename: .userQualifications)
        AppHUD.shared.showHUD()
        provider.webResource.deleteImage(request: deleteRequest) { [weak self] (result) in
            AppHUD.shared.hideHUD()
            switch result {
            case .success:
                self?.qualificationPhotos.remove(at: indexPath.item)
                self?.tableView.reloadData()
            case .failure(let error):
                self?.showAlert(for: error)
            }
        }
    }
    
    func deleteInsuranceImage(at indexPath: IndexPath) {
        if self.insurancePhotos[safe: indexPath.item]?.remoteImage != nil {
            self.insurancePhotos.remove(at: indexPath.item)
            self.tableView.reloadData()
            return
        }
    }
    
    func deleteAccreditationImage(at indexPath: IndexPath) {
        if self.accreditationsPhotos[safe: indexPath.item]?.remoteImage != nil {
            self.accreditationsPhotos.remove(at: indexPath.item)
            self.tableView.reloadData()
            return
        }
    }

}

// MARK: - Dependency Init -
extension EditProfileViewController {
    static func initialise(provider: DependencyProvider) -> EditProfileViewController {
        let vc = EditProfileViewController.instantiate(from: .main)
        vc.title = "Edit Profile".uppercased()
        vc.provider = provider
        return vc
    }
}


// MARK: - TableView Delegate -
extension EditProfileViewController: UITableViewDelegate {
    
}

// MARK: - TableView DataSource -
extension EditProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowType = self.dataSource[indexPath.row]
        switch rowType {
        case .field(let fieldRow):
            let cell = fieldRow.dequeueReusableCell(from: tableView, at: indexPath)!
            if self.valueCache[indexPath] == nil {
                self.valueCache[indexPath] = fieldRow.value.value
            }
            cell.configure(with: fieldRow.value, value: self.valueCache[indexPath], indexPath: indexPath)
            cell.onTextChange = { [weak self] (selectedIndexPath, text) in
                self?.valueCache[selectedIndexPath] = text
            }
            cell.onSelection = { [weak self] (selectedIndexPath) in
               self?.handleSelection(at: selectedIndexPath)
            }
            return cell
        case .profileImages(let profileRow):
            let cell = profileRow.dequeueReusableCell(from: tableView, at: indexPath)!
            //cell.onAddAction = { [weak self] (count) in
            //    self?.imageDestination = .photos
            //    self?.handlePicker(for: .photos, count: count)
            //}
            cell.onProfilePhotoAction = { [weak self] (count) in
                self?.imageDestination = .profile
                self?.handlePicker(for: .profile, count: count)
            }
            //cell.onDataSourceChanges = { [weak self] (images) in
            //    self?.workPhotos = images
            //}
            //cell.onDeleteAction = { [weak self] (selectedIndexPath) in
            //    self?.deleteWorkImages(at: selectedIndexPath)
            //}
            //cell.add(images: workPhotos)
            if let pickedImage = self.profileImage {
                cell.profileImageView.image = pickedImage
            } else {
                cell.profileImageView.placeholder = #imageLiteral(resourceName: "userPlaceholder")
                cell.profileImageView.shouldShowIndicator = false
                cell.profileImageView.urlString = user.profileImage
            }
            return cell
            
        case .insurance(let insuranceRow):
            let cell = insuranceRow.dequeueReusableCell(from: tableView, at: indexPath)!
            cell.configure(with: insuranceRow.value.0, detail: insuranceRow.value.1, actionTitle: insuranceRow.value.2)
            cell.onAddAction = { [weak self] count in
                self?.imageDestination = .insurance
                self?.handlePicker(for: .insurance, count: count)
            }
            cell.onDataSourceChange = { [weak self] images in
                self?.insurancePhotos = images
            }
            cell.onDeleteAction = { [weak self] selectedIndexPath in
                self?.deleteInsuranceImage(at: selectedIndexPath)
            }
            cell.add(images: insurancePhotos)
            return cell
            
        case .accreditation(let accreditationRow):
            let cell = accreditationRow.dequeueReusableCell(from: tableView, at: indexPath)!
            cell.configure(with: accreditationRow.value.0, detail: accreditationRow.value.1, actionTitle: accreditationRow.value.2)
            cell.onAddAction = { [weak self] count in
                self?.imageDestination = .accreditation
                self?.handlePicker(for: .accreditation, count: count)
            }
            cell.onDataSourceChange = { [weak self] images in
                self?.accreditationsPhotos = images
            }
            cell.onDeleteAction = { [weak self] selectedIndexPath in
                self?.deleteAccreditationImage(at: selectedIndexPath)
            }
            cell.add(images: accreditationsPhotos)
            return cell
            
        case .workExperience(let experienceRow):
            let cell = experienceRow.dequeueReusableCell(from: tableView, at: indexPath)!
            cell.configure(with: experienceRow.value.0, detail: experienceRow.value.1, actionTitle: experienceRow.value.2)
            cell.onAddAction = { [weak self] (count) in
                self?.imageDestination = .photos
                self?.handlePicker(for: .photos, count: count)
            }
            cell.onDeleteAction = { [weak self] (selectedIndexPath) in
                self?.deleteWorkImages(at: selectedIndexPath)
            }
            cell.add(images: workPhotos)
            return cell
            
        case .qualificationUpload(let qualificationRow):
            let cell = qualificationRow.dequeueReusableCell(from: tableView, at: indexPath)!
            cell.configure(with: qualificationRow.value.0, detail: qualificationRow.value.1, actionTitle: qualificationRow.value.2)
            cell.onAddAction = { [weak self] (count) in
                self?.imageDestination = .certificates
                self?.handlePicker(for: .certificates, count: count)
            }
            cell.onDataSourceChange = { [weak self] images in
                self?.qualificationPhotos = images
            }
            cell.onDeleteAction = { [weak self] (selectedIndexPath) in
                self?.deleteQualificationImage(at: selectedIndexPath)
            }
            cell.add(images: qualificationPhotos)
            return cell
            
        case .selection(let selectionRow):
            let cell = selectionRow.dequeueReusableCell(from: tableView, at: indexPath)!
            return cell
            
        case .updateProfile(let updateActionRow):
            let cell = updateActionRow.dequeueReusableCell(from: tableView, at: indexPath)!
            cell.configure(with: updateActionRow.value)
            if self.uploadingState {
                cell.updateButton.startAnimating()
            } else {
                cell.updateButton.stopAnimating()
            }
            cell.onAction = { [weak self] (sender) in
                self?.uploadImages(sender: sender)
            }
            return cell
        }
    }
}

// MARK: - ImagePickerController Delegate
extension EditProfileViewController: ImagePickerDiplaying, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            self.insertImage(image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - GMSAutoComplete Delegate
extension EditProfileViewController: GMSAutocompleteViewControllerDelegate {
    
    private func updateWorkingPlaceFieldValue() {
        let indexPath = EditProfileRow.workingArea.indexPath
        self.valueCache[indexPath] = self.selectedWorkingPlace?.workingArea
        self.tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.selectedWorkingPlace = WorkingPlace(place: place)
        self.updateWorkingPlaceFieldValue()
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print(error)
        viewController.dismiss(animated: true, completion: nil)
    }
}

// MARK: - API -
extension EditProfileViewController {
    func fetchServiceTradeList() {
        let serviceCell = tableView.cellForRow(at: EditProfileRow.tradeType.indexPath) as? EditProfileFieldCell
        let tradeCell = tableView.cellForRow(at: EditProfileRow.subtrade.indexPath) as? EditProfileFieldCell
        
        let serviceField = serviceCell?.textField
        let tradeField = tradeCell?.textField
        
        serviceField?.startAnimating()
        tradeField?.startAnimating()
        provider.webResource.serviceAndTradeList { [weak self] (result) in
            serviceField?.stopAnimating()
            tradeField?.stopAnimating()
            switch result {
            case .success(let list):
                self?.serviceList = list.service ?? []
                self?.updateTradeSkills()
                break
            case .failure(let error):
                self?.showAlert(for: error)
            }
        }
    }
    
    private func updateProfileAction(register: Register, sender: IndicatorButton) {
        self.tableView.isUserInteractionEnabled = false
        sender.startAnimating()
        self.uploadingState = true
        provider.webResource.updateProfile(register: register) { [weak self] (result) in
            self?.uploadingState = false
            self?.tableView.isUserInteractionEnabled = true
            sender.stopAnimating()
            switch result {
            case .success:
                self?.navigationController?.popViewController(animated: true)
            case .failure(let error):
                self?.showAlert(for: error)
            }
        }
    }
    
    private func uploadImages(sender: IndicatorButton) {
        impactFeedbackGenerator.impactOccurred(withIntensity: 0.5)
        guard let register = self.validate() else { return }
        guard let images = self.prepareImages() else {
            self.updateProfileAction(register: register, sender: sender)
            return
        }
        self.uploadingState = true
        sender.startAnimating()
        provider.webResource.upload(images: images, progress: { percentage in
            sender.updateProgress(progress: percentage)
        }) { [weak self] (result) in
            self?.uploadingState = false
            sender.stopAnimating()
            switch result {
            case .success(let response):
                if let uploadedImages = response.data {
                    if self?.profileImage != nil {
                        register.profile_image = uploadedImages["image"]
                    }
                    self?.updateImagesValues(in: register, from: uploadedImages)
                    self?.updateProfileAction(register: register, sender: sender)
                }
            case .failure(let error):
                print(error)
                self?.showAlert(for: error)
                sender.updateProgress(progress: 0)
            }
        }
    }
}

// MARK: - GMSPlace with WorkingPlace. -
extension WorkingPlace {
    init(place: GMSPlace) {
        self.city = place.city
        self.latitude = "\(place.coordinate.latitude)"
        self.longitude = "\(place.coordinate.longitude)"
        self.workingArea = place.formattedAddress ?? ""
    }
    
    init(with user: User) {
        self.city = user.city
        self.latitude = user.latitude
        self.longitude = user.longitude
        self.workingArea = user.workingArea ?? ""
    }
}
