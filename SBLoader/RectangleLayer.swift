//
//  RectangleLayer.swift
//  SBLoader
//
//  Created by Satraj Bambra on 2015-03-20.
//  Copyright (c) 2015 Satraj Bambra. All rights reserved.
//

import UIKit

class RectangleLayer: CAShapeLayer {

    // MARK: - 属性

    var sideLength: CGFloat = 0 { didSet { path = rectanglePathFull } }

    private var rectanglePathFull: CGPath {
        let length = sideLength / 2 + lineWidth / 2

        let rectanglePath = UIBezierPath()
        rectanglePath.moveToPoint(CGPoint(x: -length, y: -length))
        rectanglePath.addLineToPoint(CGPoint(x: length, y: -length))
        rectanglePath.addLineToPoint(CGPoint(x: length, y: length))
        rectanglePath.addLineToPoint(CGPoint(x: -length, y: length))
        rectanglePath.closePath()

        return rectanglePath.CGPath
    }

    // MARK: - 初始化

    override init() {
        super.init()
        fillColor = nil
        lineWidth = 5
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(layer: AnyObject!) {
        super.init(layer: layer)
        // 动画到 strokeColor = color.CGColor 这步,会触发 fatalError 提示未实现此方法,还没弄明白...
    }

    // MARK: - 公共方法

    func animateStrokeWithColor(color: UIColor,
        duration: NSTimeInterval, completion: CompletionBlock?) {

        strokeColor = color.CGColor

        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.fromValue = 0
        strokeAnimation.toValue   = 1
        strokeAnimation.duration  = duration
        strokeAnimation.addDelegate(self, withCompletion: completion)

        addAnimation(strokeAnimation, forKey: nil)
    }
}