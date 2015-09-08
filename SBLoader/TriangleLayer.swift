//
//  TriangleLayer.swift
//  SBLoader
//
//  Created by Satraj Bambra on 2015-03-19.
//  Copyright (c) 2015 Satraj Bambra. All rights reserved.
//

import UIKit

class TriangleLayer: CAShapeLayer {

    // MARK: - 属性

    var radius: CGFloat = 0 { didSet { radius -= 20 /* 减去这个数基本上看不见小三角形了. */ } }
    var sideLength: CGFloat = 0

    // MARK: - 初始化
    
    override init() {
        super.init()
        fillColor   = Colors.green.CGColor
        strokeColor = fillColor
        lineWidth   = 5
        lineCap     = kCALineCapRound
        lineJoin    = kCALineJoinRound
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 公共方法

extension TriangleLayer {

    func triangleAnimationWithDuration(duration: NSTimeInterval, completion: CompletionBlock?) {

        let animation = CAKeyframeAnimation(keyPath: "path")
        animation.duration = duration
        animation.values = [
            trianglePathSmall,
            trianglePathLeftExtension,
            trianglePathRightExtension,
            trianglePathTopExtension
        ]
        animation.addDelegate(self, withCompletion: completion)

        addAnimation(animation, forKey: nil)
        path = trianglePathTopExtension
    }
}

// MARK: - 私有

private extension TriangleLayer {

    /// 等边三角形角度.
    var α: CGFloat {
        return CGFloat(M_PI / 3)
    }

    /// 角度的一半.
    var β: CGFloat {
        return α / 2
    }

    var innerTopPoint: CGPoint {
        return CGPoint(x: 0, y: -radius)
    }

    var innerLeftBottomPoint: CGPoint {
        return CGPoint(x: -radius * cos(β), y: radius * sin(β))
    }

    var innerRightBottomPoint: CGPoint {
        return CGPoint(x: radius * cos(β), y: radius * sin(β))
    }

    var outerTopPoint: CGPoint {
        return CGPoint(x: 0, y: -(sideLength / 2) / cos(β))
    }

    var outerLeftBottomPoint: CGPoint {
        return CGPoint(x: -sideLength / 2, y: (sideLength / 2) * tan(β))
    }

    var outerRightBottomPoint: CGPoint {
        return CGPoint(x: sideLength / 2, y: (sideLength / 2) * tan(β))
    }

    var trianglePathSmall: CGPath {
        let trianglePath = UIBezierPath()
        trianglePath.moveToPoint(innerTopPoint)
        trianglePath.addLineToPoint(innerLeftBottomPoint)
        trianglePath.addLineToPoint(innerRightBottomPoint)
        trianglePath.closePath()
        return trianglePath.CGPath
    }

    var trianglePathLeftExtension: CGPath {
        let trianglePath = UIBezierPath()
        trianglePath.moveToPoint(innerTopPoint)
        trianglePath.addLineToPoint(outerLeftBottomPoint)
        trianglePath.addLineToPoint(innerRightBottomPoint)
        trianglePath.closePath()
        return trianglePath.CGPath
    }

    var trianglePathRightExtension: CGPath {
        let trianglePath = UIBezierPath()
        trianglePath.moveToPoint(innerTopPoint)
        trianglePath.addLineToPoint(outerLeftBottomPoint)
        trianglePath.addLineToPoint(outerRightBottomPoint)
        trianglePath.closePath()
        return trianglePath.CGPath
    }

    var trianglePathTopExtension: CGPath {
        let trianglePath = UIBezierPath()
        trianglePath.moveToPoint(outerTopPoint)
        trianglePath.addLineToPoint(outerLeftBottomPoint)
        trianglePath.addLineToPoint(outerRightBottomPoint)
        trianglePath.closePath()
        return trianglePath.CGPath
    }
}