//
//  CommentsAnimator.swift
//  FractoCal
//
//  Created by Neil Jain on 10/17/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit

class CommentsAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var duration: TimeInterval = 0.5
    var isPresenting: Bool = true
    var sourceView: UIView!
    var sourceRect: CGRect!
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        sourceView.alpha = 1
        guard let toVC = isPresenting ? transitionContext.viewController(forKey: .to) : transitionContext.viewController(forKey: .from) else { return }
        guard let originalSourceView = sourceView, let toView = toVC.view else { return }
        guard let sourceView = sourceView.snapshotView(afterScreenUpdates: true), let sourceRect = sourceRect else { return }
        
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)
    
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1.0)
        originalSourceView.alpha = 0
        
        if isPresenting {
            containerView.addSubview(toView)
            toView.frame = finalFrame
            toView.center = sourceRect.center
            toView.transform = transform(from: finalFrame, to: sourceRect)
            toView.alpha = 0
            
            sourceView.center = sourceRect.center
            animator.addAnimations {
                sourceView.center = finalFrame.center
                sourceView.transform = self.transform(from: sourceRect, to: finalFrame)
                sourceView.alpha = 0
                toView.center = finalFrame.center
                toView.transform = .identity
                toView.alpha = 1
            }
            
        } else {
            containerView.addSubview(sourceView)
            toView.center = finalFrame.center
            sourceView.frame = sourceRect
            sourceView.center = finalFrame.center
            sourceView.transform = self.transform(from: sourceRect, to: finalFrame)
            sourceView.alpha = 0
            
            animator.addAnimations {
                sourceView.alpha = 1
                sourceView.center = sourceRect.center
                sourceView.transform = .identity
                toView.alpha = 0
                toView.center = sourceRect.center
                toView.transform = self.transform(from: finalFrame, to: sourceRect)
            }
        }
        
        animator.addCompletion { (position) in
            if position == .end {
                if !self.isPresenting {
                    originalSourceView.alpha = 1
                }
                transitionContext.completeTransition(true)
            } else {
                transitionContext.completeTransition(false)
                animator.isReversed = true
                animator.finishAnimation(at: .start)
            }
        }
        
        animator.startAnimation()
        
    }
    
    private func transform(from sourceRect: CGRect, to destinationRect: CGRect) -> CGAffineTransform {
        let scaleX = destinationRect.width / sourceRect.width
        let scaleY = destinationRect.height / sourceRect.height
        
        let minScale = min(scaleX, scaleY)
        return CGAffineTransform(scaleX: minScale, y: minScale)
    }

}

fileprivate extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}
