//
//  ViewController.swift
//  CurveRefreshControl
//
//  Created by 从今以后 on 15/11/28.
//  Copyright © 2015年 从今以后. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    var curveRefreshView = CurveRefreshControl()

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.addSubview(curveRefreshView)
        curveRefreshView.refreshingHandler = {
            print("刷新啦~")
        }
    }
}
