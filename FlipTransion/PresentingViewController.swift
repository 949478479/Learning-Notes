//
//  PresentingViewController.swift
//  FlipTransion
//
//  Created by 从今以后 on 15/7/19.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

import UIKit

class PresentingViewController: UIViewController {

    private lazy var transitioningController = TransitioningController()

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // FIXME: present 时如果中途取消, presented 控制器不会释放,直到下次 present 时才释放.
        // 应该因为某个强引用造成的,尝试取消后 dismiss 一次也没效果,以后再说吧.
        transitioningController.transitioningType = .Present
        transitioningController.action = {
            self.performSegueWithIdentifier("PresentVC", sender: nil)
        }
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        transitioningController.transitioningType = .Dismiss
        transitioningController.action = {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let toVC = segue.destinationViewController as! UIViewController
        toVC.transitioningDelegate = transitioningController
    }

    @IBAction func prepareForDismissWithSegue(segue: UIStoryboardSegue) { }
}