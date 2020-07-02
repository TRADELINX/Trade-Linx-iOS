//
//  ImagePickerDisplaying.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/4/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit
import Photos

protocol ImagePickerDiplaying: class {
    func pickerAction(sourceType : UIImagePickerController.SourceType)
    func alertForPermissionChange(forFeature feature: String, library: String, action: String)
    func cameraAccessPermissionCheck(completion: @escaping (Bool) -> Void)
    func photosAccessPermissionCheck(completion: @escaping (Bool)->Void)
}

extension ImagePickerDiplaying where Self: UIViewController & UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func showMediaPickerOptions() {
        let fromCameraAction = UIAlertAction(title: "Capture Image from Camera", style: .default) { (_) in
            self.pickerAction(sourceType: .camera)
        }
        
        let fromPhotoLibraryAction = UIAlertAction(title: "Select from Photos library", style: .default) { (_) in
            self.pickerAction(sourceType: .photoLibrary)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(fromCameraAction)
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(fromPhotoLibraryAction)
        }
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func pickerAction(sourceType : UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let picker = UIImagePickerController()
            picker.sourceType = sourceType
            picker.delegate = self
            if sourceType == .camera {
                self.cameraAccessPermissionCheck(completion: { (success) in
                    if success {
                        self.present(picker, animated: true, completion: nil)
                    }else {
                        self.alertForPermissionChange(forFeature: "Camera", library: "Camera", action: "take photos of QR code")
                    }
                })
            }
            if sourceType == .photoLibrary {
                self.photosAccessPermissionCheck(completion: { (success) in
                    if success {
                        self.present(picker, animated: true, completion: nil)
                    }else {
                        self.alertForPermissionChange(forFeature: "Photos", library: "Photo Library", action: "select QR code photo")
                    }
                })
            }
            
        }
    }
    
    func alertForPermissionChange(forFeature feature: String, library: String, action: String) {
        let settingsAction = UIAlertAction(title: "Open Settings", style: .default) { (_) in
            UIApplication.shared.openSettings()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Please enable camera access from Settings > reiwa.com > Camera to take photos
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "App"
        let alert = UIAlertController(title: "\"\(appName)\" Would Like to Access the \(library)", message: "Please enable \(library) access from Settings > \(appName) > \(feature) to \(action)", preferredStyle: .alert)
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func cameraAccessPermissionCheck(completion: @escaping (Bool) -> Void) {
        let cameraMediaType = AVMediaType.video
        let cameraAutherisationState = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
        switch cameraAutherisationState {
        case .authorized:
            completion(true)
        case .denied, .notDetermined, .restricted:
            AVCaptureDevice.requestAccess(for: cameraMediaType, completionHandler: { (granted) in
                DispatchQueue.main.async {
                    completion(granted)
                }
            })
        }
    }
    
    func photosAccessPermissionCheck(completion: @escaping (Bool)->Void) {
        let photosStatus = PHPhotoLibrary.authorizationStatus()
        switch photosStatus {
        case .authorized:
            completion(true)
        case .denied, .notDetermined, .restricted:
            PHPhotoLibrary.requestAuthorization({ (status) in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized:
                        completion(true)
                    default:
                        completion(false)
                    }
                }
            })
        }
    }
    
}

extension UIApplication {
    func openSettings() {
        let url = URL(string: UIApplication.openSettingsURLString)!
        if canOpenURL(url) {
            open(url, options: [:], completionHandler: nil)
        }
    }
}
