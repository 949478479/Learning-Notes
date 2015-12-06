//
//  CustomSegue.swift
//  CustomSegue
//
//  Created by 从今以后 on 15/12/6.
//  Copyright © 2015年 从今以后. All rights reserved.
//

import UIKit

class CustomSegue: UIStoryboardSegue {

    private var duration: NSTimeInterval {
        return 0.4
    }
    private var completion: (Bool -> Void)? {
        return { _ in
            // 完成实际的 present 过程
            let sourceViewController = self.sourceViewController
            sourceViewController.presentViewController(self.destinationViewController,
                animated: false, completion: nil)
            sourceViewController.view.transform = CGAffineTransformIdentity
        }
    }

    override func perform() {

        let sourceView = sourceViewController.view
        let destinationView = destinationViewController.view

        // 将目标控制器的视图添加到窗口上，从而实现一些动画效果
        let window = UIApplication.sharedApplication().keyWindow!
        window.addSubview(destinationView)

        let minScaleTransform = CGAffineTransformMakeScale(0.001, 0.001)
        destinationView.transform = minScaleTransform
        UIView.animateWithDuration(duration, animations: {
            sourceView.transform = minScaleTransform
        }, completion: { _ in
            UIView.animateWithDuration(self.duration, animations: {
                destinationView.transform = CGAffineTransformIdentity
            }, completion: self.completion)
        })
    }
}

class CustomUnwindSegue: CustomSegue {

    override var completion: (Bool -> Void)? {
        return { _ in
            // 完成实际的 dismiss 过程
            let sourceViewController = self.sourceViewController
            sourceViewController.dismissViewControllerAnimated(false, completion: nil)
        }
    }
}
