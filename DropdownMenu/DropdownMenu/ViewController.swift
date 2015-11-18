//
//  ViewController.swift
//  DropdownMenu
//
//  Created by 从今以后 on 15/11/11.
//  Copyright © 2015年 从今以后. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let dropdownMenu = DropdownMenu.dropdownMenu()

        dropdownMenu.items = ["Most Popular", "Latest", "Trending", "Nearest", "Top Picks"]
        dropdownMenu.selectedItem = 3
        dropdownMenu.didSelectItemAtIndexHandler = {
            print("selectedItem: \($0), index: \($1)")
        }

        dropdownMenu.menuWidth = 300
        dropdownMenu.menuTextFont = UIFont.boldSystemFontOfSize(15)
        dropdownMenu.menuTextColor = UIColor.whiteColor()
        dropdownMenu.menuTitleColor = UIColor.whiteColor()
        dropdownMenu.separatorColor = UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1.0)
        dropdownMenu.menuCheckmarkColor = UIColor.whiteColor()
        dropdownMenu.menuBackgroundColor = navigationController!.navigationBar.barTintColor

        navigationItem.titleView = dropdownMenu
    }
}
