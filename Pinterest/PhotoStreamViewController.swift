//
//  PhotoStreamViewController.swift
//  RWDevCon
//
//  Created by Mic Pringle on 26/02/2015.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit
import AVFoundation

class PhotoStreamViewController: UICollectionViewController {

    private let photos = Photo.allPhotos

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView!.backgroundColor = UIColor(patternImage: UIImage(named: "Pattern")!)
        collectionView!.contentInset    = UIEdgeInsets(top: 20, left: 8, bottom: 8, right: 8)

        (collectionViewLayout as! PinterestLayout).delegate = self
    }
}

// MARK: - UICollectionView 数据源

extension PhotoStreamViewController {

    override func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {

        return photos.count
    }

    override func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            "AnnotatedPhotoCell", forIndexPath: indexPath) as! AnnotatedPhotoCell

        cell.photo = photos[indexPath.item]

        return cell
    }
}

// MARK: - PinterestLayoutDelegate 代理

extension PhotoStreamViewController: PinterestLayoutDelegate {

    func collectionView(collectionView: UICollectionView,
        heightForPhotoAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {

        let aspectRatio  = photos[indexPath.item].image.size
        let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat.max)

        return AVMakeRectWithAspectRatioInsideRect(aspectRatio, boundingRect).height // 好用~
    }

    func collectionView(collectionView: UICollectionView,
        heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {

        // 这里宽度需要减去 storyboard 中为 label 两侧设置的约束各 4 点距离.
        let font = UIFont(name: "AvenirNext-Regular", size: 10)!
        let commentHeight = photos[indexPath.item].heightForComment(font, width: width - 8)

        // 根据 storyboard 中的约束,让标题高 17, 间距 4, 文本内容上下一共2个间距.
        return commentHeight + 4 * 2 + 17
    }
}