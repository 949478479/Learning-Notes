//
//  AnimatedMaskLabel.swift
//  SlideToUnlock
//
//  Created by 从今以后 on 15/12/17.
//  Copyright © 2015年 从今以后. All rights reserved.
//

import UIKit

class AnimatedMaskLabel: UIView {

    @IBOutlet var label: UILabel!

    override class func layerClass() -> AnyClass {
        return CAGradientLayer.self
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        let gradientLayer = layer as! CAGradientLayer

        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.locations = [ 0, 0.5, 1 ]
        gradientLayer.colors = [
            label.textColor.CGColor,
            UIColor.whiteColor().CGColor,
            label.textColor.CGColor
        ]

        layer.mask = label.layer
    }

    override func didMoveToWindow() {
        guard window != nil else {
            layer.removeAllAnimations()
            return
        }

        let locationsAnimation = CABasicAnimation(keyPath: "locations")
        locationsAnimation.fromValue = [ -1, -0.5, 0 ]
        locationsAnimation.toValue = [ 1, 1.5, 2 ]
        locationsAnimation.duration = 3
        locationsAnimation.repeatCount = Float.infinity
        layer.addAnimation(locationsAnimation, forKey: nil)
    }
}
