//
//  CollectionViewController.swift
//  CollectionViewLayoutDemo
//
//  Created by 从今以后 on 15/8/9.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"
private let kImageCount = 20

private func randomInRange(range: Range<Int>) -> Int {
    let count = UInt32(range.endIndex - range.startIndex)
    return Int(arc4random_uniform(count)) + range.startIndex
}

class CollectionViewController: UICollectionViewController {

    private var itemCount: Int = kImageCount
    private var imageIndexes: [Int] = []

    @IBOutlet
    private weak var lineLayout: LineLayout!

    @IBOutlet
    private weak var circleLayout: CircleLayout!

    @objc
    private func addOrDeleteItemAction(sender: UIStepper) {

        struct ValueRecorder { static var value: Double = Double(kImageCount) }

        if sender.value > ValueRecorder.value {
            ++itemCount
            let randomItem = randomInRange(0..<itemCount)
            imageIndexes.insert(randomInRange(0..<kImageCount), atIndex: randomItem)
            collectionView?.insertItemsAtIndexPaths([NSIndexPath(forItem: randomItem, inSection: 0)])
        }
        else if sender.value < ValueRecorder.value {
            --itemCount
            let randomItem = randomInRange(0..<itemCount)
            imageIndexes.removeAtIndex(randomItem)
            collectionView?.deleteItemsAtIndexPaths([NSIndexPath(forItem: randomItem, inSection: 0)])
        }

        ValueRecorder.value = sender.value
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = {
            let stepper = UIStepper()
            stepper.value = Double(kImageCount)
            stepper.autorepeat = false
            stepper.addTarget(self, action: "addOrDeleteItemAction:", forControlEvents: .ValueChanged)
            return stepper
        }()

        for index in 0..<kImageCount {
            imageIndexes.append(index)
        }
    }

    @IBAction
    private func didTapCollectionView(sender: UITapGestureRecognizer) {

        // 环形布局不响应手势点击事件,只响应 cell 的点击事件.
        if collectionView?.collectionViewLayout is CircleLayout { return }

        // 点击不是 cell 则切换回环形布局.
        for visibleCell in collectionView?.visibleCells() as! [UICollectionViewCell] {
            if CGRectContainsPoint(visibleCell.bounds, sender.locationInView(visibleCell)) {
                return
            }
        }

        collectionView!.setCollectionViewLayout(circleLayout, animated: true) { _ in
            navigationItem.titleView?.userInteractionEnabled = true
        }
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
        cell.imageView.image = UIImage(named: "\(imageIndexes[indexPath.item])")
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        // 线形布局 下自动滚到被点击的 cell 处.
        if (collectionView.collectionViewLayout is LineLayout) {
            collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
        }
        // 环形布局下点击 cell 切换至 线形布局,并滚动至点击的 cell.
        else {
            navigationItem.titleView?.userInteractionEnabled = false // 线形布局没做交互处理...

            lineLayout.selectedIndexPath = indexPath
            collectionView.setCollectionViewLayout(lineLayout, animated: true)
        }
    }
}