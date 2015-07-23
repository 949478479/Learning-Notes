//
//  PopAnimationController.swift
//  MagicMove
//
//  Created by 从今以后 on 15/7/18.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

import UIKit

private let kTransitionDuration: NSTimeInterval = 0.4

class PopAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return kTransitionDuration
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

        let containerView = transitionContext.containerView()

        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! MasterViewController

        let toImageView = toVC.selectedCell.imageView

        // 隐藏源控制器的 imageView, 用截图做动画.
        let fromVC: DetailViewController = {
            let vc = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! DetailViewController
            vc.imageView.hidden = true
            return vc
        }()

        let fromImageView = fromVC.imageView

        // 将源控制器的 imageView 截图,用来做动画.
        let snapshot: UIView = {
            let view = fromImageView.snapshotViewAfterScreenUpdates(false)
            view.frame = fromImageView.frame
            return view
        }()

        // 由于是 pop 过程,需将目标控制器视图添加到源控制视图的下层.
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        containerView.addSubview(snapshot)

        // 将源控制器淡出,并将截图以动画效果移动到目标控制器选中 cell 的 imageView 的位置.
        // 结束后显示真正的 imageView, 并将截图移除.这里需要将源控制器的 imageView 恢复显示,因为有可能中途取消 pop.
        UIView.animateWithDuration(kTransitionDuration, animations: {

            fromVC.view.alpha = 0
            snapshot.frame = containerView.convertRect(toImageView.frame, fromView: toImageView.superview)

        }, completion: { _ in

            snapshot.removeFromSuperview()
            fromImageView.hidden = false
            toImageView.hidden = false

            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }
}