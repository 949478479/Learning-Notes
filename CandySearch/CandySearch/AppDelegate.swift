/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    func application(application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        let splitViewController = window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers.last as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem
            = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self

        UISearchBar.appearance().tintColor = UIColor.whiteColor()
        UISearchBar.appearance().barTintColor = UIColor.candyGreen()
        UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).tintColor
            = UIColor.candyGreen()

        return true
    }

    // MARK: - Split view
    func splitViewController(splitViewController: UISplitViewController,
        collapseSecondaryViewController secondaryViewController: UIViewController,
        ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {

        if let
            secondaryAsNavController = secondaryViewController as? UINavigationController,
            topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController
            where topAsDetailController.detailCandy != nil {
                return false
        }
        return true
    }
}

extension UIColor {
    static func candyGreen() -> UIColor {
        return UIColor(red: 67.0/255.0, green: 205.0/255.0, blue: 135.0/255.0, alpha: 1.0)
    }
}
