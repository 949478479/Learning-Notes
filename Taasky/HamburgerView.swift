//
//  HamburgerView.swift
//  Taasky
//
//  Created by 从今以后 on 15/8/20.
//  Copyright (c) 2015年 Ray Wenderlich. All rights reserved.
//

import UIKit

class HamburgerView: UIView {

    private let imageView = UIImageView(image: UIImage(named: "Hamburger"))

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.contentMode = UIViewContentMode.Center
        
        addSubview(imageView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func rotate(fraction: CGFloat) {
        imageView.transform = CGAffineTransformMakeRotation( fraction * CGFloat(M_PI_2) )
    }
}