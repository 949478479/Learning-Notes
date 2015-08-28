//
//  CollectionViewController.swift
//  CircularCollectionView
//
//  Created by Rounak Jain on 10/05/15.
//  Copyright (c) 2015 Rounak Jain. All rights reserved.
//

import UIKit

class CollectionViewController: UICollectionViewController {

    private let reuseIdentifier = "Cell"

    private let images = NSBundle.mainBundle().pathsForResourcesOfType("png", inDirectory: "Images") as! [String]

    override func viewDidLoad() {
        super.viewDidLoad()

        let imageView = UIImageView(image: UIImage(named: "bg-dark.jpg"))
        imageView.contentMode = .ScaleAspectFill
        collectionView!.backgroundView = imageView
    }
}

// MARK: UICollectionViewDataSource

extension CollectionViewController {

    override func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            reuseIdentifier, forIndexPath: indexPath) as! CircularCollectionViewCell
        cell.imageName = images[indexPath.row]
        return cell
    }
}