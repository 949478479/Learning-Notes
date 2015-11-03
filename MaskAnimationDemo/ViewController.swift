//
//  ViewController.swift
//  MaskAnimationDemo
//
//  Created by 从今以后 on 15/11/3.
//  Copyright © 2015年 从今以后. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var ringImageView: UIImageView!
    @IBOutlet weak var grayHeadImageView: UIImageView!
    @IBOutlet weak var greenHeadImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        greenHeadImageView.layer.mask = createMaskLayerWithBounds(greenHeadImageView.bounds)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        animateRingImageView()
        animateCircleShapeLayer()
    }
}

private extension ViewController {

    func animateRingImageView() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.byValue = 2 * M_PI
        animation.duration = 1
        animation.repeatCount = Float.infinity
        ringImageView.layer.addAnimation(animation, forKey: nil)
    }

    func animateCircleShapeLayer() {
        let maskLayer = greenHeadImageView.layer.mask!

        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 1
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        animation.toValue = NSValue(CGPoint: CGPoint(x: maskLayer.bounds.midX, y: maskLayer.bounds.midY))

        maskLayer.sublayers?.forEach { $0.addAnimation(animation, forKey: nil) }
    }

    func createMaskLayerWithBounds(bounds: CGRect) -> CALayer {
        let mask = CALayer()
        mask.frame = bounds
        mask.addSublayer(createCircleShapeLayerWithBounds(bounds, position: CGPoint(x: -10, y: -10)))
        mask.addSublayer(createCircleShapeLayerWithBounds(bounds, position: CGPoint(x: bounds.maxX + 10, y: bounds.maxY + 10)))
        return mask
    }

    func createCircleShapeLayerWithBounds(bounds: CGRect, position: CGPoint) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = position
        shapeLayer.path = UIBezierPath(ovalInRect: bounds).CGPath
        return shapeLayer
    }
}

