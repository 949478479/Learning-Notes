//
//  TableViewController.swift
//  PullRefresh
//
//  Created by 从今以后 on 15/9/1.
//  Copyright (c) 2015年 Appcoda. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    @IBAction func beginRefreshing() {
        refreshControl?.beginRefreshing()
    }

    @IBAction func endRefreshing() {
        refreshControl?.endRefreshing()
    }
}