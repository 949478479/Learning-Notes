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
    private var anglePerItem: CGFloat {
        return atan(itemSize.width / radius)
    }

    /// 最大旋转角度,即将最后一个 cell 旋转至屏幕中间也就是初始 cell 的位置(向右拖动情况下).
    private var angleAtExtreme: CGFloat {
        let itemCount = collectionView!.numberOfItemsInSection(0)
        return itemCount > 0 ? -CGFloat(itemCount - 1) * anglePerItem : 0
    }

    /// 当前旋转角度,为负数弧度,根据 collectionView 拖动位置计算.
    private var currentAngle: CGFloat {
        return  angleAtExtreme * collectionView!.contentOffset.x /
            (collectionViewContentSize().width - collectionView!.bounds.width)
    }

    private var layoutAttributes = [CircularCollectionViewLayoutAttributes]()

    // MARK: - 指定自定义布局属性类

    override class func layoutAttributesClass() -> AnyClass {
        return CircularCollectionViewLayoutAttributes.self
    }

    // MARK: - 计算布局属性

    override func prepareLayout() {

        let itemCount = collectionView!.numberOfItemsInSection(0)

        let centerX = collectionView!.contentOffset.x + collectionView!.bounds.width / 2
        let anchorPointY = (radius + itemSize.height / 2) / itemSize.height

        // 圆心与屏幕左下角连线 与 过圆心直线 间的夹角.
        let θ = atan( (collectionView!.bounds.width / 2) /
            (radius + itemSize.height / 2 - collectionView!.bounds.height / 2) )

        // currentAngle 是负数弧度, θ 是正数弧度.
        // 轮子逆时针旋转弧度大小为 θ 时,此时第一个 cell 只有一小部分还在屏幕范围内,因为 cell 间是有一定间距的,
        // 所以对于逆时针旋转弧度大小超过 θ 的 cell, 最多只有索引最大的那个 cell 还在屏幕范围,或者都不在.
        // -currentAngle - θ 为弧度大小超过 θ 的部分,除以 anglePerItem, 整数部分即是屏幕范围外的 cell 个数,
        // 小数部分(如果未整除)则对应还有部分在屏幕范围的 cell. 该整数值也正好是屏幕范围的那个 cell 的索引.
        let startIndex = (currentAngle < -θ) ? Int((-currentAngle - θ) / anglePerItem) : 0

        // 屏幕右侧,未旋转时, θ / anglePerItem 的整数部分刚好表示最右侧且完全在屏幕范围的 cell 的索引,
        // 小数部分则对应最右侧但是只有部分在屏幕的 cell, 因此屏幕范围内的 cell 最大索引要用 ceil(_:) 函数上舍入.
        // 轮子旋转时,需把旋转弧度加上,即 (-currentAngle + θ) / anglePerItem. 
        // min 是为了防止越界,例如旋转到最大旋转角度时,计算所得索引为 itemCount.
        // 当然这么计算出来的 cell 是没有考虑屏幕左边离屏的情况的,所以还需要配合 startIndex.
        let endIndex = min(itemCount - 1, Int(ceil( (-currentAngle + θ) / anglePerItem )))

        // FIXME: -
//        if (endIndex < startIndex) {
//            endIndex = 0
//            startIndex = 0
//        }

        // 只计算屏幕范围内 cell 的的布局属性.
        layoutAttributes = (startIndex...endIndex).map {

            let indexPath = NSIndexPath(forItem: $0, inSection: 0)

            let attributes = CircularCollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)

            attributes.size        = self.itemSize
            attributes.zIndex      = $0
            attributes.center      = CGPoint(x: centerX, y: self.collectionView!.bounds.midY)
            attributes.transform   = CGAffineTransformMakeRotation(self.anglePerItem * CGFloat($0) + self.currentAngle)
            attributes.anchorPoint = CGPoint(x: 0.5, y: anchorPointY) // 改变锚点,使旋转圆心在屏幕下方.

            return attributes
        }
    }

    // MARK: - 提供布局属性

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        return layoutAttributes.filter { CGRectIntersectsRect($0.frame, rect) }
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