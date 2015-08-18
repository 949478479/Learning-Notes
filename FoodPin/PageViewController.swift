//
//  PageViewController.swift
//  FoodPin
//
//  Created by 从今以后 on 15/8/18.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController {

    private let pageHeadings    = [ "Personalize", "Locate", "Discover" ]
    private let pageImages      = [ "homei", "mapintro", "fiveleaves" ]
    private let pageSubHeadings = [
        "Pin your favourite restaurants and create your own food guide",
        "Search and locate your favourite restaurant on Maps",
        "Find restaurants pinned by your friends and other foodies around the world" ]

    // MARK: - 初始化
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.whiteColor()

        dataSource = self

        setViewControllers([viewControllerAtIndex(0)!],
            direction: .Forward, animated: false, completion: nil)
    }

    // MARK: - 调整布局

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        for subview in view.subviews as! [UIView] {

            // 调整小圆点到屏幕顶部.
            if let pageControll = subview as? UIPageControl {

                pageControll.frame.origin.y                = 0
                pageControll.pageIndicatorTintColor        = UIColor.lightGrayColor()
                pageControll.currentPageIndicatorTintColor = UIColor.redColor()

                continue
            }

            // 将 scrollView 全屏化,默认底部会留出小圆点的37点高度.
            if let scrollView = subview as? UIScrollView {

                scrollView.frame.size.height = view.bounds.height

                continue
            }
        }
    }

    // MARK: - 过渡到下一页面

    func forwardFromIndex(index: Int) {

        if let pageContentVC = viewControllerAtIndex(index + 1) {

            setViewControllers([pageContentVC],
                direction: .Forward, animated: true, completion: nil)
        }
    }
}

extension PageViewController: UIPageViewControllerDataSource {

    private func viewControllerAtIndex(index: Int) -> PageContentViewController? {

        if index < 0 || index >= pageHeadings.count {
            return nil
        }

        if let pageContentVC = storyboard?.instantiateViewControllerWithIdentifier("PageContentVC")
            as? PageContentViewController {

            pageContentVC.index      = index
            pageContentVC.heading    = pageHeadings[index]
            pageContentVC.subHeading = pageSubHeadings[index]
            pageContentVC.imageFile  = pageImages[index]
            pageContentVC.isEnd      = (index == pageHeadings.count - 1)

            return pageContentVC
        }
        
        return nil
    }

    func pageViewController(pageViewController: UIPageViewController,
        viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {

        return viewControllerAtIndex((viewController as! PageContentViewController).index - 1)
    }

    func pageViewController(pageViewController: UIPageViewController,
        viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
            
        return viewControllerAtIndex((viewController as! PageContentViewController).index + 1)
    }

    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 3
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return (pageViewController.viewControllers[0] as! PageContentViewController).index
    }
}