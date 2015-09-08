//
//  LoaderView.swift
//  SBLoader
//
//  Created by Satraj Bambra on 2015-03-17.
//  Copyright (c) 2015 Satraj Bambra. All rights reserved.
//

import UIKit

class LoaderView: UIView {

    // MARK: - 属性

    private weak var ovalLayer: OvalLayer!
    private weak var triangleLayer: TriangleLayer!
    private weak var redRectangleLayer: RectangleLayer!
    private weak var blueRectangleLayer: RectangleLayer!
    private weak var arcLayer: WaveLayer!

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSublayer()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 父类方法

    override func didMoveToWindow() {
        if window == nil { return }
        layoutSublayers()
        animation()
    }
}

private extension LoaderView {

    func addSublayer() {

        let ovalLayer = OvalLayer()
        self.ovalLayer = ovalLayer
        layer.addSublayer(ovalLayer)

        let triangleLayer = TriangleLayer()
        self.triangleLayer = triangleLayer
        layer.addSublayer(triangleLayer)

        let redRectangleLayer = RectangleLayer()
        self.redRectangleLayer = redRectangleLayer
        layer.addSublayer(redRectangleLayer)

        let blueRectangleLayer = RectangleLayer()
        self.blueRectangleLayer = blueRectangleLayer
        layer.addSublayer(blueRectangleLayer)

        let arcLayer = WaveLayer()
        self.arcLayer = arcLayer
        layer.addSublayer(arcLayer)
    }

    func layoutSublayers() {

        let θ = M_PI / 6 // 等边三角形角度的一半.
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)

        ovalLayer.position = center
        ovalLayer.diameter = bounds.width

        triangleLayer.position   = center
        triangleLayer.radius     = bounds.width / 2
        triangleLayer.sideLength = 2 * (bounds.width / 2 + 10) * CGFloat(cos(θ)) // 尖角长约 10.

        let offsetY = bounds.width / 2 - triangleLayer.sideLength / 2 * CGFloat(tan(θ))

        redRectangleLayer.position    = CGPoint(x: center.x, y: center.y - offsetY)
        redRectangleLayer.sideLength  = bounds.width
        blueRectangleLayer.position   = redRectangleLayer.position
        blueRectangleLayer.sideLength = bounds.width

        arcLayer.frame = CGRectOffset(bounds, 0, -offsetY)
    }

    func animation() {
        ovalLayer.expandAnimationWithDuration(0.4) { _ in
            self.ovalLayer.wobbleAnimationWithDuration(1.2, completion: nil)
            self.triangleLayer.triangleAnimationWithDuration(1.2) { _ in
                self.spinAndTransformAnimationWithDuration(0.4) { _ in
                    self.redRectangleLayer.animateStrokeWithColor(Colors.green, duration: 0.4) { _ in
                        self.blueRectangleLayer.animateStrokeWithColor(Colors.blue, duration: 0.4) { _ in
                            self.arcLayer.waveAnimationWithDuration(0.8) { _ in
                                self.expandViewAnimation()
                            }
                        }
                    }
                }
            }
        }
    }

    func spinAndTransformAnimationWithDuration(duration: NSTimeInterval,
        completion: CompletionBlock?) {

        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.duration = duration
        rotationAnimation.toValue = CGFloat(M_PI * 2)
        layer.addAnimation(rotationAnimation, forKey: nil)

        ovalLayer.contractAnimationWithDuration(duration, completion: completion)
    }

    func expandViewAnimation() {
        backgroundColor = Colors.blue

        let delta = blueRectangleLayer.lineWidth / 2
        frame = CGRectInset(frame, -delta, -delta)

        layer.sublayers = nil

        UIView.animateWithDuration(0.4, animations: {
            self.frame = self.superview!.frame
        }, completion: { _ in
            self.addLabelWithAnimation()
        })
    }

    func addLabelWithAnimation() {

        let label           = UILabel(frame: bounds)
        label.text          = ""
        label.font          = UIFont.systemFontOfSize(170)
        label.textColor     = UIColor.lightGrayColor()
        label.textAlignment = NSTextAlignment.Center
        label.transform     = CGAffineTransformScale(label.transform, 0.25, 0.25)

        addSubview(label)

        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0, options: nil, animations: ({

            label.transform = CGAffineTransformIdentity

        }), completion: nil)
    }
}