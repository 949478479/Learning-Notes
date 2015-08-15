//
//  ShareViewController.swift
//  FoodPin
//
//  Created by 从今以后 on 15/8/16.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

import UIKit

class ShareViewController: UIViewController {

    var backgroundImage: UIImage!

    @IBOutlet private weak var emailButton: UIButton!
    @IBOutlet private weak var twitterButton: UIButton!
    @IBOutlet private weak var messageButton: UIButton!
    @IBOutlet private weak var facebookButton: UIButton!
    @IBOutlet private weak var bgImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        bgImageView.image        = backgroundImage

        let translateDown        = CGAffineTransformMakeTranslation(0, view.bounds.height)
        facebookButton.transform = translateDown
        messageButton.transform  = translateDown

        let translateUp          = CGAffineTransformMakeTranslation(0, -view.bounds.height)
        twitterButton.transform  = translateUp
        emailButton.transform    = translateUp
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animateWithDuration(0.7, delay: 0.0, usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0, options: nil, animations: {

            self.facebookButton.transform = CGAffineTransformIdentity
            self.emailButton.transform    = CGAffineTransformIdentity

        }, completion: nil)

        UIView.animateWithDuration(0.7, delay: 0.5, usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0, options: nil, animations: {

            self.twitterButton.transform = CGAffineTransformIdentity
            self.messageButton.transform = CGAffineTransformIdentity

        }, completion: nil)
    }

    // MARK: - 导航控制

    @IBAction private func close(segue: UIStoryboardSegue) { }
}