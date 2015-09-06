//
//  CircularCollectionViewLayout.swift
//  CircularCollectionView
//
//  Created by 从今以后 on 15/8/28.
//  Copyright (c) 2015年 Rounak Jain. All rights reserved.
//

import UIKit

class CircularCollectionViewLayout: UICollectionViewLayout {

    var itemSize = CGSize(width: 133, height: 173)

    var radius: CGFloat = 500 {
        didSet {
            invalidateLayout() // 半径变化时重新布局.
        }
    }

    /// cell 间夹角.
    private var anglePerItem: CGFloat = 0

    /// 最大旋转角度.即向右拖动将最后一个 cell 旋转至屏幕中间也就是初始 cell 的位置.
    private var angleAtExtreme: CGFloat = 0

    /// 缓存布局属性.
    private var layoutAttributes: [CircularCollectionViewLayoutAttributes]!

    // MARK: - 指定自定义布局属性类

    override class func layoutAttributesClass() -> AnyClass {
        return CircularCollectionViewLayoutAttributes.self
    }

    // MARK: - 计算布局属性

    override func prepareLayout() {

        let itemCount = collectionView!.numberOfItemsInSection(0)

        if itemCount == 0 { return }

        // 可随意,只是这样计算比较方便,视觉效果也不错.
        anglePerItem = atan(itemSize.width / radius)

        angleAtExtreme = -anglePerItem * CGFloat(itemCount - 1)

        // 当前旋转角度,为负数弧度,根据 collectionView 滚动位置计算.
        let currentAngle = angleAtExtreme * collectionView!.contentOffset.x /
            (collectionViewContentSize().width - collectionView!.bounds.width)

        // 改变锚点,使旋转圆心在屏幕下方.
        // 正常锚点 y = 0.5, 对应高度一半.现在要修改锚点到屏幕下方圆心处,即在高度一半基础是加上半径.
        let anchorPointY = (radius + itemSize.height / 2) / itemSize.height

        // 让 cell 始终位于屏幕中心,再配合旋转造成轮子效果.
        let centerX = collectionView!.contentOffset.x + collectionView!.bounds.width / 2

        // 圆心与屏幕左下角连线 与 过圆心直线 间的夹角.
        let θ = atan( (collectionView!.bounds.width / 2) /
            (radius + itemSize.height / 2 - collectionView!.bounds.height / 2) )

        // 注意 currentAngle 是负数弧度, θ 是正数弧度.
        // 轮子逆时针旋转弧度绝对值为 θ 时,此时第一个 cell 只有一小部分还在屏幕范围内,因为 cell 间是有一定间距的,
        // 所以当一个 cell 逆时针旋转弧度绝对值为 θ 时, 它前面的 cell 肯定是在屏幕外的.
        // -currentAngle - θ 为轮子逆时针旋转弧度超过 θ 的部分,除以 cell 间夹角,整数部分即是屏幕范围外的 cell 个数,
        // 如果有小数部分,则说明有个 cell 只有部分还在屏幕范围.整数值也正好是该 cell 的索引.
        let startIndex = (currentAngle < -θ) ? Int( (-currentAngle - θ) / anglePerItem ) : 0

        // 屏幕右侧,未旋转时, θ / anglePerItem 的整数部分刚好表示最右侧且完全在屏幕范围的 cell 的索引,
        // 如果有小数部分,则表示最右侧有个 cell 只有部分在屏幕范围,屏幕范围内的 cell 最大索引需用 ceil(_:) 上舍入.
        // 轮子旋转时,需把旋转弧度加上,即 (-currentAngle + θ) / anglePerItem.
        // min 是为了防止越界,例如旋转到最大旋转角度时,计算所得索引为 itemCount.
        // 这么计算是没有考虑屏幕左边离屏的情况的,所以还需要配合 startIndex.
        let endIndex = min(itemCount - 1, Int(ceil( (-currentAngle + θ) / anglePerItem )))

        // 只计算屏幕范围内 cell 的的布局属性.
        layoutAttributes = (startIndex...endIndex).map {

            let indexPath = NSIndexPath(forItem: $0, inSection: 0)

            let attributes = CircularCollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)

            attributes.size        = self.itemSize
            attributes.zIndex      = $0
            attributes.center      = CGPoint(x: centerX, y: self.collectionView!.bounds.midY)
            attributes.transform   = CGAffineTransformMakeRotation(self.anglePerItem * CGFloat($0) + currentAngle)
            attributes.anchorPoint = CGPoint(x: 0.5, y: anchorPointY)

            return attributes
        }
    }

    // MARK: - 提供布局属性

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        return layoutAttributes
    }

    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath)
        -> UICollectionViewLayoutAttributes! {
        return layoutAttributes[indexPath.item]
    }

    // MARK: - 提供滚动范围

    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: CGFloat(collectionView!.numberOfItemsInSection(0)) * itemSize.width,
                     height: collectionView!.bounds.height)
    }

    // MARK: - 滚动时刷新布局属性

    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }

    // MARK: - 设置滚动停止时位置

    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint,
        withScrollingVelocity velocity: CGPoint) -> CGPoint {

        var proposedContentOffset = proposedContentOffset

        // 每移动一点对应的旋转弧度,即 弧度/点.
        let factor = angleAtExtreme / (collectionViewContentSize().width - collectionView!.bounds.width)

        // 停止时的旋转弧度.
        let proposedAngle = proposedContentOffset.x * factor

        // 停止时的旋转弧度对应多少个 cell.
        let multiple = proposedAngle / anglePerItem

        // 根据滚动方向取整数.
        let integralMultiple: CGFloat

        if velocity.x > 0 {
            integralMultiple = ceil(multiple)
        } else if velocity.x < 0 {
            integralMultiple = floor(multiple)
        } else {
            integralMultiple = round(multiple)
        }

        // "总弧度" ÷ "弧度/点" = "滚动距离".
        proposedContentOffset.x = (integralMultiple * anglePerItem) / factor

        return proposedContentOffset
    }
}

// MARK: - 自定义布局属性

class CircularCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {

    var anchorPoint = CGPoint(x: 0.5, y: 0.5)

    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! CircularCollectionViewLayoutAttributes
        copy.anchorPoint = anchorPoint
        return copy
    }

    override func isEqual(object: AnyObject?) -> Bool {
        if anchorPoint == (object as? CircularCollectionViewLayoutAttributes)?.anchorPoint {
            return super.isEqual(object)
        }
        return false
    }
}