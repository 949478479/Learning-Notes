//
//  PresentAnimationController.swift
//  FlipTransion
//
//  Created by 从今以后 on 15/7/19.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

import UIKit

private let kTransitionDuration: NSTimeInterval = 1

class PresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return kTransitionDuration
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

        let presentedVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! PresentedViewController
        let presentingVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! PresentingViewController

        let initalFrame = transitionContext.initialFrameForViewController(presentingVC)

        // 添加遮罩,实现明暗变化.
        let coverView: UIView = {
            let cover                 = UIView(frame: initalFrame)
            cover.alpha               = 0
            cover.backgroundColor     = UIColor.blackColor()
            cover.layer.anchorPoint.x = 0
            cover.layer.position.x    = initalFrame.minX
            return cover
        }()

        // 改变锚点,使之以左边界为轴旋转.调整 position 使视图 frame 不变.开启光栅化,不然有毛边.
        presentingVC.view.layer.anchorPoint.x      = 0
        presentingVC.view.layer.position.x         = initalFrame.minX
        presentingVC.view.layer.shouldRasterize    = true
        presentingVC.view.layer.rasterizationScale = UIScreen.mainScreen().scale

        let containerView = transitionContext.containerView()
        containerView.layer.sublayerTransform.m34 = -1 / 1_000 // 改变 m34, 获得立体透视效果.
        containerView.insertSubview(presentedVC.view, belowSubview: presentingVC.view)
        containerView.addSubview(coverView)

        // 将视图以左边界为轴向屏幕外旋转90°,动画结束后恢复锚点,移除遮罩.注意恢复仿射变换,否则frame受影响.
        UIView.animateWithDuration(kTransitionDuration, delay: 0, options: .CurveLinear, animations: {
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