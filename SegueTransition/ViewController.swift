//
//  ViewController.swift
//  SegueTransition
//
//  Created by 从今以后 on 15/7/20.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func unwindingSegueAction(sender: UIStoryboardSegue) { }

    override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
        return UnwindingSegue(identifier: "UnwindingSegue", source: fromViewController, destination: toViewController, performHandler: {})
    }
}