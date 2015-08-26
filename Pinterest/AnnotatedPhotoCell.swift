//
//  AnnotatedPhotoCell.swift
//  RWDevCon
//
//  Created by Mic Pringle on 26/02/2015.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit

@IBDesignable
class AnnotatedPhotoCell: UICollectionViewCell {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var imageViewHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet private weak var captionLabel: UILabel!
    @IBOutlet private weak var commentLabel: UILabel!

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }

    var photo: Photo? {
        didSet {
            if let photo = photo {
                imageView.image   = photo.image
                captionLabel.text = photo.caption
                commentLabel.text = photo.comment
            }
        }
    }

    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {

        super.applyLayoutAttributes(layoutAttributes) // 保证超类的原有属性得以应用.

        imageViewHeightLayoutConstraint.constant = (layoutAttributes as! PinterestLayoutAttributes).photoHeight
    }
}