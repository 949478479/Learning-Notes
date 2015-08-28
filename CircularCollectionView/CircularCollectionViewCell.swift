//
//  CircularCollectionViewCell.swift
//  CircularCollectionView
//
//  Created by Rounak Jain on 10/05/15.
//  Copyright (c) 2015 Rounak Jain. All rights reserved.
//

import UIKit

class CircularCollectionViewCell: UICollectionViewCell {

    var imageName: String! {
        didSet {
            imageView!.image = UIImage(named: imageName)
        }
    }

    @IBOutlet private weak var imageView: UIImageView!

    // MARK: - 配置基本属性

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.borderWidth = 1
        layer.borderColor = UIColor.blackColor().CGColor

        layer.cornerRadius = 5
        clipsToBounds      = true
    }

    // MARK: - 应用自定义布局属性

    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
        let circularlayoutAttributes = layoutAttributes as! CircularCollectionViewLayoutAttributes
        layer.anchorPoint = circularlayoutAttributes.anchorPoint
        // 由于锚点跑到了屏幕下方, cell 会跑到屏幕上方,需要将锚点变化造成的偏移抵消掉.
        center.y += (layer.anchorPoint.y - 0.5) * bounds.height
    }
}