//
//  PresentSegue.swift
//  SegueTransition
//
//  Created by 从今以后 on 15/7/20.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

import UIKit

class PresentSegue: UIStoryboardSegue {

    override func perform() {

        let presentingVC = sourceViewController as! UIViewController
        let presentedVC  = destinationViewController as! UIViewController

        let finalFrame = presentingVC.view.frame
        presentedVC.view.frame = CGRectOffset(finalFrame, 0, finalFrame.height)
        presentingVC.view.superview!.addSubview(presentedVC.view)

        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: nil, animations: {
            presentedVC.view.frame = finalFrame
        }, completion: { _ in
            presentingVC.presentViewController(presentedVC, animated: false, completion: nil)
        })
    }
}