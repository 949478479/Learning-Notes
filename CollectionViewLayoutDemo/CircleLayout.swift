//
//  CircleLayout.swift
//  CollectionViewLayoutDemo
//
//  Created by 从今以后 on 15/8/9.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

import UIKit

class CircleLayout: UICollectionViewLayout {
    
    @IBInspectable var center: CGPoint = CGPointZero

    @IBInspectable var radius: CGFloat = 0

    @IBInspectable var itemSize: CGSize = CGSizeZero

    private var itemCount: Int = 0
    private var angleDelta: CGFloat = 0

    private var insertIndexPaths: [NSIndexPath]!
    private var deleteIndexPaths: [NSIndexPath]!

    // MARK: - 布局准备

    override func prepareLayout() {

        let collectionViewSize = collectionView!.bounds.size

        center     = CGPoint(x: collectionViewSize.width / 2, y: collectionViewSize.height / 2)
        radius     = (collectionViewSize.height - itemSize.height) / 2 - 20 // 减去 20 点状态栏高度.
        itemCount  = collectionView!.numberOfItemsInSection(0)
        angleDelta = CGFloat(M_PI * 2) / CGFloat(itemCount)
    }

    // MARK: - 确定滚动范围

    override func collectionViewContentSize() -> CGSize {
        return collectionView!.bounds.size
    }

    // MARK: - 计算布局属性

    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {

        let angle = CGFloat(indexPath.item) * angleDelta

        let layoutAttributes    = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        layoutAttributes.zIndex = indexPath.item
        layoutAttributes.size   = itemSize
        layoutAttributes.center = CGPoint(x: center.x + radius * sin(angle),
                                          y: center.y - radius * cos(angle))
        return layoutAttributes
    }

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {

        var layoutAttributes = [UICollectionViewLayoutAttributes]()

        for item in 0..<itemCount {
            let indexPath = NSIndexPath(forItem: item, inSection: 0)
            layoutAttributes.append(layoutAttributesForItemAtIndexPath(indexPath))
        }

        return layoutAttributes
    }

    // MARK: - 动画准备/结束

    override func prepareForCollectionViewUpdates(updateItems: [AnyObject]!) {
        super.prepareForCollectionViewUpdates(updateItems)

        for updateItem in updateItems as! [UICollectionViewUpdateItem] {

            if updateItem.updateAction == .Insert {

                insertIndexPaths = [NSIndexPath]()
                insertIndexPaths.append(updateItem.indexPathAfterUpdate!)

            } else if updateItem.updateAction == .Delete {

                deleteIndexPaths = [NSIndexPath]()
                deleteIndexPaths.append(updateItem.indexPathBeforeUpdate!)
            }
        }
    }

    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()

        insertIndexPaths = nil
        deleteIndexPaths = nil
    }

    // MARK: - 动画布局属性.无论插入或删除, initial... 和 final... 方法均会调用,来确定初始和结束时的布局信息.

    override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {

        var layoutAttributes = super.initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath)

        // 需要确定是变化的那个 item 后再做进一步处理.
        if let insertIndexPaths = insertIndexPaths, index = find(insertIndexPaths, itemIndexPath) {

            assert(layoutAttributes != nil)

            // 由屏幕中间边旋转边变大到达最终插入位置.
            layoutAttributes?.center    = center
            layoutAttributes?.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(CGFloat(M_PI)), 0.01, 0.01)
        }

        // 不加这句 cell 的层级有时候不正确,然而即使加上了如果切换布局后再切回来也会层级不正确...不明白...
        layoutAttributes?.zIndex = itemIndexPath.item

        return layoutAttributes
    }

    override func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {

        var layoutAttributes = super.finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath)

        if let deleteIndexPaths = deleteIndexPaths, index = find(deleteIndexPaths, itemIndexPath) {
            
            layoutAttributes?.center    = center
            layoutAttributes?.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(CGFloat(M_PI)), 0.01, 0.01)
        }

        layoutAttributes?.zIndex = itemIndexPath.item

        return layoutAttributes
    }
}