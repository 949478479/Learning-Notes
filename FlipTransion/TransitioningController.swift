//
//  TransitioningController.swift
//  FlipTransion
//
//  Created by 从今以后 on 15/7/19.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

import UIKit

enum TransitioningType {
    case Present
    case Dismiss
}

class TransitioningController: NSObject {

    var transitioningType: TransitioningType!
    var action: (() -> ())!

    private lazy var window  = UIApplication.sharedApplication().keyWindow!
    private var shouldBegin  = true
    private var percent      = CGFloat()
    private var translationX = CGFloat()
    private var percentDriven: UIPercentDrivenInteractiveTransition!
    
    override init() {
        super.init()
        UIApplication.sharedApplication().keyWindow!.addGestureRecognizer(
            UIPanGestureRecognizer(target: self, action: "panGestureRecognizerHandle:"))
    }

    func panGestureRecognizerHandle(sender: UIPanGestureRecognizer) {

        if shouldBegin {
            translationX = sender.translationInView(window).x
            percent = max(0, min(translationX * (transitioningType == .Present ? -1 : 1) / window.bounds.width, 1))
        }

        switch sender.state {
        case .Began:
            if transitioningType == .Present && sender.velocityInView(window).x > 0 ||
               transitioningType == .Dismiss && sender.velocityInView(window).x < 0 {
                shouldBegin = false
            } else {
                percentDriven = UIPercentDrivenInteractiveTransition()
                action()
            }
        case .Changed:
            if shouldBegin {
                percentDriven.updateInteractiveTransition(percent)
            }
        case .Ended, .Cancelled:
            if shouldBegin {
                percent > 0.5 ? percentDriven.finishInteractiveTransition() : percentDriven.cancelInteractiveTransition()
                percentDriven = nil
            } else {
                shouldBegin = true
            }
        default: break
        }
    }
}

extension TransitioningController: UIViewControllerTransitioningDelegate {

    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return percentDriven
    }

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentAnimationController()
    }

    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return percentDriven
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimationController()
    }
}