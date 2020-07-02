//
//  AddIntroductionController.swift
//  MartinsApp
//
//  Created by Neil Jain on 10/19/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class AddIntroductionController: UIViewController {
    let maxCharactersLimit = 200
    var onSaveAction: ((String)->Void)?
    var defaultText: String?

    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var saveButton: ShadowButton!
    
    private lazy var characterCountItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "\(maxCharactersLimit)", style: .plain, target: nil, action: nil)
        return item
    }()
    
    private lazy var cancelButton: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelAction))
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textView.becomeFirstResponder()
    }
    
    private func setup() {
        self.instructionLabel.text = "Please enter about yourself. Max characters \(maxCharactersLimit) allowed."
        self.saveButton.color = UIColor.tintBlue
        self.saveButton.tintColor = .white
        
        self.textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        self.textView.delegate = self
        self.textView.alwaysBounceVertical = true
        self.textView.keyboardDismissMode = .onDrag
        
        self.textView.text = defaultText
        self.updateCharacterCount()
        
        self.navigationItem.rightBarButtonItem = characterCountItem
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    @objc private func cancelAction(_ sender: UIBarButtonItem) {
        self.textView.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    private func updateCharacterCount() {
        let characterCount = textView.text?.count ?? 0
        self.characterCountItem.title = "\(maxCharactersLimit - characterCount)"
    }
    
    @IBAction func saveAction() {
        self.textView.resignFirstResponder()
        self.onSaveAction?(self.textView.text)
        self.dismiss(animated: true, completion: nil)
    }

}

extension AddIntroductionController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        updateCharacterCount()
        return newText.count <= maxCharactersLimit
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.updateCharacterCount()
    }
}
