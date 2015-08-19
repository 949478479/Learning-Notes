//
//  AboutViewController.swift
//  FoodPin
//
//  Created by 从今以后 on 15/8/19.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

import UIKit
import MessageUI

class AboutViewController: UIViewController {

    // MARK: - IBAction

    @IBAction func sendEmail(sender: UIButton) {

        if !MFMailComposeViewController.canSendMail() { return }

        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["support@appcoda.com"])
        composer.navigationBar.tintColor = UIColor.whiteColor()

        presentViewController(composer, animated: true) {
            UIApplication.sharedApplication().statusBarStyle = .LightContent // 不加这个状态栏是黑色的.
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate

extension AboutViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(controller: MFMailComposeViewController!,
        didFinishWithResult result: MFMailComposeResult, error: NSError!) {

        switch result.value {
        case MFMailComposeResultCancelled.value: println("Cancelled")
        case MFMailComposeResultSaved.value:     println("Saved")
        case MFMailComposeResultSent.value:      println("Sent")
        case MFMailComposeResultFailed.value:    println("Failed - \(error)")
        default: break
        }

        dismissViewControllerAnimated(true, completion: nil)
    }
}