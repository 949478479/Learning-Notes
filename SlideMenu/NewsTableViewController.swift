//
//  NewsTableViewController.swift
//  SlideMenu
//
//  Created by Simon Ng on 7/2/15.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import UIKit

class NewsTableViewController: UITableViewController {

    private let menuTransitionManager = MenuTransitionManager()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Home"

        tableView.estimatedRowHeight = 302
        tableView.rowHeight = UITableViewAutomaticDimension

        menuTransitionManager.delegate = self
    }

    // MARK: - Segue

    @IBAction func unwind(segue: UIStoryboardSegue) {
        title = (segue.sourceViewController as! MenuTableViewController).currentItem
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        let menuTableViewController = segue.destinationViewController as! MenuTableViewController
        menuTableViewController.currentItem = title!
        menuTableViewController.transitioningDelegate = menuTransitionManager
    }
}

// MARK: - MenuTransitionManager 代理

extension NewsTableViewController: MenuTransitionManagerDelegate {

    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - Table view data source

extension NewsTableViewController {

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            as! NewsTableViewCell

        if indexPath.row == 0 {

            cell.postTitle.text        = "Red Lights, Lisbon"
            cell.postAuthor.text       = "TOM EVERSLEY (@tomeversley)"
            cell.postImageView.image   = UIImage(named: "red-lights-lisbon")
            cell.authorImageView.image = UIImage(named: "appcoda-300")

        } else if indexPath.row == 1 {

            cell.postTitle.text        = "Val Thorens, France"
            cell.postAuthor.text       = "BARA ART (bara-art.com)"
            cell.postImageView.image   = UIImage(named: "val-throrens-france")
            cell.authorImageView.image = UIImage(named: "appcoda-300")

        } else if indexPath.row == 2 {

            cell.postTitle.text        = "Summer Beach Huts, England"
            cell.postAuthor.text       = "TOM EVERSLEY (@tomeversley)"
            cell.postImageView.image   = UIImage(named: "summer-beach-huts")
            cell.authorImageView.image = UIImage(named: "appcoda-300")

        } else {

            cell.postTitle.text        = "Taxis, NYC"
            cell.postAuthor.text       = "TOM EVERSLEY (@tomeversley)"
            cell.postImageView.image   = UIImage(named: "taxis-nyc")
            cell.authorImageView.image = UIImage(named: "appcoda-300")
        }

        return cell
    }
}