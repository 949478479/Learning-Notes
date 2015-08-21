//
//  MenuTableViewController.swift
//  SlideMenu
//
//  Created by Simon Ng on 9/2/15.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {

    var currentItem = "Home"
    private let menuItems = ["Home", "News", "Tech", "Finance", "Reviews"]
}

// MARK: - Table view 数据源

extension MenuTableViewController {

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            as! MenuTableViewCell

        cell.titleLabel.text = menuItems[indexPath.row]
        cell.titleLabel.textColor =
            (menuItems[indexPath.row] == currentItem) ? UIColor.whiteColor() : UIColor.grayColor()

        return cell
    }
}

// MARK: - Table view 代理

extension MenuTableViewController {

    override func tableView(tableView: UITableView,
        willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {

        currentItem = menuItems[indexPath.row]

        return indexPath
    }
}