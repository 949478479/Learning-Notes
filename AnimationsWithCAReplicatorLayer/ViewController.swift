//
//  ViewController.swift
//  AnimationsWithCAReplicatorLayer
//
//  Created by 从今以后 on 15/8/24.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        animation1()

//        animation2()

        animation3()
    }

    // MARK: - 三个红色小条

    private func animation1() {

        // 创建并添加 CAReplicatorLayer 图层.
        let replicator         = CAReplicatorLayer()
        replicator.position    = view.center
        replicator.bounds.size = CGSize(width: 60, height: 60)
//        replicator.backgroundColor = UIColor.lightGrayColor().CGColor
        view.layer.addSublayer(replicator)

        // 创建并添加红色条条图层.
        let bar             = CALayer()
        bar.cornerRadius    = 2
        bar.bounds.size     = CGSize(width: 8, height: 40)
        bar.position        = CGPoint(x: 10, y: 75)
        bar.backgroundColor = UIColor.redColor().CGColor
        replicator.addSublayer(bar)

        // 为红色条条图层添加上下移动的动画.
        let move          = CABasicAnimation(keyPath: "position.y")
        move.toValue      = bar.position.y - 35
        move.duration     = 0.5
        move.autoreverses = true
        move.repeatCount  = Float.infinity
        bar.addAnimation(move, forKey: nil)

        // 设置副本间的偏移量.
        replicator.instanceCount = 3
        replicator.instanceTransform = CATransform3DMakeTranslation(20, 0, 0)
        replicator.instanceDelay = 0.33

        // 遮罩 CAReplicatorLayer 图层 bounds 范围之外的部分.
        replicator.masksToBounds = true
    }

    // MARK: - 活动指示器

    private func animation2() {

        // 创建并添加 CAReplicatorLayer 图层.
        let replicator             = CAReplicatorLayer()
        replicator.cornerRadius    = 10
        replicator.position        = view.center
        replicator.bounds.size     = CGSize(width: 200, height: 200)
        replicator.backgroundColor = UIColor(white: 0, alpha: 0.75).CGColor
        view.layer.addSublayer(replicator)

        // 创建并添加白色小方块图层.
        let dot             = CALayer()
        dot.borderWidth     = 1
        dot.cornerRadius    = 2
        dot.borderColor     = UIColor.whiteColor().CGColor
        dot.position        = CGPoint(x: 100, y: 40)
        dot.bounds.size     = CGSize(width: 14, height: 14)
        dot.backgroundColor = UIColor(white: 0.8, alpha: 1).CGColor
        dot.transform       = CATransform3DMakeScale(0.01, 0.01, 0.01)
        replicator.addSublayer(dot)

        // 为小方块添加缩小动画.
        let duration: NSTimeInterval = 1.5
        let shrink         = CABasicAnimation(keyPath: "transform.scale")
        shrink.fromValue   = 1
        shrink.toValue     = 0.1
        shrink.duration    = duration
        shrink.repeatCount = Float.infinity
        dot.addAnimation(shrink, forKey: nil)

        // 设置副本间偏移量.
        let nrDots = 15
        replicator.instanceCount     = nrDots
        replicator.instanceDelay     = duration / Double(nrDots)
        replicator.instanceTransform = CATransform3DMakeRotation(
            CGFloat(2 * M_PI) / CGFloat(nrDots), 0, 0, 1)
    }

    // MARK: - 跟随动画

    private func animation3() {

        // 生成 RayWenderlich 网站 logo 的图案路径.
        let rw = { () -> CGPath in

            var bezierPath = UIBezierPath()

            bezierPath.moveToPoint(CGPointMake(31.5, 71.5))
            bezierPath.addLineToPoint(CGPointMake(31.5, 23.5))
            bezierPath.addCurveToPoint(CGPointMake(58.5, 38.5),
                controlPoint1: CGPointMake(31.5, 23.5), controlPoint2: CGPointMake(62.46, 18.69))
            bezierPath.addCurveToPoint(CGPointMake(53.5, 45.5),
                controlPoint1: CGPointMake(57.5, 43.5), controlPoint2: CGPointMake(53.5, 45.5))
            bezierPath.addLineToPoint(CGPointMake(43.5, 48.5))
            bezierPath.addLineToPoint(CGPointMake(53.5, 66.5))
            bezierPath.addLineToPoint(CGPointMake(62.5, 51.5))
            bezierPath.addLineToPoint(CGPointMake(70.5, 66.5))
            bezierPath.addLineToPoint(CGPointMake(86.5, 23.5))
            bezierPath.addLineToPoint(CGPointMake(86.5, 78.5))
            bezierPath.addLineToPoint(CGPointMake(31.5, 78.5))
            bezierPath.addLineToPoint(CGPointMake(31.5, 71.5))

            bezierPath.closePath()

            bezierPath.applyTransform(CGAffineTransformMakeScale(3, 3)) // 放大点好看.

            return bezierPath.CGPath
        }

        // 创建并添加 CAReplicatorLayer 图层.
        let replicator = CAReplicatorLayer()
        replicator.frame = view.bounds
        replicator.backgroundColor = UIColor(white: 0, alpha: 0.75).CGColor
        view.layer.addSublayer(replicator)

        // 创建并添加白色小圆图层.
        let dot             = CALayer()
        dot.cornerRadius    = 5
        dot.borderWidth     = 1
        dot.borderColor     = UIColor.whiteColor().CGColor
        dot.bounds.size     = CGSize(width: 10, height: 10)
        dot.backgroundColor = UIColor(white: 0.8, alpha: 1).CGColor
        replicator.addSublayer(dot)

        // 为小圆添加帧动画.
        let move         = CAKeyframeAnimation(keyPath: "position")
        move.path        = rw()
        move.duration    = 4
        move.repeatCount = Float.infinity
        dot.addAnimation(move, forKey: nil)

        // 设置副本间偏移量.
        replicator.instanceCount       = 20
        replicator.instanceDelay       = 0.1
        replicator.instanceGreenOffset = -0.03
        replicator.instanceColor       = UIColor.greenColor().CGColor
    }
}