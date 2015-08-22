//
//  MenuItemCell.swift
//  Taasky
//
//  Created by Audrey M Tam on 18/03/2015.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit

class MenuItemCell: UITableViewCell {

    @IBOutlet private weak var menuItemImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        // 开启光栅化,不然动画时毛边太明显了.
        layer.shouldRasterize    = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
    }

    func configureForMenuItem(menuItem: NSDictionary) {
        backgroundColor = UIColor(colorArray: menuItem["colors"] as! NSArray)
        menuItemImageView.image = UIImage(named: menuItem["image"] as! String)
    }
}