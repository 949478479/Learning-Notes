//
//  ViewController.swift
//  Uberworks
//
//  Created by Marin Todorov on 10/29/15.
//  Copyright © 2015 Underplot ltd. All rights reserved.
//

import UIKit

func delay(seconds seconds: Double, completion: ()->()) {
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
    dispatch_after(popTime, dispatch_get_main_queue()) {
        completion()
    }
}

class ViewController: UIViewController {

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        view.layer.addSublayer(animatedLine(from: CGPoint(x: 160, y: 550), to: view.center))

        delay(seconds: 1.0) {
            self.view.layer.addSublayer(self.firework1(atPoint: self.view.center))
//            self.view.layer.addSublayer(self.firework2(atPoint: self.view.center))
        }
    }
}

private extension ViewController {

    func animatedLine(from from: CGPoint, to: CGPoint) -> CAShapeLayer {

        let linePath = UIBezierPath()
        linePath.moveToPoint(from)
        linePath.addLineToPoint(to)

        let line = CAShapeLayer()
        line.path = linePath.CGPath
        line.lineCap = kCALineCapRound
        line.strokeColor = UIColor.cyanColor().CGColor

        line.strokeEnd = 0.0
        UIView.animateWithDuration(1.0, delay: 0.0, options: [.CurveEaseOut], animations: {
            line.strokeEnd = 1.0
        }, completion: nil)

        UIView.animateWithDuration(0.75, delay: 0.9, options: [.CurveEaseOut], animations: {
            line.strokeStart = 1.0
        }, completion: nil)

        return line
    }

    func firework1(atPoint atPoint: CGPoint) -> CAReplicatorLayer {

        let replicator = CAReplicatorLayer()
        replicator.position = atPoint
        replicator.instanceCount = 20
        replicator.instanceTransform = CATransform3DMakeRotation(CGFloat(M_PI/10), 0, 0, 1)

        let f11linePath = UIBezierPath()
        f11linePath.moveToPoint(CGPoint(x: 0, y: 0))
        f11linePath.addLineToPoint(CGPoint(x: 0, y: -100))

        let f11line = CAShapeLayer()
        f11line.path = f11linePath.CGPath
        f11line.strokeColor = UIColor.cyanColor().CGColor
        replicator.addSublayer(f11line)

        f11line.strokeEnd = 0
        UIView.animateWithDuration(1.0, delay: 0.33, options: [.CurveEaseOut], animations: {
            f11line.strokeEnd = 1.0
        }, completion: nil)

        let f12linePath = UIBezierPath()
        f12linePath.moveToPoint(CGPoint(x: 0, y: -0))
        f12linePath.addLineToPoint(CGPoint(x: 0, y: -100))
        f12linePath.applyTransform(CGAffineTransformMakeRotation(CGFloat(M_PI/20)))

        let f12line = CAShapeLayer()
        f12line.path = f12linePath.CGPath
        f12line.lineDashPattern = [20, 2]
        f12line.strokeColor = UIColor.cyanColor().CGColor
        replicator.addSublayer(f12line)

        f12line.strokeEnd = 0
        UIView.animateWithDuration(1.0, delay: 0.0, options: [.CurveEaseOut], animations: {
            f12line.strokeEnd = 1.0
        }, completion: nil)

        UIView.animateWithDuration(1.0, delay: 1.0, options: [.CurveEaseIn], animations: {

            f11line.strokeStart = 1.0
            f12line.strokeStart = 0.5

            f11line.transform = CATransform3DMakeRotation(CGFloat(M_PI_4), 0, 0, 1)
            f12line.transform = CATransform3DMakeRotation(CGFloat(M_PI_4/2), 0, 0, 1)

            replicator.opacity = 0.0

        }, completion: nil)

        return replicator
    }

    func animatedDot(delta delta: CGFloat, delay: Double) -> CALayer {

        let dot = CALayer()
        dot.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        dot.backgroundColor = UIColor.cyanColor().CGColor

        UIView.animateAndChainWithDuration(1.0, delay: delay, options: [.CurveEaseOut], animations: {
            dot.transform = CATransform3DMakeTranslation(0, -delta, 0)
        }, completion: nil).animateWithDuration(2.0, animations: {
            dot.transform = CATransform3DConcat(dot.transform, CATransform3DMakeRotation(CGFloat(M_PI_4), 0, 0, 1))
        }).animateWithDuration(1.0, animations: {
            dot.transform = CATransform3DConcat(dot.transform, CATransform3DMakeTranslation(0, -delta, 0))
            dot.opacity = 0.1
        })

        return dot
    }

    func firework2(atPoint atPoint: CGPoint) -> CAReplicatorLayer {

        let replicator = CAReplicatorLayer()
        replicator.position = atPoint

        replicator.instanceCount = 40
        replicator.instanceTransform = CATransform3DMakeRotation(CGFloat(M_PI/20), 0, 0, 1)

        for i in 1...10 {
            replicator.addSublayer(animatedDot(delta: CGFloat(i*10), delay: 1/Double(i)))
        }
        return replicator
    }
}
