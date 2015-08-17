//
//  RestaurantViewController.swift
//  FoodPin
//
//  Created by 从今以后 on 15/8/15.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

import UIKit
import CoreData

class RestaurantViewController: UITableViewController {

    private let identifier = "RestaurantCell"

    private var restaurants:[Restaurant] = [
        Restaurant(name: "Cafe Deadend", type: "Coffee & Tea Shop", location: "G/F, 72 Po Hing Fong, Sheung Wan, Hong Kong", image: "cafedeadend", thumbnail: "cafedeadend_thumbnail", isVisited: false),
        Restaurant(name: "Homei", type: "Cafe", location: "Shop B, G/F, 22-24A Tai Ping San Street SOHO, Sheung Wan, Hong Kong", image: "homei", thumbnail: "homei_thumbnail", isVisited: false),
        Restaurant(name: "Teakha", type: "Tea House", location: "Shop B, 18 Tai Ping Shan Road SOHO, Sheung Wan, Hong Kong", image: "teakha", thumbnail: "teakha_thumbnail", isVisited: false),
        Restaurant(name: "Cafe loisl", type: "Austrian / Causual Drink", location: "Shop B, 20 Tai Ping Shan Road SOHO, Sheung Wan, Hong Kong", image: "cafeloisl", thumbnail: "cafeloisl_thumbnail", isVisited: false),
        Restaurant(name: "Petite Oyster", type: "French", location: "24 Tai Ping Shan Road SOHO, Sheung Wan, Hong Kong", image: "petiteoyster", thumbnail: "petiteoyster_thumbnail", isVisited: false),
        Restaurant(name: "For Kee Restaurant", type: "Bakery", location: "Shop J-K., 200 Hollywood Road, SOHO, Sheung Wan, Hong Kong", image: "forkeerestaurant", thumbnail: "forkeerestaurant_thumbnail", isVisited: false),
        Restaurant(name: "Po's Atelier", type: "Bakery", location: "G/F, 62 Po Hing Fong, Sheung Wan, Hong Kong", image: "posatelier", thumbnail: "posatelier_thumbnail", isVisited: false),
        Restaurant(name: "Bourke Street Backery", type: "Chocolate", location: "633 Bourke St Sydney New South Wales 2010 Surry Hills", image: "bourkestreetbakery", thumbnail: "bourkestreetbakery_thumbnail", isVisited: false),
        Restaurant(name: "Haigh's Chocolate", type: "Cafe", location: "412-414 George St Sydney New South Wales", image: "haighschocolate", thumbnail: "haighschocolate_thumbnail", isVisited: false),
        Restaurant(name: "Palomino Espresso", type: "American / Seafood", location: "Shop 1 61 York St Sydney New South Wales", image: "palominoespresso", thumbnail: "palominoespresso_thumbnail", isVisited: false),
        Restaurant(name: "Upstate", type: "American", location: "95 1st Ave New York, NY 10003", image: "upstate", thumbnail: "upstate_thumbnail", isVisited: false),
        Restaurant(name: "Traif", type: "American", location: "229 S 4th St Brooklyn, NY 11211", image: "traif", thumbnail: "traif_thumbnail", isVisited: false),
        Restaurant(name: "Graham Avenue Meats", type: "Breakfast & Brunch", location: "445 Graham Ave Brooklyn, NY 11211", image: "grahamavenuemeats", thumbnail: "grahamavenuemeats_thumbnail", isVisited: false),
        Restaurant(name: "Waffle & Wolf", type: "Coffee & Tea", location: "413 Graham Ave Brooklyn, NY 11211", image: "wafflewolf", thumbnail: "wafflewolf_thumbnail", isVisited: false),
        Restaurant(name: "Five Leaves", type: "Coffee & Tea", location: "18 Bedford Ave Brooklyn, NY 11222", image: "fiveleaves", thumbnail: "fiveleaves_thumbnail", isVisited: false),
        Restaurant(name: "Cafe Lore", type: "Latin American", location: "Sunset Park 4601 4th Ave Brooklyn, NY 11220", image: "cafelore", thumbnail: "cafelore_thumbnail", isVisited: false),
        Restaurant(name: "Confessional", type: "Spanish", location: "308 E 6th St New York, NY 10003", image: "confessional", thumbnail: "confessional_thumbnail", isVisited: false),
        Restaurant(name: "Barrafina", type: "Spanish", location: "54 Frith Street London W1D 4SL United Kingdom", image: "barrafina", thumbnail: "barrafina_thumbnail", isVisited: false),
        Restaurant(name: "Donostia", type: "Spanish", location: "10 Seymour Place London W1H 7ND United Kingdom", image: "donostia", thumbnail: "donostia_thumbnail", isVisited: false),
        Restaurant(name: "Royal Oak", type: "British", location: "2 Regency Street London SW1P 4BZ United Kingdom", image: "royaloak", thumbnail: "royaloak_thumbnail", isVisited: false),
        Restaurant(name: "Thai Cafe", type: "Thai", location: "22 Charlwood Street London SW1V 2DY Pimlico", image: "thaicafe", thumbnail: "thaicafe_thumbnail", isVisited: false)]
/* FIXME:
    lazy var fetchedResultsController: NSFetchedResultsController = {

        let fetchRequest = NSFetchRequest(entityName: "Restaurant")

        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: AppDelegate.sharedAppDelegate().managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: "Restaurants")

        fetchedResultsController.delegate = self

        var error: NSError?

        if !fetchedResultsController.performFetch(&error) {
            println(error)
        }

        return fetchedResultsController
    }() */

    // MARK: - 导航控制

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "ShowRestaurantDetail" {

            if let
                indexPath = tableView.indexPathForSelectedRow(),
                restaurantDetailVC = segue.destinationViewController as? RestaurantDetailViewController
            {/* FIXME:
                restaurantDetailVC.restaurant =
                    fetchedResultsController.objectAtIndexPath(indexPath) as! Restaurant */
                restaurantDetailVC.restaurant = restaurants[indexPath.row]
            }
        }
    }

    @IBAction private func unwindToHomeScreen(segue: UIStoryboardSegue) { }
}

// MARK: - TableView 数据源

extension RestaurantViewController {

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
/* FIXME:
        return (fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo).numberOfObjects */
        return restaurants.count
    }

    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
            as! RestaurantCell
/* FIXME:
        let restaurant = fetchedResultsController.objectAtIndexPath(indexPath) as! Restaurant */
        let restaurant = restaurants[indexPath.row]

        cell.nameLabel.text            = restaurant.name
        cell.locationLabel.text        = restaurant.location
        cell.typeLabel.text            = restaurant.type
/* FIXME:
        cell.thumbnailImageView.image  = UIImage(data: restaurant.thumbnail) */
        cell.thumbnailImageView.image  = UIImage(named: restaurant.thumbnail)
        cell.favorIconImageView.hidden = !restaurant.isVisited.boolValue

        return cell
    }
}

// MARK: - TableView 代理

extension RestaurantViewController {

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    override func tableView(tableView: UITableView, commitEditingStyle
        editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) { }

    override func tableView(tableView: UITableView,
        editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {

        let shareAction = UITableViewRowAction(style: .Default, title: "Share") { _, indexPath in

            let twitterAction  = UIAlertAction(title: "Twitter", style: .Default, handler: nil)
            let facebookAction = UIAlertAction(title: "Facebook", style: .Default, handler: nil)
            let emailAction    = UIAlertAction(title: "Emali", style: .Default, handler: nil)
            let cancelAction   = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)

            let shareMenu = UIAlertController(
                title: nil,
                message: "Share using",
                preferredStyle: .ActionSheet)

            shareMenu.addAction(twitterAction)
            shareMenu.addAction(facebookAction)
            shareMenu.addAction(emailAction)
            shareMenu.addAction(cancelAction)

            self.presentViewController(shareMenu, animated: true, completion: nil)
        }
        shareAction.backgroundColor = UIColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 1)

        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete") { _, indexPath in

/* FIXME:
            let restaurant = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Restaurant

            let appDelegate = AppDelegate.sharedAppDelegate()

            appDelegate.managedObjectContext.deleteObject(restaurant)

            appDelegate.saveContext() */

            self.restaurants.removeAtIndex(indexPath.row)

            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        deleteAction.backgroundColor = UIColor(red: 237/255, green: 75/255, blue: 27/255, alpha: 1)
        
        return [deleteAction, shareAction]
    }
}

// MARK: - FetchedResultsController 代理
/* FIXME:
extension RestaurantViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController,
      didChangeObject anObject: AnyObject,
         atIndexPath indexPath: NSIndexPath?,
            forChangeType type: NSFetchedResultsChangeType,
                  newIndexPath: NSIndexPath?)
    {
        switch type
        {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)

        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)

        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)

        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
}*/