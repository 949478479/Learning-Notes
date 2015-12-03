//
//  File.swift
//  CurveRefreshControl
//
//  Created by 从今以后 on 15/11/28.
//  Copyright © 2015年 从今以后. All rights reserved.
//

import UIKit

private let _bounds = CGRect(x: 0, y: 0, width: 60, height: 60)

private enum RefreshState {
    case Idle, WillRefresh, Refreshing, EndRefresh
}

final class CurveRefreshControl: UIView {

    var refreshingHandler: (Void -> Void)?
    private(set) var refreshing = false

    private var _state = RefreshState.Idle
    private var _kvoContext: UnsafeMutablePointer<Void>!
    private var _curveRefreshView = _CurveRefreshView(frame: _bounds)
    private var _scrollView: UIScrollView { return superview as! UIScrollView }
    private var _contentInsetTop: CGFloat = 64
    private var _manualAdjustContentOffset = false

    // MARK: 初始化

    init() {
        super.init(frame: _bounds)
        _configure()
        _setupCurveRefreshView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func _configure() {
        alpha = 0
        hidden = true
        clipsToBounds = true
//        backgroundColor = UIColor.orangeColor()
//        _curveRefreshView.backgroundColor = UIColor.greenColor()
        _kvoContext = UnsafeMutablePointer(unsafeAddressOf(self))
    }

    private func _setupCurveRefreshView() {
        addSubview(_curveRefreshView)
        _curveRefreshView.translatesAutoresizingMaskIntoConstraints = false
        _curveRefreshView.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
        _curveRefreshView.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
        _curveRefreshView.widthAnchor.constraintEqualToConstant(_bounds.width).active = true
        _curveRefreshView.heightAnchor.constraintEqualToConstant(_bounds.height).active = true
    }

    // MARK: 布局调整

    private func _adjustCenterX() {
        center.x = _scrollView.bounds.midX
    }

    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        var nextResponder = _scrollView.nextResponder()
        while nextResponder != nil && !(nextResponder is UIViewController) {
            nextResponder = nextResponder?.nextResponder()
        }
        if let vc = nextResponder as? UIViewController {
            if vc.navigationController?.navigationBar != nil {
                _contentInsetTop = vc.topLayoutGuide.length
            } else {
                _contentInsetTop = 0
            }
        }
    }

    // MARK: KVO

    override func willMoveToWindow(newWindow: UIWindow?) {
        newWindow != nil ? _registerKVO() : _unregisterKVO()
    }

    private func _registerKVO() {
        _scrollView.addObserver(self, forKeyPath: "frame", options: [], context: _kvoContext)
        _scrollView.addObserver(self, forKeyPath: "contentOffset", options: [], context: _kvoContext)
    }

    private func _unregisterKVO() {
        _scrollView.removeObserver(self, forKeyPath: "frame", context: _kvoContext)
        _scrollView.removeObserver(self, forKeyPath: "contentOffset", context: _kvoContext)
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
        change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == _kvoContext {
            guard let keyPath = keyPath else { return }
            switch keyPath {
            case "frame": _adjustCenterX()
            case "contentOffset": _updateProgress()
            default: break
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }

    // MARK: 更新进度

    private func _updateProgress() {
        guard _manualAdjustContentOffset || _scrollView.tracking || _scrollView.decelerating else { return }

        let contentOffsetY = _scrollView.contentOffset.y
        let delta = -(contentOffsetY + _contentInsetTop)

//        print("contentOffsetY: \(contentOffsetY) delta: \(delta) center: \(-delta / 2)")

        // 随着拖拽幅度调整垂直位置以及尺寸，不要露出多余的部分
        _updateFrameWithDragDistance(delta)

        // 处于刷新状态时只调整垂直位置，不对用户拖拽做进一步处理
        guard _state != .Refreshing || _manualAdjustContentOffset else { return }

        // 已满足刷新拖拽幅度，且用户松手，此时触发刷新
        if _state == .WillRefresh && !_scrollView.tracking {
            _beginRefreshing()
            return
        }

        // 乘上 0.85 是为了要求手动拖拽时幅度更大一些，否则回弹太快，来不及设置 contentInset.top
        let radio: CGFloat = _scrollView.tracking ? 0.85 : 1
        let progress = CGFloat( max(0, min(radio * delta / _bounds.height, 1)) )

        _updateStateWithProgress(progress)

        if progress == 1 {
            // manualAdjustContentOffset 状态下分为开始和结束两种情况，都会造成 progress 为 1
            if _state == .Refreshing && _manualAdjustContentOffset {
                _curveRefreshView.beginRefreshingAnimation()
                _endAdjustContentOffsetForOpen(true)
                return
            }
            // 用户拖拽时才标记刷新，忽略惯性或者代码调整的情况
            if _scrollView.tracking {
                _state = .WillRefresh
                return
            }
        }

        if progress == 0 {
            // manualAdjustContentOffset 状态下分为开始和结束两种情况，都会造成 progress 为 0
            if _state == .EndRefresh && _manualAdjustContentOffset {
                _state = .Idle
                refreshing = false
                _endAdjustContentOffsetForOpen(false)
                return
            }
            // 惯性减速到零，而非手动拖拽
            if _scrollView.decelerating {
                _state = .Idle
                return
            }
        }
    }

    private func _updateFrameWithDragDistance(distance: CGFloat) {
        bounds.size.height = max(0, min(distance, _bounds.height))
        center = CGPoint(x: _scrollView.bounds.width / 2, y: -distance / 2)
    }

    private func _updateStateWithProgress(progress: CGFloat) {
        alpha = progress
        hidden = (progress == 0)
        _curveRefreshView.progress = progress
    }

    // MARK: 动画控制

    private func _beginRefreshing() {
        guard !refreshing else { return }

        refreshing = true
        _state = .Refreshing

        _curveRefreshView.beginRefreshingAnimation()
        UIView.animateWithDuration(0.3, animations: {
            self.center.y = -_bounds.height / 2
            self._scrollView.contentInset.top += _bounds.height
        }, completion: { _ in
            self.refreshingHandler?()
        })
    }

    private func _beginAdjustContentOffsetForOpen(open: Bool) {
        _manualAdjustContentOffset = true
        _scrollView.userInteractionEnabled = false

        var contentOffset = _scrollView.contentOffset
        contentOffset.y += (open ? -_bounds.height : _bounds.height)
        _scrollView.setContentOffset(contentOffset, animated: true)
    }

    private func _endAdjustContentOffsetForOpen(open: Bool) {
        _manualAdjustContentOffset = false
        _scrollView.userInteractionEnabled = true
        _scrollView.contentInset.top += (open ? _bounds.height : -_bounds.height)
    }

    func beginRefreshing() {
        guard !refreshing else { return }
        refreshing = true
        _state = .Refreshing
        _beginAdjustContentOffsetForOpen(true)
    }

    func endRefreshing() {
        guard refreshing else { return }
        _state = .EndRefresh
        _beginAdjustContentOffsetForOpen(false)
        _curveRefreshView.endRefreshingAnimation()
    }
}

private final class _CurveRefreshView: UIView {

    // MARK: 属性

    let frequency = 1.0
    let radius: CGFloat = 10.0
    let lineWidth: CGFloat = 2.0
    let arrowAngle: CGFloat = CGFloat(M_PI / 6)
    let arrowLength: CGFloat = 3.0

    var refreshing = false
    var didAddAnimation = false

    var progress: CGFloat = 0 {
        didSet {
            guard refreshing == false else { return }

            progress == 0 ? removeInteractiveAnimationIfNeed() : addInteractiveAnimationIfNeed()

            let _progress = Double(progress)

            leftLineLayer.timeOffset = _progress
            rightLineLayer.timeOffset = _progress
            leftArrowLayer.timeOffset = _progress
            rightArrowLayer.timeOffset = _progress
        }
    }

    var refreshingAnimation: CAAnimation!
    var lineAnimation: CAAnimationGroup!
    var leftArrowAnimation: CAAnimationGroup!
    var rightArrowAnimation: CAAnimationGroup!

    let leftLineLayer = CAShapeLayer()
    let leftArrowLayer = CAShapeLayer()

    let rightLineLayer = CAShapeLayer()
    let rightArrowLayer = CAShapeLayer()

    // MARK: 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        setupLayer()
        configureArrowAnimation()
        configureRefreshingAnimation()
        configureLineLayerAnimatetion()
    }

    // MARK: 调整颜色
    
    override func tintColorDidChange() {
        let strokeColor = tintColor.CGColor
        leftLineLayer.strokeColor = strokeColor
        rightLineLayer.strokeColor = strokeColor
        leftArrowLayer.strokeColor = strokeColor
        rightArrowLayer.strokeColor = strokeColor
    }

    // MARK: 配置图层

    func setupLayer() {
        layer.addSublayer(configureLineLayer(leftLineLayer))
        layer.addSublayer(configureLineLayer(rightLineLayer))
        layer.addSublayer(configureArrowLayer(leftArrowLayer))
        layer.addSublayer(configureArrowLayer(rightArrowLayer))
    }

    func configureLineLayer(layer: CAShapeLayer, withPath path: CGPath) -> CAShapeLayer {

        layer.speed = 0
        layer.path = path
        layer.lineWidth = lineWidth
        layer.lineCap = kCALineCapRound
        layer.fillColor = nil
        layer.strokeColor = tintColor.CGColor

        return layer
    }

    func configureLineLayer(layer: CAShapeLayer) -> CAShapeLayer {

        let symbol: CGFloat = (layer === leftLineLayer ? -1 : 1)
        let startAngle = ( layer === leftLineLayer ? 0 : CGFloat(M_PI) )
        let deltaAngle = -CGFloat(M_PI)

        let path = CGPathCreateMutable()
        CGPathAddRelativeArc(path, nil, bounds.midX, bounds.midY, radius, startAngle, deltaAngle)
        CGPathAddLineToPoint(path, nil, bounds.midX + symbol * radius, bounds.midY - symbol * CGFloat(M_PI) * radius)

        return configureLineLayer(layer, withPath: path)
    }

    func configureArrowLayer(layer: CAShapeLayer) -> CAShapeLayer {

        let symbol: CGFloat = (layer === leftArrowLayer ? -1 : 1)

        let x1 = bounds.midX + symbol * radius
        let y1 = bounds.midY
        let x2 = bounds.midX + symbol * ( radius + arrowLength * sin(arrowAngle) )
        let y2 = bounds.midY - symbol * arrowLength * cos(arrowAngle)

        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, x1, y1)
        CGPathAddLineToPoint(path, nil, x2, y2)

        configureLineLayer(layer, withPath: path)

        let layerBounds = CGPathGetPathBoundingBox(path)
        layer.bounds = layerBounds

        // 将锚点的水平位置对应到视图中心，垂直位置对应到小箭头图层的顶部，主要是为了绕视图中心旋转
        let anchorX = -symbol * ( radius / layerBounds.width + (layer === leftArrowLayer ? 1 : 0) )
        let anchorY: CGFloat = (layer === leftArrowLayer ? 0 : 1)
        layer.anchorPoint = CGPoint(x: anchorX, y: anchorY)

        let originY = bounds.midY + (layer === leftArrowLayer ? 0 : -layerBounds.height)
        let originX = bounds.midX + (layer === rightArrowLayer ? 0 : -layerBounds.width) + symbol * radius
        layer.frame.origin = CGPoint(x: originX, y: originY)

        return layer
    }

    // MARK: 配置动画

    func configureRefreshingAnimation() {

        let _refreshingAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        _refreshingAnimation.byValue = M_PI * 2
        _refreshingAnimation.duration = 1 / frequency
        _refreshingAnimation.repeatCount = Float.infinity

        refreshingAnimation = _refreshingAnimation
    }

    func configureLineLayerAnimatetion() {

        let strokeStartAnimatetion = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimatetion.fromValue = 1.0
        strokeStartAnimatetion.toValue = 0.0

        let strokeEndAnimatetion = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimatetion.fromValue = 1.45
        strokeEndAnimatetion.toValue = 0.45

        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1.0
        animationGroup.animations = [strokeStartAnimatetion, strokeEndAnimatetion]

        lineAnimation = animationGroup
    }

    func configureArrowAnimation() {

        let positionAnimatetion = CABasicAnimation(keyPath: "position.y")
        positionAnimatetion.duration = 0.5
        positionAnimatetion.fromValue = bounds.height
        positionAnimatetion.toValue = bounds.midY

        let transformAnimatetion = CABasicAnimation(keyPath: "transform.rotation.z")
        transformAnimatetion.duration = 0.5
        transformAnimatetion.beginTime = 0.5
        transformAnimatetion.byValue = CGFloat(M_PI)

        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1.0
        animationGroup.animations = [positionAnimatetion.copy() as! CABasicAnimation, transformAnimatetion]

        leftArrowAnimation = animationGroup.copy() as! CAAnimationGroup

        positionAnimatetion.fromValue = 0
        positionAnimatetion.toValue = bounds.midY
        animationGroup.animations = [positionAnimatetion, transformAnimatetion]

        rightArrowAnimation = animationGroup
    }

    // MARK: 添加|移除交互动画

    func addInteractiveAnimationIfNeed() {
        guard didAddAnimation == false else { return }
        didAddAnimation = true

        leftLineLayer.addAnimation(lineAnimation, forKey: nil)
        rightLineLayer.addAnimation(lineAnimation, forKey: nil)
        leftArrowLayer.addAnimation(leftArrowAnimation, forKey: nil)
        rightArrowLayer.addAnimation(rightArrowAnimation, forKey: nil)
    }

    func removeInteractiveAnimationIfNeed() {
        guard didAddAnimation == true else { return }
        didAddAnimation = false

        leftArrowLayer.removeAllAnimations()
        leftLineLayer.removeAllAnimations()
        rightArrowLayer.removeAllAnimations()
        rightLineLayer.removeAllAnimations()
    }

    // MARK: 开始|停止刷新动画

    func beginRefreshingAnimation() {
        guard refreshing == false else { return }
        refreshing = true
        layer.addAnimation(refreshingAnimation, forKey: nil)
    }

    func endRefreshingAnimation() {
        guard refreshing == true else { return }
        refreshing = false
        layer.removeAllAnimations()
    }
}
