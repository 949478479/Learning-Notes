//
//  PushAnimationController.swift
//  MagicMove
//
//  Created by 从今以后 on 15/7/18.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

import UIKit

class PushAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    let transitionDuration: NSTimeInterval = 0.4

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return transitionDuration
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! MasterViewController
        let toVC   = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! DetailViewController

        // 隐藏选中 cell 的 imageView, 用截图做动画.
        fromVC.selectedCell.imageView.hidden = true

        // 淡入目标控制器视图,隐藏真正的 imageView 直到截图动画结束后到达 imageView 的位置.
        toVC.view.alpha       = 0
        toVC.imageView.hidden = true

        // 将选中 cell 截图,需要将坐标系从其父视图(contentView)转换到截图的父视图(containerView).
        let snapshotView   = fromVC.selectedCell.imageView.snapshotViewAfterScreenUpdates(false)
        snapshotView.frame = transitionContext.containerView().convertRect(
            fromVC.selectedCell.imageView.frame, fromView: fromVC.selectedCell.imageView.superview)

        transitionContext.containerView().addSubview(toVC.view)
        transitionContext.containerView().addSubview(snapshotView)

        // 动画前需要更新到最终 frame 以确定 imageView 的最终实际位置,否则还是 IB 中的 frame.
        toVC.view.layoutIfNeeded()

        // 将目标控制器视图淡入,并将截图动画移动到目标控制器中 imageView 的位置.
        // 结束后显示目标控制器的 imageView, 并将截图移除.
        UIView.animateWithDuration(transitionDuration, animations: {

            toVC.view.alpha = 1
            snapshotView.frame = toVC.imageView.frame

        }, completion: { _ in
        
            toVC.imageView.hidden = false
            snapshotView.removeFromSuperview()

            transitionContext.completeTransition(true)
        })
    }
}