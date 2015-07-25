//
//  DismissAnimationController.swift
//  FlipTransion
//
//  Created by 从今以后 on 15/7/19.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

import UIKit

class DismissAnimationController: PresentAnimationController {

    override var presentintViewController: UIViewController? {
        return transitionContext?.viewControllerForKey(UITransitionContextToViewControllerKey)
    }

    override var presentedViewController: UIViewController? {
        return transitionContext?.viewControllerForKey(UITransitionContextFromViewControllerKey)
    }

    override var frameForPresentingView: CGRect? {
        if let presentingVC = presentintViewController {
            return transitionContext?.finalFrameForViewController(presentingVC)
        }
        return nil
    }

    override var frameForPresentedView: CGRect? {
        if let presentedVC = presentedViewController {
            return transitionContext?.initialFrameForViewController(presentedVC)
        }
        return nil
    }

    // MARK: - 动画预备

    override func configurePresentingView(view: UIView, shadowView: ShadowView, withFrame frame: CGRect) {
        super.configurePresentingView(view, shadowView: shadowView, withFrame: frame)
        shadowView.layer.transform = CATransform3DMakeRotation(CGFloat(-M_PI_2), 0, 1, 0)
        shadowView.layer.opacity   = 1
    }

    override func configurePresentedView(view: UIView, shadowView: ShadowView, withFrame frame: CGRect) {
        shadowView.layer.opacity = 0
    }

    // MARK: - 动画过程

    override func animationForPresentingView(view: UIView, shadowView: ShadowView) {
        view.layer.transform       = CATransform3DIdentity
        shadowView.layer.transform = CATransform3DIdentity
        shadowView.layer.opacity   = 0
    }

    override func animationForPresentedView(view: UIView, shadowView: ShadowView) {
        shadowView.layer.opacity = 1
    }
}