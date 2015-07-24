//
//  PingAnimationController.swift
//  PingTransition
//
//  Created by 从今以后 on 15/7/24.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

import UIKit

class PingAnimationController: NSObject {

    let transitionDuration = 1.0

    var transitionContext: UIViewControllerContextTransitioning!

    var presentingViewController: UIViewController {
        return transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
    }

    var presentedViewController: UIViewController {
        return transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
    }

    var fromViewController: UIViewController {
        return presentingViewController
    }

    func maskLayerPathRadiusForButtonFrame(frame: CGRect) -> CGFloat {
        return sqrt(
            pow(frame.midX, 2) +
            pow(fromViewController.view.bounds.height - frame.midY, 2)
        )
    }

    func animationValuesForFromViewController(fromVC: UIViewController) -> (CGPathRef, CGPathRef) {
        let buttonFrame = (fromVC as! PresentingViewController).button.frame
        let pathRadius  = maskLayerPathRadiusForButtonFrame(buttonFrame)
        return (
            CGPathCreateWithEllipseInRect(buttonFrame, nil),
            CGPathCreateWithEllipseInRect(CGRectInset(buttonFrame, -pathRadius, -pathRadius), nil)
        )
    }
}

extension PingAnimationController: UIViewControllerAnimatedTransitioning {

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return transitionDuration
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext

        presentedViewController.view.layer.mask = CAShapeLayer()
        transitionContext.containerView().addSubview(presentingViewController.view)
        transitionContext.containerView().addSubview(presentedViewController.view)

        let animationValues = animationValuesForFromViewController(fromViewController)

        let animation = CABasicAnimation(keyPath: "path")
        animation.delegate  = self
        animation.duration  = transitionDuration
        animation.fromValue = animationValues.0
        animation.toValue   = animationValues.1
        presentedViewController.view.layer.mask.addAnimation(animation, forKey: nil)
    }
}

extension PingAnimationController {
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        transitionContext.completeTransition(true)
        presentedViewController.view.layer.mask = nil
    }
}