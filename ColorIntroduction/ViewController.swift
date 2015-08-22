//
//  ViewController.swift
//  ColorIntroduction
//
//  Created by Marin Todorov on 7/9/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//  
//  Public domain "Prince frog" fairy tale taken from:
//  http://www.feedbooks.com/books?category=FBFIC010000
//
//  Public domain frog image
//  http://www.publicdomainpictures.net/view-image.php?image=57441&picture=frog-illustration
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!

    let story = "One fine evening a young princess put on her bonnet and clogs, and went out to take a walk by herself in a wood; and when she came to a cool spring of water, that rose in the midst of it, she sat herself down to rest a while.\n\nNow she had a golden ball in her hand, which was her favourite plaything; and she was always tossing it up into the air, and catching it again as it fell.\n\nAfter a time she threw it up so high that she missed catching it as it fell... \n\nAnd here our story begins ..."

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // 创建一个梯度图层.
        let gradient        = CAGradientLayer()
        gradient.frame      = view.bounds
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint   = CGPoint(x: 1, y: 1)
    }
}