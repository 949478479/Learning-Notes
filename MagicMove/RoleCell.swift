//
//  RoleCell.swift
//  MagicMove
//
//  Created by 从今以后 on 15/7/18.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

import UIKit

class RoleCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!

    func configureForRole(role: Role) {
        imageView.image = role.image
        nameLabel.text  = role.name
    }
}