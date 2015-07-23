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
    private var percentDriven: UIPercentDrivenInteractiveTransition!
    
    override init() {
        super.init()
        UIApplication.sharedApplication().keyWindow!.addGestureRecognizer(
            UIPanGestureRecognizer(target: self, action: "panGestureRecognizerHandle:"))
    }

    func panGestureRecognizerHandle(sender: UIPanGestureRecognizer) {

        let percent: CGFloat
        if sender.enabled {
            let translationX = sender.translationInView(window).x * (transitioningType == .Present ? -1 : 1)
            percent = max(0, min(translationX / window.bounds.width, 1))
        } else {
            percent = 0
        }

        switch sender.state {
        case .Began:
            if transitioningType == .Present && sender.velocityInView(window).x > 0 ||
               transitioningType == .Dismiss && sender.velocityInView(window).x < 0 {
                sender.enabled = false
            } else {
                percentDriven = UIPercentDrivenInteractiveTransition()
                action()
            }
        case .Changed:
            percentDriven.updateInteractiveTransition(percent)
        default:
            if sender.enabled {
                percent > 0.5 ? percentDriven.finishInteractiveTransition() : percentDriven.cancelInteractiveTransition()
                percentDriven = nil
            } else {
                sender.enabled = true
            }
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