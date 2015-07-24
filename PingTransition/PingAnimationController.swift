//
//  PingAnimationController.swift
//  PingTransition
//
//  Created by 从今以后 on 15/7/24.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

import UIKit

class PingAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    private let transitionDuration = 1.0
    private var transitionContext: UIViewControllerContextTransitioning!

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return transitionDuration
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext

        let fromVC = transitionContext.viewControllerForKey(
            UITransitionContextFromViewControllerKey) as! PresentingViewController
        let toVC   = transitionContext.viewControllerForKey(
            UITransitionContextToViewControllerKey) as! PresentedViewController

        toVC.view.layer.mask = CAShapeLayer()
        transitionContext.containerView().addSubview(toVC.view)

        let radius = sqrt(
            pow(fromVC.button.frame.midX, 2) +
            pow(fromVC.view.bounds.height - fromVC.button.frame.midY, 2)
        )

        let animation = CABasicAnimation(keyPath: "path")
        animation.delegate  = self
        animation.duration  = transitionDuration
        animation.fromValue = CGPathCreateWithEllipseInRect(fromVC.button.frame, nil)
        animation.toValue   = CGPathCreateWithEllipseInRect(CGRectInset(fromVC.button.frame, -radius, -radius), nil)
        toVC.view.layer.mask.addAnimation(animation, forKey: nil)
    }
}

extension PingAnimationController {
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        transitionContext.completeTransition(true)
        
        (transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
            as! PresentedViewController).view.layer.mask = nil
    }
}