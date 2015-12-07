//
//  ViewController.swift
//  SFSafariViewControllerDemo
//
//  Created by 从今以后 on 15/12/7.
//  Copyright © 2015年 从今以后. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController, SFSafariViewControllerDelegate {

    @IBAction func openButtonDidTapped(sender: UIButton) {
        let url = NSURL(string: "https://baidu.com")!
        let safariVC = SFSafariViewController(URL: url)
        showDetailViewController(safariVC, sender: nil)
    }
}

