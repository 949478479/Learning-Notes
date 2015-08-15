//
//  RestaurantCell.swift
//  FoodPin
//
//  Created by 从今以后 on 15/8/15.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

import UIKit

class RestaurantCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var favorIconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        thumbnailImageView.layer.shouldRasterize    = true
        thumbnailImageView.layer.rasterizationScale = UIScreen.mainScreen().scale
        thumbnailImageView.layer.masksToBounds      = true
        thumbnailImageView.layer.cornerRadius       = thumbnailImageView.bounds.width / 2
    }
}