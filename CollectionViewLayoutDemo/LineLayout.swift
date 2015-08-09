//
//  LineLayout.swift
//  CollectionViewLayoutDemo
//
//  Created by 从今以后 on 15/8/9.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

import UIKit

class LineLayout: UICollectionViewFlowLayout {

    @IBInspectable var zoomFactor: CGFloat = 0

    @IBInspectable var activeDistance: CGFloat = 0

    @IBInspectable var itemLength: CGFloat = 0 {
        didSet {
            itemSize = CGSize(width: itemLength, height: itemLength)
        }
    }
    
    @IBInspectable var isHorizontal: Bool = false {
        didSet {
            scrollDirection = isHorizontal ? .Horizontal: .Vertical
        }
    }

    var selectedIndexPath: NSIndexPath!

    private var didPrepareLayout = false

    // MARK: - 布局准备

    override func prepareLayout() {
        super.prepareLayout()

        if didPrepareLayout { return } // 避免无谓的重复计算.

        didPrepareLayout = true

        let leftAndRightInset = (collectionView!.bounds.width - itemSize.width) / 2
        let topAndBottomInset = (collectionView!.bounds.height - itemSize.height * (1 + zoomFactor)) / 2

        activeDistance     = collectionView!.bounds.width / 2
        minimumLineSpacing = collectionView!.bounds.width / 2 - itemSize.width
        sectionInset       = UIEdgeInsets(top: topAndBottomInset,
                                         left: leftAndRightInset,
                                       bottom: topAndBottomInset,
                                        right: leftAndRightInset)
    }

    // MARK: - 更新布局

    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }

    // MARK: - 为了由其他布局切换至该布局时能正常放大.否则会先显示正常尺寸然后再突然变大.

    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {

        let layoutAttributes = super.layoutAttributesForItemAtIndexPath(indexPath)!

        if indexPath == selectedIndexPath {
            layoutAttributes.transform = CGAffineTransformMakeScale(1 + zoomFactor, 1 + zoomFactor)
        }

        return layoutAttributes
    }

    // MARK: - 滚动中实时根据距离中心的距离缩放单元格

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {

        let layoutAttributes = super.layoutAttributesForElementsInRect(rect)!

        let visiableRect = CGRect(origin: collectionView!.contentOffset,
                                    size: collectionView!.bounds.size)

        for attributes in layoutAttributes as! [UICollectionViewLayoutAttributes] {

            let distance = abs(visiableRect.midX - attributes.center.x)

            if distance < activeDistance {
                
                let zoom = 1 + zoomFactor * (1 - distance / activeDistance)
                attributes.transform = CGAffineTransformMakeScale(zoom, zoom)
            }
        }

        return layoutAttributes
    }

    // MARK: - 减速过程结束后自动对齐

    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {

        let proposedRect = CGRect(origin: proposedContentOffset, size: collectionView!.bounds.size)

        let layoutAttributes = super.layoutAttributesForElementsInRect(proposedRect)!

        var offsetAdjustment = CGFloat.max

        for attributes in layoutAttributes {

            let distance = attributes.center.x - proposedRect.midX

            if abs(distance) < abs(offsetAdjustment) {
                offsetAdjustment = distance
            }
        }

        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }

    // MARK: - 由其他布局切换至该布局时自动对齐

    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint) -> CGPoint {
        
        let layoutAttributes = layoutAttributesForItemAtIndexPath(selectedIndexPath)
        
        return CGPoint(x: layoutAttributes.center.x - collectionView!.bounds.width / 2,
                       y: proposedContentOffset.y)
    }
}