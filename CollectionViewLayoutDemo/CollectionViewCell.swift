//
//  CollectionViewCell.swift
//  CollectionViewLayoutDemo
//
//  Created by 从今以后 on 15/8/9.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBInspectable
    var cornerRadius: CGFloat = 0

    @IBInspectable
    var borderWidth: CGFloat = 0

    @IBInspectable
    var borderColor: UIColor?

    @IBOutlet
    weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.shouldRasterize    = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        
        imageView.layer.borderWidth   = borderWidth
        imageView.layer.borderColor   = borderColor?.CGColor
        imageView.layer.cornerRadius  = cornerRadius
        imageView.layer.masksToBounds = cornerRadius > 0
    }
}