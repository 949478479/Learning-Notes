//
//  PinterestLayout.swift
//  Pinterest
//
//  Created by 从今以后 on 15/8/26.
//  Copyright (c) 2015年 Razeware LLC. All rights reserved.
//

import UIKit

@objc protocol PinterestLayoutDelegate {

    /** 根据图片宽度提供对应高度. */
    func collectionView(collectionView: UICollectionView,
        heightForPhotoAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat

    /** 根据文本宽度提供对应高度. */
    func collectionView(collectionView: UICollectionView,
        heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat
}

class PinterestLayout: UICollectionViewLayout {

    weak var delegate: PinterestLayoutDelegate?

    var numberOfColumns = 2
    var cellPadding: CGFloat = 8

    private var contentWidth: CGFloat = 0
    private var contentHeight: CGFloat = 0

    /// 缓存计算好的布局属性,提高查询效率.
    private var attributesCache = [PinterestLayoutAttributes]()

    // MARK: - 布局计算

    override func prepareLayout() {

        contentWidth = collectionView!.bounds.width -
            collectionView!.contentInset.left - collectionView!.contentInset.right

        let columnWidth =
            (contentWidth - CGFloat(numberOfColumns - 1) * cellPadding) / CGFloat(numberOfColumns)
        
        var yOffset = [CGFloat](count: numberOfColumns, repeatedValue: 0)

        for item in 0..<collectionView!.numberOfItemsInSection(0) {

            let minY      = minElement(yOffset)  // 获取最低一列的高度.
            let colmun    = find(yOffset, minY)! // 获取最低一列的列数.
            let indexPath = NSIndexPath(forItem: item, inSection: 0)

            let photoHeight = delegate!.collectionView(collectionView!,
                heightForPhotoAtIndexPath: indexPath, withWidth: columnWidth)

            let annotationHeight = delegate!.collectionView(collectionView!,
                heightForAnnotationAtIndexPath: indexPath, withWidth: columnWidth)

            // 新 cell 插入到最低一列.
            let frame = CGRect(x: CGFloat(colmun) * (cellPadding + columnWidth),
                               y: minY + cellPadding,
                           width: columnWidth,
                          height: photoHeight + annotationHeight)

            let attributes = PinterestLayoutAttributes(forCellWithIndexPath: indexPath)
            attributes.frame = frame
            attributes.photoHeight = photoHeight
            attributesCache.append(attributes)

            yOffset[colmun] = frame.maxY // 更新插入新 cell 那列的高度.
        }

        contentHeight = maxElement(yOffset) // 最高一列的高度即是最大滚动范围.
    }

    override func collectionViewContentSize() -> CGSize {

        return CGSize(width: contentWidth, height: contentHeight)
    }

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {

        return attributesCache.filter { CGRectIntersectsRect($0.frame, rect) } 
    }

    // MARK: - 返回自定义的 UICollectionViewLayoutAttributes 子类

    override class func layoutAttributesClass() -> AnyClass {
        return PinterestLayoutAttributes.self
    }
}

// MARK: - 子类化 UICollectionViewLayoutAttributes

class PinterestLayoutAttributes: UICollectionViewLayoutAttributes {

    var photoHeight: CGFloat = 0

    // 继承 UICollectionViewLayoutAttributes 有两个硬性要求:
    // 1.覆盖 copyWithZone(_:) 方法,对增加的属性进行 copy.
    // 2.覆盖 isEqual(_:) 方法,在父类基础上加上对新增属性的判断.
    // 此外,布局类需要实现 layoutAttributesClass() 类方法, cell 需实现 applyLayoutAttributes(_:) 方法.
    override func copyWithZone(zone: NSZone) -> AnyObject {

        let copy = super.copyWithZone(zone) as! PinterestLayoutAttributes
        copy.photoHeight = photoHeight
        return copy
    }

    override func isEqual(object: AnyObject?) -> Bool {

        if photoHeight == (object as? PinterestLayoutAttributes)?.photoHeight {
            return super.isEqual(object)
        }

        return false
    }
}