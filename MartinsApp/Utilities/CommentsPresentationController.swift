//
//  CommentsPresentationController.swift
//  FractoCal
//
//  Created by Neil Jain on 10/17/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class CommentsPresentationController: UIPresentationController {
    
    private let chromeView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        view.isUserInteractionEnabled = true
        return view
    }()
    
    override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero
        frame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView!.bounds.size)
        frame.origin.x = 16
        frame.origin.y = (containerView?.safeAreaInsets.top ?? 0) + 8
        return frame
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = self.containerView else { return }
        containerView.addSubview(chromeView)
        chromeView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        chromeView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        chromeView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        chromeView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            chromeView.alpha = 1
            return
        }
        
        coordinator.animate(alongsideTransition: { (_) in
            self.chromeView.alpha = 1
        })
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            chromeView.alpha = 0
            return
        }
        coordinator.animate(alongsideTransition: { _ in
            self.chromeView.alpha = 0
        })
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width - 32, height: 280)
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
        presentedView?.layer.cornerRadius = 16
        presentedView?.layer.masksToBounds = true
    }
    
}
