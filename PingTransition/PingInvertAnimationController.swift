//
//  PingInvertAnimationController.swift
//  PingTransition
//
//  Created by 从今以后 on 15/7/24.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

import UIKit

class PingInvertAnimationController: PingAnimationController {

    override var presentingViewController: UIViewController {
        return transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
    }

    override var presentedViewController: UIViewController {
        return transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
    }

    override var fromViewController: UIViewController {
        return presentedViewController
    }

    override func animationValuesForFromViewController(fromVC: UIViewController) -> (CGPathRef, CGPathRef) {
        let buttonFrame = (fromVC as! PresentedViewController).button.frame
        let pathRadius  = maskLayerPathRadiusForButtonFrame(buttonFrame)
        return (
            CGPathCreateWithEllipseInRect(CGRectInset(buttonFrame, -pathRadius, -pathRadius), nil),
            CGPathCreateWithEllipseInRect(buttonFrame, nil)
        )
    }
}