//
//  PopAnimationController.swift
//  MagicMove
//
//  Created by 从今以后 on 15/7/18.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

import UIKit

class PopAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    let transitionDuration: NSTimeInterval = 0.4

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return transitionDuration
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! DetailViewController
        let toVC   = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! MasterViewController

        // 隐藏当前控制器的 imageView, 用截图做动画.
        fromVC.imageView.hidden            = true
        toVC.selectedCell.imageView.hidden = true

        // 将当前控制器的 imageView 截图,用来做动画.
        let snapshotView   = fromVC.imageView.snapshotViewAfterScreenUpdates(false)
        snapshotView.frame = fromVC.imageView.frame

        // 由于是 pop 过程,需将根控制器视图添加到当前控制视图的下层.
        transitionContext.containerView().insertSubview(toVC.view, belowSubview: fromVC.view)
        transitionContext.containerView().addSubview(snapshotView)

        // 将当前控制器视图淡出,并将截图以动画效果移动到根控制器选中 cell 的 imageView 的位置.
        // 结束后显示真正的 imageView, 并将截图移除.这里需要将当前控制器的 imageView 恢复显示,因为有可能中途取消 pop.
        UIView.animateWithDuration(transitionDuration, animations: {

            fromVC.view.alpha  = 0
            snapshotView.frame = transitionContext.containerView().convertRect(
                toVC.selectedCell.imageView.frame, fromView: toVC.selectedCell.imageView.superview)

        }, completion: { _ in

            snapshotView.removeFromSuperview()
            fromVC.imageView.hidden            = false
            toVC.selectedCell.imageView.hidden = false

            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }
}