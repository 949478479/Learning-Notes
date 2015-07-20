//
//  UnwindingSegue.swift
//  SegueTransition
//
//  Created by 从今以后 on 15/7/20.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

import UIKit

class UnwindingSegue: UIStoryboardSegue {

    override func perform() {

        let presentingVC = destinationViewController as! UIViewController
        let presentedVC  = sourceViewController as! UIViewController

        presentedVC.view.window?.addSubview(presentingVC.view)
        presentedVC.view.window?.addSubview(presentedVC.view)

        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: nil, animations: {
            presentedVC.view.frame.origin.y += presentedVC.view.frame.height
        }, completion: { _ in
            presentingVC.dismissViewControllerAnimated(true, completion: nil)
        })
    }
}