//
//  PresentAnimationController.swift
//  FlipTransion
//
//  Created by 从今以后 on 15/7/19.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

import UIKit

class PresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    let transitionDuration: NSTimeInterval = 1

    var transitionContext: UIViewControllerContextTransitioning?

    var presentintViewController: UIViewController? {
        return transitionContext?.viewControllerForKey(UITransitionContextFromViewControllerKey)
    }

    var presentedViewController: UIViewController? {
        return transitionContext?.viewControllerForKey(UITransitionContextToViewControllerKey)
    }

    var frameForPresentingView: CGRect? {
        if let presentingVC = presentintViewController {
            return transitionContext?.initialFrameForViewController(presentingVC)
        }
        return nil
    }

    func coverViewWithFrame(frame: CGRect) -> UIView {
        let coverView = UIView(frame: frame)
        coverView.alpha               = 0
        coverView.backgroundColor     = UIColor.blackColor()
        coverView.layer.anchorPoint.x = 0
        coverView.layer.frame         = frame
        return coverView
    }

    func configurePresentingView(view: UIView, withFrame frame: CGRect) {
        view.layer.shouldRasterize    = true
        view.layer.rasterizationScale = UIScreen.mainScreen().scale
        view.layer.anchorPoint.x      = 0
        view.layer.frame              = frame
    }

    func animationForPresentingView(view: UIView, coverView: UIView) {
        coverView.alpha           = 0.8
        coverView.layer.transform = CATransform3DMakeRotation(CGFloat(-M_PI_2), 0, 1, 0)
        view.layer.transform      = CATransform3DMakeRotation(CGFloat(-M_PI_2), 0, 1, 0)
    }

    func animationCompletionForPresentingView(view: UIView, coverView: UIView, withFrame frame: CGRect) {
        coverView.removeFromSuperview()

        view.layer.shouldRasterize = false
        view.layer.anchorPoint.x   = 0.5
        view.layer.frame           = frame
    }
}

extension PresentAnimationController: UIViewControllerAnimatedTransitioning {

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return transitionDuration
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext

        if let
            presentingVC = presentintViewController,
            presentedVC = presentedViewController,
            frameForPresentingVC = frameForPresentingView
        {
            let coverView = coverViewWithFrame(frameForPresentingVC)

            configurePresentingView(presentingVC.view, withFrame: frameForPresentingVC)

            transitionContext.containerView().layer.sublayerTransform.m34 = -1 / 1_000
            transitionContext.containerView().addSubview(presentedVC.view)
            transitionContext.containerView().addSubview(presentingVC.view)
            transitionContext.containerView().addSubview(coverView)

            UIView.animateWithDuration(transitionDuration, delay: 0, options: .CurveLinear, animations: {
                self.animationForPresentingView(presentingVC.view, coverView: coverView)
            }, completion: { _ in
                self.animationCompletionForPresentingView(presentingVC.view, coverView: coverView, withFrame: frameForPresentingVC)
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            })
        }
    }
}