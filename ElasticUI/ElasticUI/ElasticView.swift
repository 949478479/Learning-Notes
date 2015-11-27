//
//  ElasticView.swift
//  ElasticUI
//
//  Created by 从今以后 on 15/11/27.
//  Copyright © 2015年 Daniel Tavares. All rights reserved.
//

import UIKit

class ElasticView: UIView {

    // MARK: 属性

    @IBInspectable var overshootAmount: CGFloat = 10.0

    private var didSetup = false

    private let topControlPointView    = UIView()
    private let leftControlPointView   = UIView()
    private let bottomControlPointView = UIView()
    private let rightControlPointView  = UIView()

    private let elasticShapeLayer = CAShapeLayer()

    private lazy var displayLink: CADisplayLink! = {
        let displayLink = CADisplayLink(target: self, selector: "updateLoop")
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        return displayLink
    }()

    // MARK: 基本配置

    override func layoutSubviews() {
        super.layoutSubviews()
        setupIfNeed()
    }

    // MARK: 移除定时器

    override func willMoveToSuperview(newSuperview: UIView?) {
        if newSuperview == nil {
            displayLink.invalidate()
            displayLink = nil
        }
    }

    // MARK: 激活动画

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        performAnimation()
    }

    // MARK: 执行动画
    
    func performAnimation() {

        UIView.animateWithDuration(0.25, delay: 0, usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0, options: [], animations: {
                self.topControlPointView.center.y    -= self.overshootAmount
                self.leftControlPointView.center.x   -= self.overshootAmount
                self.bottomControlPointView.center.y += self.overshootAmount
                self.rightControlPointView.center.x  += self.overshootAmount
            }, completion: { _ in
                UIView.animateWithDuration(0.45, delay: 0, usingSpringWithDamping: 0.15,
                    initialSpringVelocity: 0, options: [], animations: {
                        self.positionControlPoints()
                    }, completion: { _ in
                        self.stopUpdateLoop()
                })
        })

        startUpdateLoop()
    }
}

private extension ElasticView {

    // MARK: 基本配置

    func setupIfNeed() {
        guard didSetup == false else { return }
        didSetup = true

        setupElasticShapeLayer()
        setupControlPoints()
        positionControlPoints()
    }

    func setupElasticShapeLayer() {
        elasticShapeLayer.frame = bounds
        elasticShapeLayer.fillColor = backgroundColor?.CGColor
        layer.addSublayer(elasticShapeLayer)
    }

    func setupControlPoints() {
        addSubview(topControlPointView)
        addSubview(leftControlPointView)
        addSubview(bottomControlPointView)
        addSubview(rightControlPointView)
    }

    // MARK: 调整控制点

    func positionControlPoints() {
        topControlPointView.center    = CGPoint(x: bounds.midX, y: 0)
        leftControlPointView.center   = CGPoint(x: 0, y: bounds.midY)
        bottomControlPointView.center = CGPoint(x: bounds.midX, y: bounds.maxY)
        rightControlPointView.center  = CGPoint(x: bounds.maxX, y: bounds.midY)
    }

    // MARK: 实时计算路径

    func bezierPathForControlPoints() -> CGPath {

        let top = topControlPointView.layer.presentationLayer()!.position
        let left = leftControlPointView.layer.presentationLayer()!.position
        let bottom = bottomControlPointView.layer.presentationLayer()!.position
        let right = rightControlPointView.layer.presentationLayer()!.position

        let width = frame.width
        let height = frame.height

        let path = CGPathCreateMutable()

        CGPathMoveToPoint(path, nil, 0, 0)
        CGPathAddQuadCurveToPoint(path, nil, top.x, top.y, width, 0)
        CGPathAddQuadCurveToPoint(path, nil, right.x, right.y, width, height)
        CGPathAddQuadCurveToPoint(path, nil, bottom.x, bottom.y, 0, height)
        CGPathAddQuadCurveToPoint(path, nil, left.x, left.y, 0, 0)

        return path
    }

    // MARK: 定时器方法

    @objc func updateLoop() {
        elasticShapeLayer.path = bezierPathForControlPoints()
    }

    func startUpdateLoop() {
        displayLink.paused = false
    }

    func stopUpdateLoop() {
        displayLink.paused = true
    }
}
