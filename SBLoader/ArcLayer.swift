//
//  WaveLayer.swift
//  SBLoader
//
//  Created by Satraj Bambra on 2015-03-20.
//  Copyright (c) 2015 Satraj Bambra. All rights reserved.
//

import UIKit

class WaveLayer: CAShapeLayer {

    // MARK: - 属性

    var waveHeight: CGFloat = 10

    // MARK: - 初始化
    
    override init() {
        super.init()
        fillColor = Colors.blue.CGColor
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 公共方法

extension WaveLayer {

    func waveAnimationWithDuration(duration: NSTimeInterval, completion: CompletionBlock?) {

        let waveAnimation = CAKeyframeAnimation(keyPath: "path")
        waveAnimation.duration = duration
        waveAnimation.values = [
            arcPathPre,
            arcPathStarting,
            arcPathLow,
            arcPathMid,
            arcPathHigh,
            arcPathComplete]
        waveAnimation.addDelegate(self, withCompletion: completion)

        addAnimation(waveAnimation, forKey: nil)
        path = arcPathComplete
    }
}

// MARK: - 私有

private extension WaveLayer {

    var controlPoint1X: CGFloat {
        return bounds.width / 3
    }

    var controlPoint2X: CGFloat {
        return bounds.width * 2 / 3
    }

    var arcPathPre: CGPath {
        let arcPath = UIBezierPath()
        arcPath.moveToPoint(CGPoint(x: 0, y: bounds.height))
        arcPath.addLineToPoint(CGPoint(x: 0, y: bounds.height - 1))
        arcPath.addLineToPoint(CGPoint(x: bounds.width, y: bounds.height - 1))
        arcPath.addLineToPoint(CGPoint(x: bounds.width, y: bounds.height))
        arcPath.closePath()
        return arcPath.CGPath
    }

    var arcPathStarting: CGPath {

        let waterSurfaceY = bounds.height * 0.8

        let arcPath = UIBezierPath()
        arcPath.moveToPoint(CGPoint(x: 0, y: bounds.height))
        arcPath.addLineToPoint(CGPoint(x: 0, y: waterSurfaceY))
        arcPath.addCurveToPoint(CGPoint(x: bounds.width, y: waterSurfaceY),
            controlPoint1: CGPoint(x: controlPoint1X, y: waterSurfaceY - waveHeight),
            controlPoint2: CGPoint(x: controlPoint2X, y: waterSurfaceY + waveHeight))
        arcPath.addLineToPoint(CGPoint(x: bounds.width, y: bounds.height))
        arcPath.closePath()
        return arcPath.CGPath
    }

    var arcPathLow: CGPath {

        let waterSurfaceY = bounds.height * 0.6

        let arcPath = UIBezierPath()
        arcPath.moveToPoint(CGPoint(x: 0, y: bounds.height))
        arcPath.addLineToPoint(CGPoint(x: 0, y: waterSurfaceY))
        arcPath.addCurveToPoint(CGPoint(x: bounds.width, y: waterSurfaceY),
            controlPoint1: CGPoint(x: controlPoint1X, y: waterSurfaceY + waveHeight),
            controlPoint2: CGPoint(x: controlPoint2X, y: waterSurfaceY - waveHeight))
        arcPath.addLineToPoint(CGPoint(x: bounds.width, y: bounds.height))
        arcPath.closePath()
        return arcPath.CGPath
    }

    var arcPathMid: CGPath {

        let waterSurfaceY = bounds.height * 0.4

        let arcPath = UIBezierPath()
        arcPath.moveToPoint(CGPoint(x: 0, y: bounds.height))
        arcPath.addLineToPoint(CGPoint(x: 0, y: waterSurfaceY))
        arcPath.addCurveToPoint(CGPoint(x: bounds.width, y: waterSurfaceY),
            controlPoint1: CGPoint(x: controlPoint1X, y: waterSurfaceY - waveHeight),
            controlPoint2: CGPoint(x: controlPoint2X, y: waterSurfaceY + waveHeight))
        arcPath.addLineToPoint(CGPoint(x: bounds.width, y: bounds.height))
        arcPath.closePath()
        return arcPath.CGPath
    }

    var arcPathHigh: CGPath {

        let waterSurfaceY = bounds.height * 0.2

        let arcPath = UIBezierPath()
        arcPath.moveToPoint(CGPoint(x: 0, y: bounds.height))
        arcPath.addLineToPoint(CGPoint(x: 0, y: waterSurfaceY))
        arcPath.addCurveToPoint(CGPoint(x: bounds.width, y: waterSurfaceY),
            controlPoint1: CGPoint(x: controlPoint1X, y: waterSurfaceY + waveHeight),
            controlPoint2: CGPoint(x: controlPoint2X, y: waterSurfaceY - waveHeight))
        arcPath.addLineToPoint(CGPoint(x: bounds.width, y: bounds.height))
        arcPath.closePath()
        return arcPath.CGPath
    }

    var arcPathComplete: CGPath {
        let arcPath = UIBezierPath()
        arcPath.moveToPoint(CGPoint(x: 0, y: bounds.height))
        arcPath.addLineToPoint(CGPointZero)
        arcPath.addLineToPoint(CGPoint(x: bounds.width, y: 0))
        arcPath.addLineToPoint(CGPoint(x: bounds.width, y: bounds.height))
        arcPath.closePath()
        return arcPath.CGPath
    }
}