//
//  PresentingViewController.swift
//  PingTransition
//
//  Created by 从今以后 on 15/7/24.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

import UIKit

class PresentingViewController: UIViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet var button: UIButton!

    @IBAction func dismissViewController(segue: UIStoryboardSegue) { }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        (segue.destinationViewController as! UIViewController).transitioningDelegate = self
    }
}

extension PresentingViewController: UIViewControllerTransitioningDelegate {

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PingAnimationController()
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PingInvertAnimationController()
    }
}