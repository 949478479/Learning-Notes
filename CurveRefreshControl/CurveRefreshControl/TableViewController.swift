//
//  TableViewController.swift
//  CurveRefreshControl
//
//  Created by 从今以后 on 15/11/29.
//  Copyright © 2015年 从今以后. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    var curveRefreshControl = CurveRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        curveRefreshControl.refreshingHandler = {
            print("刷新中~~~")
        }
        tableView.addSubview(curveRefreshControl)
    }

    @IBAction func didBeginRefreshing(sender: CurveRefreshControl) {
//        print("didBeginRefreshing -------")
//
//        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
//        dispatch_after(when, dispatch_get_main_queue()) {
//            sender.endRefreshing()
//        }
    }

    @IBAction func manualRefresh(sender: UIBarButtonItem) {
        if curveRefreshControl.refreshing {
            curveRefreshControl.endRefreshing()
        } else {
            curveRefreshControl.beginRefreshing()
        }
    }
}
