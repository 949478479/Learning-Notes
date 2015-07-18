//
//  MasterViewController.swift
//  MagicMove
//
//  Created by 从今以后 on 15/7/18.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

import UIKit

let reuseIdentifier = "Role"

class MasterViewController: UICollectionViewController {

    var selectedCell: RoleCell!
    @IBOutlet var flowLayout: UICollectionViewFlowLayout!

    override func viewDidLoad() {
        super.viewDidLoad()

        flowLayout.itemSize = {
            let inset = self.flowLayout.sectionInset.left + self.flowLayout.sectionInset.right
            let width = (self.view.bounds.width - inset - self.flowLayout.minimumInteritemSpacing) / 2
            return CGSize(width: width, height: width * 3 / 4 + 36)
        }()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        navigationController?.delegate = self
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let toVC  = segue.destinationViewController as! DetailViewController
        let index = collectionView!.indexPathForCell(selectedCell)!.item
        toVC.role = roles[index]
    }
}

// MARK: - UICollectionViewDataSource

extension MasterViewController {
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return roles.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! RoleCell
        cell.configureForRole(roles[indexPath.item])
        return cell
    }

    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as! RoleCell
        return true
    }
}

extension MasterViewController: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PushAnimationController()
    }
}