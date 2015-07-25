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

    override func coverViewWithFrame(frame: CGRect) -> UIView {
        let coverView = super.coverViewWithFrame(frame)
        coverView.alpha = 0.8
        coverView.layer.transform = CATransform3DMakeRotation(CGFloat(-M_PI_2), 0, 1, 0)
        return coverView
    }

    override func animationForPresentingView(view: UIView, coverView: UIView) {
        coverView.alpha           = 0
        coverView.layer.transform = CATransform3DIdentity
        view.layer.transform      = CATransform3DIdentity
    }
}