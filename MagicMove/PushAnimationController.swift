//
//  PushAnimationController.swift
//  MagicMove
//
//  Created by 从今以后 on 15/7/18.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

import UIKit

private let kTransitionDuration: NSTimeInterval = 0.4

class PushAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return kTransitionDuration
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

        let containerView = transitionContext.containerView()

        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! MasterViewController

        // 隐藏选中 cell 的 imageView, 用截图做动画.
        let fromImageView: UIImageView = {
            fromVC.selectedCell.imageView.hidden = true
            return fromVC.selectedCell.imageView
        }()

        // 将选中 cell 截图,需要将坐标系从其父视图(contentView)转换到截图的父视图(containerView).
        let snapshot: UIView = {
            let view = fromImageView.snapshotViewAfterScreenUpdates(false)
            view.frame = containerView.convertRect(fromImageView.frame, fromView: fromImageView.superview)
            return view
        }()

        // 将目标控制器视图的 alpha 设为 0 实现淡入,隐藏真正的 imageView 直到截图动画结束后到达 imageView 的位置.
        let toVC: DetailViewController = {
            let vc = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! DetailViewController
            vc.view.alpha = 0
            vc.imageView.hidden = true
            return vc
        }()

        let toImageView = toVC.imageView

        // 确保截图在目标控制器视图的上层.
        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot)

        // 动画前需要更新到最终 frame 以确定 imageView 的最终实际位置,否则还是 IB 中的 frame.
        toVC.view.layoutIfNeeded()

        // 将目标控制器淡入,并将截图动画移动到目标控制器中 imageView 的位置.
        // 结束后显示目标控制器的 imageView, 并将截图移除.
        UIView.animateWithDuration(kTransitionDuration, animations: {

            toVC.view.alpha = 1
            snapshot.frame = toImageView.frame

        }, completion: { _ in
        
            toImageView.hidden = false
            snapshot.removeFromSuperview()

            transitionContext.completeTransition(true)
        })
    }
}