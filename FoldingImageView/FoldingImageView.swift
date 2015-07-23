//
//  FoldingImageView.swift
//  FoldingImageView
//
//  Created by 从今以后 on 15/7/22.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

import UIKit

enum PanDirection {
    case Up
    case Down
    case Left
    case Right
    case Unspecified
}

@IBDesignable
class FoldingImageView: UIView {

    @IBInspectable var image: UIImage? {
        didSet {
            imageLayer.contents = image?.CGImage
        }
    }

    private let imageLayer = CALayer()

    private lazy var pageLayer1: CALayer = self.p_configureLayerBasicAttributes(CALayer()) // 左方/上方 的图层.
    private lazy var pageLayer2: CALayer = self.p_configureLayerBasicAttributes(CALayer()) // 右方/下方 的图层.

    private lazy var shadowLayer1 = CAGradientLayer()
    private lazy var shadowLayer2 = CAGradientLayer()

    private var animationPropertyNamed: String?
    private var panDirection: PanDirection = .Unspecified

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(p_configureLayerBasicAttributes(imageLayer))
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.addSublayer(p_configureLayerBasicAttributes(imageLayer))
    }

    // MARK: - 配置图层基本属性

    private func p_configureLayerBasicAttributes(layer: CALayer) -> CALayer {
        layer.masksToBounds   = (contentMode != .ScaleAspectFit)
        layer.transform.m34   = -1 / 1_000
        layer.contentsScale   = UIScreen.mainScreen().scale
        layer.contentsGravity = {
            switch self.contentMode {
            case .ScaleAspectFill: return kCAGravityResizeAspectFill
            case .ScaleAspectFit:  return kCAGravityResizeAspect
            default:               return kCAGravityResize
            }
        }()
        return layer
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()

        if imageLayer.frame != bounds {
            imageLayer.frame = bounds
        }
    }

    // MARK: - 手势处理

    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return image != nil
    }

    @IBAction private func p_panGestureRecognizerHandle(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .Changed:
            if CGRectContainsPoint(bounds, pan.locationInView(self)) {
                let percent = p_calculatePercentForTranslation(pan.translationInView(self))
                p_foldImageViewWithAnimationForPercent(percent)
            } else {
                pan.enabled = false
            }
        case .Began:
            panDirection = p_determinePanDirectionForInitialVelocity(pan.velocityInView(self))
            if p_shouldDividePagesForInitialLocation(pan.locationInView(self)) {
                p_dividePages()
            } else {
                panDirection = .Unspecified
                pan.enabled = false
            }
        default:
            pan.enabled = true
            if let propertyNamed = animationPropertyNamed {
                userInteractionEnabled = false
                animationPropertyNamed = nil
                p_recoverAnimationForPropertyNamed(propertyNamed)
            }
        }
    }

    private func p_determinePanDirectionForInitialVelocity(velocity: CGPoint) -> PanDirection {
        let velocity = (velocity.x, velocity.y)
        switch velocity {
        case (0, let y) where y < 0: return .Up
        case (0, let y) where y > 0: return .Down
        case (let x, 0) where x < 0: return .Left
        case (let x, 0) where x > 0: return .Right
        default:                     return .Unspecified
        }
    }

    // MARK: - 分页

    private func p_shouldDividePagesForInitialLocation(location: CGPoint) -> Bool {
        switch panDirection {
        case .Up:          return location.y > bounds.midY
        case .Down:        return location.y < bounds.midY
        case .Left:        return location.x > bounds.midX
        case .Right:       return location.x < bounds.midX
        case .Unspecified: return false
        }
    }

    private func p_calculateImageRect() -> CGRect {

        if contentMode == .ScaleAspectFit {

            let contentSize: CGSize
            let contentOrigin: CGPoint
            let aspectRatio = image!.size.height / image!.size.width

            // 图片两侧不吻合父视图边界,上下吻合.
            if bounds.width * aspectRatio > bounds.height {
                contentSize   = CGSize(width: bounds.height / aspectRatio, height: bounds.height)
                contentOrigin = CGPoint(x: bounds.midX - contentSize.width / 2, y: 0)
            }
            // 图片上下不吻合父视图边界,两侧吻合.或者四边都吻合.
            else {
                contentSize   = CGSize(width: bounds.width, height: bounds.width * aspectRatio)
                contentOrigin = CGPoint(x: 0, y: bounds.midY - contentSize.height / 2)
            }

            return CGRect(origin: contentOrigin, size: contentSize)

        } else {
            return bounds // 图片完全填充.
        }
    }

    // 针对 AspectFit 的两种情况进行像素舍入,不然分页显示时有缝.
    private func p_roundSize(var size: CGSize) -> CGSize {
        if contentMode != .ScaleAspectFit { return size }

        let scale = UIScreen.mainScreen().scale
        if bounds.width == size.width {
            size.height = round(size.height * scale) / scale
        } else {
            size.width  = round(size.width  * scale) / scale
        }
        return size
    }

    private func p_dividePages() {

        var bounds   = CGRect()
        let position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)

        let anchorPoint1:  CGPoint, anchorPoint2:  CGPoint
        let contentsRect1: CGRect,  contentsRect2: CGRect

        let imageRect            = p_calculateImageRect()
        let imageAspectRatio     = image!.size.height       / image!.size.width
        let imageViewAspectRatio = imageLayer.bounds.height / imageLayer.bounds.width

        switch panDirection {
        case .Up, .Down:

            anchorPoint1 = CGPoint(x: 0.5, y: 1)
            anchorPoint2 = CGPoint(x: 0.5, y: 0)

            if contentMode == .ScaleAspectFill && self.bounds.width * imageAspectRatio > self.bounds.height {
                let proportion = 1 - 0.5 * imageViewAspectRatio / imageAspectRatio
                contentsRect1  = CGRect(x: 0, y: 0,              width: 1, height: proportion)
                contentsRect2  = CGRect(x: 0, y: 1 - proportion, width: 1, height: proportion)
            } else {
                contentsRect1  = CGRect(x: 0, y: 0,   width: 1, height: 0.5)
                contentsRect2  = CGRect(x: 0, y: 0.5, width: 1, height: 0.5)
            }

            bounds.size = p_roundSize(CGSize(width: imageRect.width, height: imageRect.height / 2))

        case .Left, .Right:

            anchorPoint1 = CGPoint(x: 1, y: 0.5)
            anchorPoint2 = CGPoint(x: 0, y: 0.5)

            if contentMode == .ScaleAspectFill && self.bounds.width * imageAspectRatio < self.bounds.height {
                let proportion =  1 - 0.5 * imageAspectRatio / imageViewAspectRatio
                contentsRect1  = CGRect(x: 0,   y: 0, width: proportion,     height: 1)
                contentsRect2  = CGRect(x: 0.5, y: 0, width: 1 - proportion, height: 1)
            } else {
                contentsRect1 = CGRect(x: 0,   y: 0, width: 0.5, height: 1)
                contentsRect2 = CGRect(x: 0.5, y: 0, width: 0.5, height: 1)
            }

            bounds.size = p_roundSize(CGSize(width: imageRect.width / 2, height: imageRect.height))
            
        case .Unspecified: return
        }

        imageLayer.hidden = true

        p_configureLayerWithoutImplicitAnimation {
            self.layer.addSublayer(self.p_configurePageLayer(self.pageLayer1, withAnchorPoint: anchorPoint1, position: position, bounds: bounds, contentsRect: contentsRect1))
            self.layer.addSublayer(self.p_configurePageLayer(self.pageLayer2, withAnchorPoint: anchorPoint2, position: position, bounds: bounds, contentsRect: contentsRect2))

            self.layer.addSublayer(self.p_configureShadowlayer(self.shadowLayer1, forPageLayer: self.pageLayer1))
            self.layer.addSublayer(self.p_configureShadowlayer(self.shadowLayer2, forPageLayer: self.pageLayer2))
        }
    }

    private func p_configurePageLayer(layer: CALayer, withAnchorPoint anchorPoint: CGPoint, position: CGPoint, bounds: CGRect, contentsRect: CGRect) -> CALayer {
        layer.shouldRasterize    = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        layer.contents           = self.imageLayer.contents
        layer.anchorPoint        = anchorPoint
        layer.contentsRect       = contentsRect
        layer.position           = position
        layer.bounds             = bounds
        return layer
    }

    private func p_configureShadowlayer(shadowLayer: CAGradientLayer, forPageLayer pageLayer: CALayer) -> CAGradientLayer {
        shadowLayer.opacity       = 0
        shadowLayer.transform     = CATransform3DIdentity
        shadowLayer.transform.m34 = -1 / 1_000
        shadowLayer.anchorPoint   = pageLayer.anchorPoint
        shadowLayer.frame         = pageLayer.frame

        if panDirection == .Left || panDirection == .Right {
            shadowLayer.startPoint = CGPoint(x: 0, y: 0.5)
            shadowLayer.endPoint   = CGPoint(x: 1, y: 0.5)
        } else {
            shadowLayer.startPoint = CGPoint(x: 0.5, y: 0)
            shadowLayer.endPoint   = CGPoint(x: 0.5, y: 1)
        }

        if pageLayer === pageLayer1 {
            shadowLayer.colors = [UIColor.clearColor().CGColor, UIColor.blackColor().CGColor]
        } else {
            shadowLayer.colors = [UIColor.blackColor().CGColor, UIColor.clearColor().CGColor]
        }

        return shadowLayer
    }

    // MARK: - 动画

    private func p_calculatePercentForTranslation(translation: CGPoint) -> CGFloat {
        switch panDirection {
        case .Up:          return max(0, min(-translation.y / bounds.height, 1))
        case .Down:        return max(0, min(+translation.y / bounds.height, 1))
        case .Left:        return max(0, min(-translation.x / bounds.width,  1))
        case .Right:       return max(0, min(+translation.x / bounds.width,  1))
        case .Unspecified: return CGFloat.min
        }
    }

    private func p_animatingLayers() -> [CALayer]? {
        switch panDirection {
        case .Down, .Right: return [pageLayer1, shadowLayer1]
        case .Up, .Left:    return [pageLayer2, shadowLayer2]
        case .Unspecified:  return nil
        }
    }

    private func p_foldImageViewWithAnimationForPercent(percent: CGFloat) {
        let keyPath: String
        let factor: CGFloat

        switch panDirection {
        case .Up, .Down:
            factor  = (panDirection == .Up) ? 1 : -1
            keyPath = "transform.rotation.x"
            animationPropertyNamed = kPOPLayerRotationX
        case .Left, .Right:
            factor  = (panDirection == .Right) ? 1 : -1
            keyPath = "transform.rotation.y"
            animationPropertyNamed = kPOPLayerRotationY
        case .Unspecified: return
        }

        [shadowLayer1, shadowLayer2].map { $0.opacity = Float(percent) }
        p_animatingLayers()?.map {
            $0.setValue(CGFloat(M_PI_2) * factor * percent, forKeyPath: keyPath)
        }
    }

    private func p_recoverAnimationForPropertyNamed(propertyNamed: String) {
        let recoverAnimation = POPSpringAnimation(propertyNamed: propertyNamed)
        recoverAnimation.toValue  = 0
        recoverAnimation.delegate = self
        recoverAnimation.springBounciness = 25
        recoverAnimation.name = "recoverAnimation"
        p_animatingLayers()?.map { layer -> () in
            if layer === self.pageLayer1 || layer === self.pageLayer2 {
                layer.pop_addAnimation(recoverAnimation, forKey: "recoverAnimation")
            }
        }
        [shadowLayer1, shadowLayer2].map { $0.removeFromSuperlayer() }
    }
}

// MARK: - POPAnimationDelegate

extension FoldingImageView: POPAnimationDelegate {
    func pop_animationDidStop(anim: POPAnimation!, finished: Bool) {
        userInteractionEnabled = true
        p_configureLayerWithoutImplicitAnimation {
            self.imageLayer.hidden = false
        }
        [pageLayer1, pageLayer2].map { $0.removeFromSuperlayer() }
    }
}

// MARK: - 辅助函数

private func p_configureLayerWithoutImplicitAnimation(configuration: () -> ()) {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    configuration()
    CATransaction.commit()
}