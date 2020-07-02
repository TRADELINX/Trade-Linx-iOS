//
//  PreviewAnimator.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/2/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class PreviewAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum PresentationMode {
        case picker
        case popup
    }
    
    override init() {
        super.init()
    }
    
    var duration: CGFloat = 0.5
    var cornerRadius: CGFloat = 15.0
    var darkViewOpacity: CGFloat = 0.5
    
    var leftPadding: CGFloat = 20
    var width: CGFloat? = nil
    
    var topPadding: CGFloat = 100
    var height: CGFloat? = nil
    
    var touchEvent: ()->Void = {}
    var mode: PresentationMode = .popup
    
    init(duration: CGFloat = 0.5, cornerRadius: CGFloat = 8.0, width: CGFloat? = nil, height: CGFloat? = nil, mode: PresentationMode = .popup) {
        self.duration = duration
        self.cornerRadius = cornerRadius
        self.width = width
        self.height = height
        self.mode = mode
    }
    
    var isPresenting: Bool = true
    
    fileprivate lazy var darkView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(self.darkViewOpacity)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(darkViewTouched)))
        return view
    }()
    
    @objc func darkViewTouched() {
        self.touchEvent = {}
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(duration)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let toView = isPresenting ? transitionContext.view(forKey: UITransitionContextViewKey.to)! : transitionContext.view(forKey: UITransitionContextViewKey.from)!
        
        toView.layer.cornerRadius = cornerRadius
        toView.layer.masksToBounds = true
        
        let containerView = transitionContext.containerView
        
        containerView.addSubview(darkView)
        darkView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        darkView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        darkView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        darkView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        var afterAlpha: CGFloat = 1
        if mode == .picker {
            afterAlpha = 0.2
        }
        darkView.alpha = isPresenting ? 0 : afterAlpha
        
        containerView.addSubview(toView)
        
        if mode == .popup {
            toView.frame = CGRect(x: 0, y: 0, width: width ?? containerView.frame.width - (2 * leftPadding), height: height ?? containerView.frame.height - (2 * topPadding))
            toView.center.y = containerView.center.y
        } else {
            let calculatedHeight = height ?? 320
            let totalHeight = containerView.frame.height
            let yPosition = totalHeight - calculatedHeight
            toView.frame = CGRect(x: 0, y: yPosition, width: containerView.frame.width, height: calculatedHeight)
        }
        toView.center.x = containerView.center.x
        
        toView.transform = isPresenting ? CGAffineTransform(translationX: 0, y: containerView.frame.height) : CGAffineTransform.identity
        
        UIView.animate(withDuration: TimeInterval(duration), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            if self.isPresenting {
                toView.transform = CGAffineTransform.identity
                self.darkView.alpha = afterAlpha
            }else {
                toView.transform = CGAffineTransform(translationX: 0, y: containerView.frame.height)
                self.darkView.alpha = 0
            }
        }) { (success) in
            transitionContext.completeTransition(success)
        }
        
    }
    
    deinit {
        print("Deinit called from PreviewAnimator")
    }

}

extension PreviewAnimator: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = false
        return self
    }
}
