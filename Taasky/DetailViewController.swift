//
//  DetailViewController.swift
//  Taasky
//
//  Created by Audrey M Tam on 18/03/2015.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var menuItem: NSDictionary? {
        didSet {
            view.backgroundColor = UIColor(colorArray: menuItem?["colors"] as! NSArray)
            backgroundImageView?.image = UIImage(named: menuItem?["bigImage"] as! String)
        }
    }

    let hamburgerButton = HamburgerView(frame:
        CGRect(origin: CGPointZero, size: CGSize(width: 20, height: 20)))

    @IBOutlet private weak var backgroundImageView: UIImageView!

    // MARK: - 控制器方法

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController!.navigationBar.clipsToBounds = true // 去除导航栏下的细线.

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: hamburgerButton)

        // 由于是个 UIView, 所以自行添加轻击手势.
        // 之所以用 UIView 是因为用普通 UIBarButtonItem 或者 UIButton 包装版时按钮动画有问题.
        let tapGR = UITapGestureRecognizer(target: self, action: "hamburgerButtonAction")
        hamburgerButton.addGestureRecognizer(tapGR)
    }

    // MARK: - 汉堡按钮点击事件

    @objc private func hamburgerButtonAction() {
        // 开关左菜单.
        (navigationController?.parentViewController as! ContainerViewController)
            .hideOrShowMenu(animated: true)
    }
}