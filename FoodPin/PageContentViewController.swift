//
//  PageContentViewController.swift
//  FoodPin
//
//  Created by 从今以后 on 15/8/18.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

import UIKit

class PageContentViewController: UIViewController {

    var index = 0
    var isEnd = false
    var heading: String!
    var imageFile: String!
    var subHeading: String!

    @IBOutlet private weak var headingLabel: UILabel!
    @IBOutlet private weak var subHeadingLabel: UILabel!
    @IBOutlet private weak var contentImageView: UIImageView!
    @IBOutlet private weak var getStartedButton: UIButton!
    @IBOutlet private weak var forwardButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        headingLabel.text       = heading
        subHeadingLabel.text    = subHeading
        forwardButton.hidden    = isEnd
        getStartedButton.hidden = !isEnd
        contentImageView.image  = UIImage(named: imageFile)
    }

    @IBAction private func close(sender: AnyObject) {
            
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: hasViewedWalkthrough)

        AppDelegate.sharedAppDelegate().window?.rootViewController =
            storyboard?.instantiateViewControllerWithIdentifier("TabBarController")
                as? UIViewController
    }

    @IBAction private func nextScreen(sender: AnyObject) {
        (parentViewController as! PageViewController).forwardFromIndex(index)
    }
}