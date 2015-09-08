//
//  OvalLayer.swift
//  SBLoader
//
//  Created by Satraj Bambra on 2015-03-19.
//  Copyright (c) 2015 Satraj Bambra. All rights reserved.
//

import UIKit

class OvalLayer: CAShapeLayer {

    // MARK: - 公共属性

    var diameter: CGFloat = 0

    // MARK: - 初始化

    override init() {
        super.init()
        fillColor = Colors.green.CGColor
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 私有

private extension OvalLayer {

    var ovalPathSmall: CGPath {
        return UIBezierPath(ovalInRect: CGRectZero).CGPath
    }

    var ovalPathLarge: CGPath {
        return UIBezierPath(ovalInRect: CGRect(x: -diameter / 2, y: -diameter / 2,
            width: diameter, height: diameter)).CGPath
    }

    var ovalPathSquishVertical: CGPath {
        return UIBezierPath(ovalInRect: CGRect(x: -diameter / 2, y: -(diameter / 2 - 5),
            width: diameter, height: diameter - 10)).CGPath
    }

    var ovalPathSquishHorizontal: CGPath {
        return UIBezierPath(ovalInRect: CGRect(x: -(diameter / 2 - 5), y: -(diameter / 2 - 5),
            width: diameter - 10, height: diameter - 10)).CGPath
    }
}

// MARK: - 公共方法

extension OvalLayer {

    // MARK: - 圆形扩大动画

    func expandAnimationWithDuration(duration: NSTimeInterval, completion: CompletionBlock?) {

        let expandAnimation = CABasicAnimation(keyPath: "path")
        expandAnimation.fromValue = ovalPathSmall
        expandAnimation.toValue   = ovalPathLarge
        expandAnimation.duration  = duration
        expandAnimation.addDelegate(self, withCompletion: completion)

        addAnimation(expandAnimation, forKey: nil)
        path = expandAnimation.toValue as! CGPath
    }

    // MARK: - 挤压形变动画

    func wobbleAnimationWithDuration(duration: NSTimeInterval, completion: CompletionBlock?) {

        let largePath            = ovalPathLarge
        let squishVerticalPath   = ovalPathSquishVertical
        let squishHorizontalPath = ovalPathSquishHorizontal

        let wobbleAnimation = CAKeyframeAnimation(keyPath: "path")
        wobbleAnimation.duration = duration
        wobbleAnimation.values = [
            largePath,
            squishVerticalPath,
            squishHorizontalPath,
            squishVerticalPath,
            largePath
        ]
        wobbleAnimation.addDelegate(self, withCompletion: completion)

        addAnimation(wobbleAnimation, forKey: nil)
    }

    // MARK: - 缩小至消失动画

    func contractAnimationWithDuration(duration: NSTimeInterval, completion: CompletionBlock?) {

        let contractAnimation = CABasicAnimation(keyPath: "path")
        contractAnimation.fromValue = path
        contractAnimation.toValue   = ovalPathSmall
        contractAnimation.duration  = duration
        contractAnimation.addDelegate(self, withCompletion: completion)

        addAnimation(contractAnimation, forKey: nil)
        path = contractAnimation.toValue as! CGPath
    }
}