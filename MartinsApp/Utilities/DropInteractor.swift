//
//  DropInteractor.swift
//  MartinsApp
//
//  Created by Neil Jain on 7/7/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class DropInteractor<A: NSItemProviderReading>: NSObject, UIDropInteractionDelegate {
    
    var dropedItems: [A] = []
    
    var onDropCompletion: (([A]) -> Void)?
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: A.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: UIDropOperation.copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        if let localItems = session.localDragSession?.items.compactMap({$0.localObject}) {
            print(localItems)
        }
        session.loadObjects(ofClass: A.self) { (items) in
            guard let contacts = items as? [A] else { return }
            self.dropedItems = contacts
            self.onDropCompletion?(contacts)
        }
    }
    
    lazy var dropInteraction: UIDropInteraction = {
        return UIDropInteraction(delegate: self)
    }()
    
    deinit {
        print("Deinit called fron DropInteractor")
    }
}

class LocalDropInteractor<A>: NSObject, UIDropInteractionDelegate {
    var onDropCompletion: (([A]) -> Void)?
    var onSessionEnd: (()->Void)?
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return true
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        if let localItems = session.localDragSession?.items.compactMap({$0.localObject as? A}) {
            self.onDropCompletion?(localItems)
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnd session: UIDropSession) {
        self.onSessionEnd?()
    }
    
    lazy var dropInteraction: UIDropInteraction = {
        return UIDropInteraction(delegate: self)
    }()
}
