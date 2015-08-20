//
//  ContainerViewController.swift
//  Taasky
//
//  Created by 从今以后 on 15/8/20.
//  Copyright (c) 2015年 Ray Wenderlich. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {

    var menuItem: NSDictionary? {
        didSet {
            detailViewController.menuItem = menuItem

            if menuShowing { // 主要是避免第一次启动时重复开关菜单.
                hideOrShowMenu(animated: true)
            }
        }
    }

    private weak var detailViewController: DetailViewController!

    private var menuShowing = true // 左菜单当前是否显示.

    @IBOutlet private weak var scrollView: UIScrollView!

    @IBOutlet private weak var menuContainerView: UIView!

    // MARK: - 控制器方法

    override func viewDidLayoutSubviews() {
        menuContainerView.layer.anchorPoint.x = 1 // 修改锚点,使之绕右边界旋转.
        hideOrShowMenu(animated: false) // 启动完毕隐藏左菜单.在 viewDidLoad() 中隐藏会太早了没效果.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        // segue 连接后为 detailViewController 属性赋值.
        if segue.identifier == "DetailViewSegue" {
            detailViewController =
                (segue.destinationViewController as! UINavigationController).topViewController
                    as! DetailViewController
        }
    }

    // MARK: - 公共方法

    func hideOrShowMenu(#animated: Bool) {

        // 开关左菜单.
        let contentOffset =
            (menuShowing ? CGPoint(x: menuContainerView.bounds.width, y: 0) : CGPointZero)

        scrollView.setContentOffset(contentOffset, animated: animated)

        menuShowing = !menuShowing
    }

    // MARK: - 私有方法

    private func menuTransformForPercent(percent: CGFloat) -> CATransform3D {

        var identity             = CATransform3DIdentity
        identity.m34             = -1 / 1_000

        // 向内垂直屏幕.
        let angle                = CGFloat(-M_PI_2) * (1 - percent)
        let rotationTransform    = CATransform3DRotate(identity, angle, 0, 1, 0)

        // 不加这个水平方向会偏差宽度一半.
        let x                    = menuContainerView.bounds.width / 2
        let translationTransform = CATransform3DMakeTranslation(x, 0, 0)

        return CATransform3DConcat(rotationTransform, translationTransform)
    }
}

// MARK: - Scroll View 代理

extension ContainerViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(scrollView: UIScrollView) {

        // 拖动中根据百分比进行变换.
        let percent = 1 - scrollView.contentOffset.x / menuContainerView.bounds.width

        menuContainerView.alpha           = percent
        menuContainerView.layer.transform = menuTransformForPercent(percent)

        detailViewController.hamburgerButton.rotate(percent)
    }

    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        // 拖动结束时判断是否过半实现分页.
        menuShowing = (scrollView.contentOffset.x < menuContainerView.bounds.width / 2)
            
        targetContentOffset.memory.x = (menuShowing ? 0 : menuContainerView.bounds.width)
    }
}