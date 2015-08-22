//
//  MenuViewController.swift
//  Taasky
//
//  Created by Audrey M Tam on 18/03/2015.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit

class MenuViewController: UITableViewController {

    lazy var menuItems: NSArray = {
        let path = NSBundle.mainBundle().pathForResource("MenuItems", ofType: "plist")
        return NSArray(contentsOfFile: path!)!
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 调整菜单项高度,从而刚好能显示整数个菜单项.上舍入主要为了像素对齐.
        tableView.rowHeight = round( (tableView.bounds.height - 64) / CGFloat(menuItems.count) + 0.5)
        
        // 加上这句,否则导航栏下会有一条细线.
        navigationController!.navigationBar.clipsToBounds = true

        // 选中第一个菜单项.
        (navigationController?.parentViewController as! ContainerViewController).menuItem =
            menuItems[0] as? NSDictionary
    }
}

// MARK: - Table View 数据源

extension MenuViewController: UITableViewDataSource {

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("MenuItemCell") as! MenuItemCell

        let menuItem = menuItems[indexPath.row] as! NSDictionary

        cell.configureForMenuItem(menuItem)

        return cell
    }
}

// MARK: - Table View 代理

extension MenuViewController: UITableViewDelegate {

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let menuItem = menuItems[indexPath.row] as! NSDictionary
        (navigationController?.parentViewController as! ContainerViewController).menuItem = menuItem
    }
}