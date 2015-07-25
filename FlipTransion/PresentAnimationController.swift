//
//  PresentAnimationController.swift
//  FlipTransion
//
//  Created by 从今以后 on 15/7/19.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

import UIKit

class PresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    let transitionDuration: NSTimeInterval = 1

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return transitionDuration
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

        let containerView = transitionContext.containerView()

        let presentedVC   = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let presentingVC  = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!

        let initalFrame   = transitionContext.initialFrameForViewController(presentingVC)

        let coverView     = UIView(frame: initalFrame) // 添加遮罩,实现明暗变化.

        coverView.alpha               = 0
        coverView.backgroundColor     = UIColor.blackColor()
        coverView.layer.anchorPoint.x = 0
        coverView.layer.position.x    = initalFrame.minX

        // 改变锚点,使之以左边界为轴旋转.调整 position 使视图 frame 不变.开启光栅化,不然有毛边.
        presentingVC.view.layer.anchorPoint.x      = 0
        presentingVC.view.layer.position.x         = initalFrame.minX
        presentingVC.view.layer.shouldRasterize    = true
        presentingVC.view.layer.rasterizationScale = UIScreen.mainScreen().scale

        containerView.layer.sublayerTransform.m34 = -1 / 1_000 // 改变 m34, 获得立体透视效果.
        containerView.insertSubview(presentedVC.view, belowSubview: presentingVC.view)
        containerView.addSubview(coverView)

        // 将视图以左边界为轴向屏幕外旋转90°,动画结束后恢复锚点,移除遮罩.注意恢复仿射变换,否则frame受影响.
        UIView.animateWithDuration(transitionDuration, delay: 0, options: .CurveLinear, animations: {

            coverView.alpha                   = 0.8
            coverView.layer.transform         = CATransform3DMakeRotation(CGFloat(-M_PI_2), 0, 1, 0)

            presentingVC.view.layer.transform = CATransform3DMakeRotation(CGFloat(-M_PI_2), 0, 1, 0)

        }, completion: { _ in

            coverView.removeFromSuperview()

            presentingVC.view.layer.shouldRasterize = false
            presentingVC.view.layer.anchorPoint.x   = 0.5
            presentingVC.view.layer.position.x      = initalFrame.midX
            presentingVC.view.layer.transform       = CATransform3DIdentity

            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }
}