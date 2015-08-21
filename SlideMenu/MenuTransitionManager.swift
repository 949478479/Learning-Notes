//
//  MenuTransitionManager.swift
//  SlideMenu
//
//  Created by 从今以后 on 15/8/21.
//  Copyright (c) 2015年 AppCoda. All rights reserved.
//

import UIKit

@objc protocol MenuTransitionManagerDelegate {
    optional func dismiss()
}

class MenuTransitionManager: NSObject {

    var duration = 0.3
    weak var delegate: MenuTransitionManagerDelegate?

    /// 源控制器视图的截图.
    private weak var snapshot: UIView! {
        didSet {
            // 若指定了代理,则为截图添加轻击手势,从而点击截图也能 dismiss.
            if let delegate = delegate {
                snapshot?.addGestureRecognizer(
                    UITapGestureRecognizer(target: delegate, action: "dismiss"))
            }
        }
    }

    /// 标记是弹出还是收回.
    private var isPresenting = false
}

extension MenuTransitionManager: UIViewControllerTransitioningDelegate {

    func animationControllerForPresentedController(presented: UIViewController,
        presentingController presenting: UIViewController,
        sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        isPresenting = true

        return self
    }

    func animationControllerForDismissedController(dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {

        isPresenting = false

        return self
    }
}

extension MenuTransitionManager: UIViewControllerAnimatedTransitioning {

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning)
        -> NSTimeInterval {
        return duration
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

        let toView    = transitionContext.viewForKey(UITransitionContextToViewKey)!
        let fromView  = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        let container = transitionContext.containerView()

        let moveUp    = CGAffineTransformMakeTranslation(0, -50)
        let moveDown  = CGAffineTransformMakeTranslation(0, container.bounds.maxY - 150)

        if isPresenting {

            // 弹出时,将 Presented View 预先小幅上移,为动画下移做准备.
            toView.transform = moveUp
            // 将 Presenting View 截图,用于做动画.
            let snapshot  = fromView.snapshotViewAfterScreenUpdates(true)
            self.snapshot = snapshot

            // 将 Presented View 添加到 Presenting View 上层(而 Presenting View 会在过渡结束后被系统移除).
            container.addSubview(toView)
            // 将 Presenting View 的截图添加到 Presented View 上层.
            container.addSubview(snapshot)
        }

        UIView.animateWithDuration(duration, animations: {

            if self.isPresenting {

                // 将 Presenting View 的截图下移至屏幕下方,留 150 点高度可见.
                self.snapshot.transform = moveDown
                // 将 Presented View 由上移状态恢复原位,造成小幅度下移效果.
                toView.transform = CGAffineTransformIdentity

            } else {

                // 将 Presented View 小幅度上移.
                fromView.transform = moveUp
                // 将 Presenting View 的截图恢复原位,即由屏幕下方恢复至全屏.
                self.snapshot.transform = CGAffineTransformIdentity
            }

        }, completion: { _ in

            transitionContext.completeTransition(true)
        })
    }
}