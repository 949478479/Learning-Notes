//
//  DismissAnimationController.swift
//  FlipTransion
//
//  Created by 从今以后 on 15/7/19.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

import UIKit

private let kTransitionDuration: NSTimeInterval = 1

class DismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return kTransitionDuration
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

        let presentingVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! PresentingViewController
        let presentedVC  = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! PresentedViewController

        let finalFrame = transitionContext.finalFrameForViewController(presentingVC)

        let coverView: UIView = {
            let cover                 = UIView(frame: presentingVC.view.bounds)
            cover.alpha               = 0.8
            cover.backgroundColor     = UIColor.blackColor()
            cover.layer.anchorPoint.x = 0
            cover.layer.position.x    = finalFrame.minX
            cover.layer.transform     = CATransform3DMakeRotation(CGFloat(-M_PI_2), 0, 1, 0)
            return cover
        }()
        
        presentingVC.view.layer.shouldRasterize    = true
        presentingVC.view.layer.rasterizationScale = UIScreen.mainScreen().scale
        presentingVC.view.layer.anchorPoint.x      = 0
        presentingVC.view.layer.position.x         = finalFrame.minX
        presentingVC.view.layer.transform          = CATransform3DMakeRotation(CGFloat(-M_PI_2), 0, 1, 0)

        let containerView = transitionContext.containerView()
        containerView.layer.sublayerTransform.m34 = -1 / 1_000
        containerView.addSubview(presentingVC.view)
        containerView.addSubview(coverView)

        UIView.animateWithDuration(kTransitionDuration, delay: 0, options: .CurveLinear, animations: {
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