//
//  AddRestaurantViewController.swift
//  FoodPin
//
//  Created by 从今以后 on 15/8/17.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

import UIKit
import CoreData

func createThumbnailWithImage(var image: UIImage) -> UIImage {

    let size = CGSize(width: 60, height: 60)

    UIGraphicsBeginImageContextWithOptions(size, true, 0)

    image.drawInRect(CGRect(origin: CGPointZero, size: size))

    image = UIGraphicsGetImageFromCurrentImageContext()

    UIGraphicsEndImageContext()

    return image
}

class AddRestaurantViewController: UITableViewController {

    var restaurant: Restaurant!
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var typeTextField: UITextField!
    @IBOutlet private weak var locationTextField: UITextField!

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)
    }

    @IBAction private func saveAction(sender: UIBarButtonItem) {

        var errorField = ""

        if nameTextField.text.isEmpty {
            errorField = "name"
        } else if locationTextField.text.isEmpty {
            errorField = "location"
        } else if typeTextField.text.isEmpty {
            errorField = "type"
        }

        if !errorField.isEmpty {

            let alertController = UIAlertController(
                title: "Oops",
                message: "We can't proceed as you forget to fill in the restaurant " + errorField + ". All fields are mandatory.",
                preferredStyle: .Alert)

            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
            presentViewController(alertController, animated: true, completion: nil)

            return
        }
/* FIXME:
        let appDelegate = AppDelegate.sharedAppDelegate()
        
        let managedObjectContext = appDelegate.managedObjectContext

        let restaurant = NSEntityDescription.insertNewObjectForEntityForName("Restaurant",
            inManagedObjectContext: managedObjectContext) as! Restaurant

        restaurant.name      = nameTextField.text
        restaurant.type      = typeTextField.text
        restaurant.location  = locationTextField.text
        restaurant.image     = UIImagePNGRepresentation(imageView.image)
        restaurant.thumbnail = UIImagePNGRepresentation(createThumbnailWithImage(imageView.image!))
        restaurant.isVisited = yesButton.selected

        appDelegate.saveContext() */
        performSegueWithIdentifier("UnwindToHomeScreen", sender: self)
    }

    @IBAction private func updateIsVisited(sender: UIButton) {

        if sender.selected { return }

        sender.selected        = true
        sender.backgroundColor = UIColor(red: 235/255, green: 73/255, blue: 27/255, alpha: 1)

        let anotherButton             = (sender === yesButton ? noButton : yesButton)
        anotherButton.selected        = false
        anotherButton.backgroundColor = UIColor.lightGrayColor()
    }
}

// MARK: - TableView 代理

extension AddRestaurantViewController {

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if indexPath.row == 0 {

            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self

            presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
}

// MARK: - ImagePicker 代理

extension AddRestaurantViewController: UIImagePickerControllerDelegate {

    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {

        imageView.contentMode = .ScaleAspectFill
        imageView.image       = info[UIImagePickerControllerOriginalImage] as? UIImage

        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - NavigationController 代理

extension AddRestaurantViewController: UINavigationControllerDelegate {

    func navigationController(navigationController: UINavigationController,
        willShowViewController viewController: UIViewController, animated: Bool) {

        let selfNavigationBar = self.navigationController!.navigationBar
        let navigationBar     = navigationController.navigationBar

        navigationBar.tintColor           = selfNavigationBar.tintColor
        navigationBar.barTintColor        = selfNavigationBar.barTintColor
        navigationBar.titleTextAttributes = selfNavigationBar.titleTextAttributes
    }
}