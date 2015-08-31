//
//  InspirationsViewController.swift
//  RWDevCon
//
//  Created by Mic Pringle on 02/03/2015.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit

class InspirationsViewController: UICollectionViewController {

    private let inspirations = Inspiration.allInspirations()

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(patternImage: UIImage(named: "Pattern")!)
        collectionView!.decelerationRate = UIScrollViewDecelerationRateFast // 惯性滚动时更快减速到静止.
    }
}

// MARK: - UICollectionViewDataSource 方法

extension InspirationsViewController {

    override func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
        return inspirations.count
    }

    override func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("InspirationCell",
            forIndexPath: indexPath) as! InspirationCell
        cell.inspiration = inspirations[indexPath.item]
        return cell
    }
}

// MARK: - UICollectionViewDelegate 方法

extension InspirationsViewController {

    override func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let ultravisualLayout = collectionView.collectionViewLayout as! UltravisualLayout
        let yOffset = CGFloat(indexPath.item) * ultravisualLayout.dragOffset
        collectionView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: true)
    }
}