//
//  ReviewViewController.swift
//  FoodPin
//
//  Created by 从今以后 on 15/8/16.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController {

    var backgroundImage: UIImage!

    @IBOutlet private weak var dialogView: UIView!
    @IBOutlet private weak var bgImageView: UIImageView!
    @IBOutlet private weak var sideLengthConstraint: NSLayoutConstraint!

    // MARK: - 控制器生命周期

    override func viewDidLoad() {
        super.viewDidLoad()

        bgImageView.image    = backgroundImage

        let scale            = CGAffineTransformMakeScale(0, 0)
        let translation      = CGAffineTransformMakeTranslation(0, view.bounds.height)
        dialogView.transform = CGAffineTransformConcat(scale, translation)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0, options: nil, animations: {

            self.dialogView.transform = CGAffineTransformIdentity

        }, completion: nil)
    }
}