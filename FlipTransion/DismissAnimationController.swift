//
//  DismissAnimationController.swift
//  FlipTransion
//
//  Created by 从今以后 on 15/7/19.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

import UIKit

class DismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    let transitionDuration: NSTimeInterval = 1

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return transitionDuration
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

        let containerView = transitionContext.containerView()

        let presentingVC  = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let presentedVC   = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!

        let finalFrame    = transitionContext.finalFrameForViewController(presentingVC)

        let coverView     = UIView(frame: finalFrame)

        coverView.alpha               = 0.8
        coverView.backgroundColor     = UIColor.blackColor()
        coverView.layer.anchorPoint.x = 0
        coverView.layer.position.x    = finalFrame.minX
        coverView.layer.transform     = CATransform3DMakeRotation(CGFloat(-M_PI_2), 0, 1, 0)

        presentingVC.view.layer.shouldRasterize    = true
        presentingVC.view.layer.rasterizationScale = UIScreen.mainScreen().scale
        presentingVC.view.layer.anchorPoint.x      = 0
        presentingVC.view.layer.position.x         = finalFrame.minX
        presentingVC.view.layer.transform          = CATransform3DMakeRotation(CGFloat(-M_PI_2), 0, 1, 0)

        containerView.layer.sublayerTransform.m34 = -1 / 1_000
        containerView.addSubview(presentingVC.view)
        containerView.addSubview(coverView)

        UIView.animateWithDuration(transitionDuration, delay: 0, options: .CurveLinear, animations: {

            coverView.alpha                   = 0
            coverView.layer.transform         = CATransform3DIdentity

            presentingVC.view.layer.transform = CATransform3DIdentity

        }, completion: { _ in

            coverView.removeFromSuperview()

            presentingVC.view.layer.shouldRasterize = false
            presentingVC.view.layer.anchorPoint.x   = 0.5
            presentingVC.view.layer.position.x      = finalFrame.midX

            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }
}