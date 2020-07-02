//
//  CommentsController.swift
//  MartinsApp
//
//  Created by Neil Jain on 10/19/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class CommentsController: UINavigationController {

    var sourceView: UIView!
    var sourceRect: CGRect!

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        if #available(iOS 13, *) {
            setup()
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }
    
    private lazy var animator: CommentsAnimator = {
        let animator = CommentsAnimator()
        animator.sourceView = self.sourceView
        animator.sourceRect = self.sourceRect
        return animator
    }()

}

extension CommentsController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.isPresenting = false
        return animator
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.isPresenting = true
        return animator
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CommentsPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
