//
//  PresentAnimationController.swift
//  FlipTransion
//
//  Created by 从今以后 on 15/7/19.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

import UIKit

class ShadowView: UIView {
    override class func layerClass() -> AnyClass {
        return CAGradientLayer.self
    }

    override var layer: CAGradientLayer {
        return super.layer as! CAGradientLayer
    }
}

class PresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    var transitionDuration: NSTimeInterval = 1

    private(set) var transitionContext: UIViewControllerContextTransitioning?

    var presentintViewController: UIViewController? {
        return transitionContext?.viewControllerForKey(UITransitionContextFromViewControllerKey)
    }

    var presentedViewController: UIViewController? {
        return transitionContext?.viewControllerForKey(UITransitionContextToViewControllerKey)
    }

    var frameForPresentingView: CGRect? {
        if let presentingVC = presentintViewController {
            return transitionContext?.initialFrameForViewController(presentingVC)
        }
        return nil
    }

    var frameForPresentedView: CGRect? {
        if let presentedVC = presentedViewController {
            return transitionContext?.finalFrameForViewController(presentedVC)
        }
        return nil
    }

    // MARK: - 创建阴影

    func shadowViewWithFrame(frame: CGRect) -> ShadowView {
        let shadowView                 = ShadowView(frame: frame)
        shadowView.layer.startPoint    = CGPoint(x: 0, y: 0.5)
        shadowView.layer.endPoint      = CGPoint(x: 1, y: 0.5)
        shadowView.layer.colors        = [UIColor.blackColor().CGColor, UIColor.clearColor().CGColor]
        shadowView.layer.opacity       = 0
        shadowView.layer.anchorPoint.x = 0
        shadowView.layer.frame         = frame
        return shadowView
    }

    // MARK: - 动画预备

    func configurePresentingView(view: UIView, shadowView: ShadowView, withFrame frame: CGRect) {
        view.layer.shouldRasterize    = true
        view.layer.rasterizationScale = UIScreen.mainScreen().scale
        view.layer.anchorPoint.x      = 0
        view.layer.frame              = frame
    }

    func configurePresentedView(view: UIView, shadowView: ShadowView, withFrame frame: CGRect) {
        shadowView.layer.opacity = 1
    }

    // MARK: - 动画过程

    func animationForPresentingView(view: UIView, shadowView: ShadowView) {
        view.layer.transform       = CATransform3DMakeRotation(CGFloat(-M_PI_2), 0, 1, 0)
        shadowView.layer.transform = CATransform3DMakeRotation(CGFloat(-M_PI_2), 0, 1, 0)
        shadowView.layer.opacity   = 1
    }

    func animationForPresentedView(view: UIView, shadowView: ShadowView) {
        shadowView.layer.opacity = 0
    }

    // MARK: - 动画完成

    func animationCompletionForPresentingView(view: UIView, shadowView: ShadowView, withFrame frame: CGRect) {
        shadowView.removeFromSuperview()

        view.layer.shouldRasterize = false
        view.layer.anchorPoint.x   = 0.5
        view.layer.frame           = frame
    }

    func animationCompletionForPresentedView(view: UIView, shadowView: ShadowView, withFrame frame: CGRect) {
        shadowView.removeFromSuperview()
    }
}

extension PresentAnimationController: UIViewControllerAnimatedTransitioning {

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return transitionDuration
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext

        if let
            presentingVC         = presentintViewController,
            presentedVC          = presentedViewController,
            frameForPresentingVC = frameForPresentingView,
            frameForPresentedVC  = frameForPresentedView
        {
            let shadowViewForPresentingVC = shadowViewWithFrame(frameForPresentingVC)
            let shadowViewForPresentedVC  = shadowViewWithFrame(frameForPresentedVC)

            configurePresentingView(presentingVC.view, shadowView: shadowViewForPresentingVC, withFrame: frameForPresentingVC)
            configurePresentedView(presentedVC.view, shadowView: shadowViewForPresentedVC, withFrame: frameForPresentedVC)

            transitionContext.containerView().layer.sublayerTransform.m34 = -1 / 1_000

            transitionContext.containerView().addSubview(presentedVC.view)
            transitionContext.containerView().addSubview(shadowViewForPresentedVC)

            transitionContext.containerView().addSubview(presentingVC.view)
            transitionContext.containerView().addSubview(shadowViewForPresentingVC)

            UIView.animateWithDuration(transitionDuration, delay: 0, options: .CurveLinear, animations: {
                self.animationForPresentingView(presentingVC.view, shadowView: shadowViewForPresentingVC)
                self.animationForPresentedView(presentedVC.view, shadowView: shadowViewForPresentedVC)
            }, completion: { _ in
                self.animationCompletionForPresentingView(presentingVC.view, shadowView: shadowViewForPresentingVC, withFrame: frameForPresentingVC)
                self.animationCompletionForPresentedView(presentedVC.view, shadowView: shadowViewForPresentedVC, withFrame: frameForPresentedVC)

                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            })
        }
    }
}