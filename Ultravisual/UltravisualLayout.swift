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

    /* The amount the user needs to scroll before the featured cell changes */
    let dragOffset: CGFloat = UltravisualLayoutConstants.Cell.featuredHeight -
        UltravisualLayoutConstants.Cell.standardHeight

    private var yOffset: CGFloat {
        return collectionView!.contentOffset.y
    }

    /* Returns the item index of the currently featured cell */
    private var featuredItemIndex: Int {
        /* Use max to make sure the featureItemIndex is never < 0 */
        return max(0, Int(yOffset / dragOffset))
    }

    /* Returns a value between 0 and 1 that represents how close the next cell is to becoming the featured cell */
    private var nextItemPercentageOffset: CGFloat {
        return max(0, yOffset / dragOffset - CGFloat(featuredItemIndex))
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

    /* Return the size of all the content in the collection view */
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
        standardHeight 的 cell 数量.由于拖动中 featuredItemIndex 不会增长,直到下一个 standardHeight cell 
        完全变为 featuredHeight. 所以需要 +1 将新滚入屏幕的 cell 算进去.向下拖动时, featuredItemIndex
        会立即 -1, 这样和先前向上拖动时的索引区间是一样的,也不会多计算一个. */
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

                // 只要还是 featuredCell 就令高度保持为 featuredCellHeight.
                height = featuredHeight

                // 每拖动一个 dragOffset 距离, featuredCell 变为下一个 cell,下面的 standardCell 都上升一格.
                y = self.yOffset - standardHeight * self.nextItemPercentageOffset

            } else if indexPath.item == featuredItemIndex + 1 {

                // 每次拖动距离达到 dragOffset 时, 变大的那个 cell 高度刚好变大至 featuredHeight.
                height = standardHeight + self.dragOffset * self.nextItemPercentageOffset

                /* 先求得作为 standardCell 时底边 y 坐标,再减去此时实际高度作为实时 y 坐标. cell 变大过程中,
                底边 y 坐标不会额外改变,从而让后面的 standardCell 都能正常移动. */
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
        // 每拖动一个 dragOffset 距离正好对应一个 cell 变为 featuredCell.
        return CGPoint(x: 0, y: round(proposedContentOffset.y / dragOffset) * dragOffset)
    }
}