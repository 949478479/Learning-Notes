//
//  NewsTableViewCell.swift
//  SlideMenu
//
//  Created by Simon Ng on 7/2/15.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postAuthor: UILabel!
    @IBOutlet weak var authorImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        authorImageView.layer.masksToBounds      = true
        authorImageView.layer.cornerRadius       = authorImageView.frame.width / 2
        authorImageView.layer.shouldRasterize    = true
        authorImageView.layer.rasterizationScale = UIScreen.mainScreen().scale

        contentView.updateConstraintsIfNeeded()
    }
}