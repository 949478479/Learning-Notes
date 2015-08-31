//
//  UltravisualLayout.swift
//  RWDevCon
//
//  Created by Mic Pringle on 27/02/2015.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit

/* The heights are declared as constants outside of the class so they can be easily referenced elsewhere */
struct UltravisualLayoutConstants {
    struct Cell {
        /* The height of the non-featured cell */
        static let standardHeight: CGFloat = 100
        /* The height of the first visible cell */
        static let featuredHeight: CGFloat = 280
    }
}

class UltravisualLayout: UICollectionViewLayout {

    // MARK: - 属性

    /// standardCell 过渡到 featuredCell 的拖动距离.
    let dragOffset: CGFloat = UltravisualLayoutConstants.Cell.featuredHeight -
                              UltravisualLayoutConstants.Cell.standardHeight

    private var yOffset: CGFloat {
        return collectionView!.contentOffset.y
    }

    /// 当前 featuredCell 的索引,即 dragOffset 的整数倍.用 max(_:_:) 限制向上拖动时 yOffset 为负数的情况.
    private var featuredItemIndex: Int {
        return max(0, Int(yOffset / dragOffset))
    }

    /// standardCell 过渡到 featuredCell 的百分比,同样用 max(_:_:) 限制 yOffset 为负数的情况.
    private var nextItemPercentageOffset: CGFloat {
        return max(0, modf(yOffset / dragOffset).1)
    }

    /* Returns the width of the collection view */
    private var width: CGFloat {
        return collectionView!.bounds.width
    }

    /* Returns the height of the collection view */
    private var height: CGFloat {
        return collectionView!.bounds.height
    }

    /* Returns the number of items in the collection view */
    private var numberOfItems: Int {
        return collectionView!.numberOfItemsInSection(0)
    }

    private var cache = [UICollectionViewLayoutAttributes]()
    
    // MARK: - 计算滚动范围

    /* 至少要能拖动 numberOfItems 个 dragOffset .
    最后一个 featuredCell 显示在顶部时需凑足一页的范围,所以加上 height - dragOffset . */
    override func collectionViewContentSize() -> CGSize {
        let contentHeight = (CGFloat(numberOfItems) * dragOffset) + (height - dragOffset)
        return CGSize(width: width, height: contentHeight)
    }

    // MARK: - 计算布局属性

    override func prepareLayout() {

        let width             = self.width
        let featuredItemIndex = self.featuredItemIndex
        let standardHeight    = UltravisualLayoutConstants.Cell.standardHeight
        let featuredHeight    = UltravisualLayoutConstants.Cell.featuredHeight

        /* Int(ceil( (height - featuredHeight) / standardHeight )) 为开始拖动时当前屏幕显示的
        standardCell 的数量.由于拖动中 featuredItemIndex 不会增长,直到一个 standardCell 完全过渡到
        featuredCell .所以需要 +1 将新滚入屏幕的 standardCell 算进去.向下拖动时, featuredItemIndex 
        会立即 -1 ,这样和先前向上拖动时的索引区间是一样的,不会多计算一个. */
        let endIndex = min(
            Int(ceil( (height - featuredHeight) / standardHeight )) + 1 + featuredItemIndex,
            numberOfItems - 1
        )

        var y: CGFloat = 0

        cache = (featuredItemIndex...endIndex).map {

            let indexPath  = NSIndexPath(forItem: $0, inSection: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)

            let height: CGFloat

            if indexPath.item == featuredItemIndex {

                // 只要还是 featuredCell 就令高度保持为 featuredHeight.
                height = featuredHeight

                // 每拖动一个 dragOffset ,下面的 standardCell 都上升一格.
                y = self.yOffset - standardHeight * self.nextItemPercentageOffset

            } else if indexPath.item == featuredItemIndex + 1 {

                // 每次拖动距离达到 dragOffset , 一个 standardCell 高度增长到 featuredHeight.
                height = standardHeight + self.dragOffset * self.nextItemPercentageOffset

                /* 先求得作为 standardCell 时底边 y 坐标,再减去此时实际高度作为实时 y 坐标.过渡时,底边 y 坐标
                不会额外改变,从而让后面的 standardCell 都能正常移动. */
                y = (y + standardHeight) - height

            } else {

                height = standardHeight
            }

            attributes.zIndex = $0
            attributes.frame  = CGRect(x: 0, y: y, width: width, height: height)

            y += height // 更新 y 坐标.

            return attributes
        }
    }

    // MARK: - 供应布局属性

    /* Return all attributes in the cache whose frame intersects with the rect passed to the method */
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        return cache.filter { rect.intersects($0.frame) }
    }

    // 就该 demo 而言, layoutAttributesForItemAtIndexPath(_:) 方法可以不提供.

    // MARK: - 滚动刷新布局

    /* Return true so that the layout is continuously invalidated as the user scrolls */
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }

    // MARK: - 自动分页

    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint,
        withScrollingVelocity velocity: CGPoint) -> CGPoint {
        // 每拖动一个 dragOffset 对应一个 standardCell => featuredCell ,四舍五入求得整数个 dragOffset .
        return CGPoint(x: 0, y: round(proposedContentOffset.y / dragOffset) * dragOffset)
    }
}