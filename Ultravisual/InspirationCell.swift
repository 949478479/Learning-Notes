//
//  TutorialCell.swift
//  RWDevCon
//
//  Created by Mic Pringle on 27/02/2015.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit

class InspirationCell: UICollectionViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var timeAndRoomLabel: UILabel!
    @IBOutlet private weak var speakerLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var imageCoverView: UIView!

    var inspiration: Inspiration? {
        didSet {
            titleLabel.text       = inspiration?.title
            timeAndRoomLabel.text = inspiration?.roomAndTime
            speakerLabel.text     = inspiration?.speaker
            imageView.image       = inspiration?.backgroundImage
        }
    }

    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {

        let standardHeight = UltravisualLayoutConstants.Cell.standardHeight
        let featuredHeight = UltravisualLayoutConstants.Cell.featuredHeight

        // 蒙版透明度.
        let minAlpha: CGFloat = 0.3
        let maxAlpha: CGFloat = 0.75

        // cell 高度由 standardHeight => featuredHeight 时, delta 范围由 0 => 1 .
        let delta = 1 - (featuredHeight - bounds.height) / (featuredHeight - standardHeight)

        // alpha 由 0.75 => 0.3 .
        imageCoverView.alpha = maxAlpha - delta * (maxAlpha - minAlpha)

        // alpha 由 0 => 1 .
        timeAndRoomLabel.alpha = delta
        speakerLabel.alpha     = delta

        // 文本标签 scale 由 0.5 => 1 ,即 standardCell 的缩小显示, featuredCell 的放大到正常显示.
        let scale = max(0.5, delta)
        titleLabel.transform = CGAffineTransformMakeScale(scale, scale)
    }
}