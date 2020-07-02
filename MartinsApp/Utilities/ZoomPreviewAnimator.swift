//
//  ZoomPreviewAnimator.swift
//  MartinsApp
//
//  Created by Neil Jain on 10/10/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class ZoomPreviewAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var isPresenting: Bool = true
    
    var duration: TimeInterval = 0.5
    
    var sourceView: UIView!
    var sourceRect: CGRect!
    var destinationRect: CGRect!
    var leftPadding: CGFloat = 20
    var width: CGFloat?
    var topPadding: CGFloat = 100
    var height: CGFloat?
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator()
    
    override init() {
        super.init()
        impactFeedbackGenerator.prepare()
    }
    
    private lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        sourceView.alpha = 1
        guard
            let toVC = self.isPresenting ? transitionContext.viewController(forKey: .to) : transitionContext.viewController(forKey: .from),
            let originalSourceView = sourceView,
            let sourceView = sourceView.snapshotView(afterScreenUpdates: true),
            let sourceRect = sourceRect
        else { return }
        
        let containerView = transitionContext.containerView
        
        self.destinationRect = CGRect(x: 0,
                                      y: 0,
                                      width: width ?? containerView.frame.width - (2 * leftPadding),
                                      height: height ?? containerView.frame.height - (2 * topPadding))
        
        containerView.addSubview(shadowView)
        shadowView.frame = containerView.bounds
        
        let isPresenting = self.isPresenting

        containerView.addSubview(sourceView)
        
        originalSourceView.alpha = 0
        sourceView.frame = sourceRect
        containerView.addSubview(toVC.view)
        
        let sourceViewCenter = sourceView.center
        
        toVC.view.frame = destinationRect
        toVC.view.center = isPresenting ? CGPoint(x: sourceRect.midX, y: sourceRect.midY) : containerView.center
        toVC.view.layer.cornerRadius = isPresenting ? destinationRect.width/2 : 8
        toVC.view.layer.masksToBounds = true
        toVC.view.transform = isPresenting ? self.transform(fromRect: sourceRect, toRect: destinationRect) : .identity
        toVC.view.alpha = isPresenting ? 0 : 1
        shadowView.alpha = isPresenting ? 0 : 1
        
        if !isPresenting {
            sourceView.alpha = 0
            sourceView.center = containerView.center
            sourceView.transform = self.squareTransform(fromRect: toVC.view.frame, toRect: sourceRect)
            containerView.bringSubviewToFront(sourceView)
        }
        impactFeedbackGenerator.impactOccurred(withIntensity: 1)
        
        let dampingRatio: CGFloat = isPresenting ? 1 : 0.8
        
        let alphaAnimator = UIViewPropertyAnimator(duration: duration, timingParameters: UICubicTimingParameters(animationCurve: isPresenting ? .easeOut : .easeIn))
        alphaAnimator.addAnimations {
            UIView.animateKeyframes(withDuration: self.duration, delay: 0, options: [.calculationModeCubic], animations: {
                UIView.addKeyframe(withRelativeStartTime: self.isPresenting ? 0.3 : 0, relativeDuration: isPresenting ? 0.5 : 0.2) {
                    toVC.view.alpha = isPresenting ? 1 : 0
                    sourceView.alpha = isPresenting ? 0 : 1
                }
                let cornerRadiusStartTime = self.isPresenting ? 0.5 : 0
                UIView.addKeyframe(withRelativeStartTime: cornerRadiusStartTime, relativeDuration: isPresenting ? 0.2 : 0.5) {
                    toVC.view.layer.cornerRadius = isPresenting ? 8 : self.destinationRect.width/2
                }
            }, completion: nil)
        }
        alphaAnimator.startAnimation()
        
        let springTiming = UISpringTimingParameters(dampingRatio: dampingRatio)
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: springTiming)
        
        animator.addAnimations {
            toVC.view.transform = isPresenting ? .identity : self.transform(fromRect: sourceRect, toRect: self.destinationRect)
            toVC.view.center = isPresenting ? containerView.center : sourceViewCenter
            sourceView.center = isPresenting ? containerView.center : sourceViewCenter
            sourceView.transform = isPresenting ? self.squareTransform(fromRect: self.destinationRect, toRect: sourceRect) : .identity
            self.shadowView.alpha = isPresenting ? 1 : 0
        }
        
        animator.addCompletion { (position) in
            if !self.isPresenting && position == .end {
                self.shadowView.removeFromSuperview()
                originalSourceView.alpha = 1
                self.impactFeedbackGenerator.impactOccurred(withIntensity: 0.3)
            }
            transitionContext.completeTransition(true)
        }
        animator.startAnimation()
    }
    
    private func transform(fromRect: CGRect, toRect: CGRect) -> CGAffineTransform {
        let scaleX = fromRect.width / toRect.width
        let scaleY = fromRect.height / toRect.height
        return CGAffineTransform(scaleX: scaleX, y: scaleY)
    }
    
    private func squareTransform(fromRect: CGRect, toRect: CGRect) -> CGAffineTransform {
        let scaleX = fromRect.width / toRect.width
        return CGAffineTransform(scaleX: scaleX, y: scaleX)
    }
    
    deinit {
        print("Deinit called from ZoomPreviewAnimator")
    }
    
}

extension ZoomPreviewAnimator: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = false
        return self
    }
}

extension CGRect {
    var squared: CGRect {
        let width = min(self.width, self.height)
        return CGRect(origin: self.origin, size: CGSize(width: width, height: width))
    }
}
