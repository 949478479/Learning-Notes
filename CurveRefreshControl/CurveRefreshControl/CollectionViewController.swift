//
//  CollectionViewController.swift
//  CurveRefreshControl
//
//  Created by 从今以后 on 15/12/3.
//  Copyright © 2015年 从今以后. All rights reserved.
//

import UIKit

class CollectionViewController: UICollectionViewController {

    var refreshControl = CurveRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.refreshingHandler = {
            print("刷了个新~")
        }
        collectionView?.addSubview(refreshControl)
    }
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
    }
}
