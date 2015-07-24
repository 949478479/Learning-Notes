//
//  PingInvertAnimationController.swift
//  PingTransition
//
//  Created by 从今以后 on 15/7/24.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

import UIKit

class PingInvertAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    private let transitionDuration = 1.0
    private var transitionContext: UIViewControllerContextTransitioning!

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return transitionDuration
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext

        let fromVC = transitionContext.viewControllerForKey(
            UITransitionContextFromViewControllerKey) as! PresentedViewController
        let toVC   = transitionContext.viewControllerForKey(
            UITransitionContextToViewControllerKey) as! PresentingViewController

        fromVC.view.layer.mask = CAShapeLayer()
        transitionContext.containerView().insertSubview(toVC.view, belowSubview: fromVC.view)

        let radius = sqrt(
            pow(fromVC.button.frame.midX, 2) +
            pow(fromVC.view.bounds.height - fromVC.button.frame.midY, 2)
        )

        let animation = CABasicAnimation(keyPath: "path")
        animation.delegate  = self
        animation.duration  = transitionDuration
        animation.fromValue = CGPathCreateWithEllipseInRect(CGRectInset(fromVC.button.frame, -radius, -radius), nil)
        animation.toValue   = CGPathCreateWithEllipseInRect(fromVC.button.frame, nil)
        fromVC.view.layer.mask.addAnimation(animation, forKey: nil)
    }
}

extension PingInvertAnimationController {
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled())

        (transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
            as! PresentedViewController).view.layer.mask = nil
    }
}