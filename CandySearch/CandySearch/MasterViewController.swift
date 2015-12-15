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

class MasterViewController: UITableViewController {

    // MARK: - Properties
    private var _detailViewController: DetailViewController? = nil
    private let _candies = [
        Candy(category:"Chocolate", name:"Chocolate Bar"),
        Candy(category:"Chocolate", name:"Chocolate Chip"),
        Candy(category:"Chocolate", name:"Dark Chocolate"),
        Candy(category:"Hard", name:"Lollipop"),
        Candy(category:"Hard", name:"Candy Cane"),
        Candy(category:"Hard", name:"Jaw Breaker"),
        Candy(category:"Other", name:"Caramel"),
        Candy(category:"Other", name:"Sour Chew"),
        Candy(category:"Other", name:"Gummi Bear"),
    ]
    private let _searchController = UISearchController(searchResultsController: nil)
    private var _filteredCandies = [Candy]()

    // MARK: - View Setup

    override func viewDidLoad() {
        super.viewDidLoad()

        if let splitViewController = splitViewController {
            let navController = splitViewController.viewControllers.last as! UINavigationController
            _detailViewController = navController.topViewController as? DetailViewController
        }

        _configureSearchController()
    }

    override func viewWillAppear(animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail", let indexPath = tableView.indexPathForSelectedRow {
            let candy = searching ? _filteredCandies[indexPath.row] : _candies[indexPath.row]
            let navController = segue.destinationViewController as! UINavigationController
            let controller = navController.topViewController as! DetailViewController
            controller.detailCandy = candy
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
}

// MARK: - Table View
extension MasterViewController {

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searching ? _filteredCandies.count : _candies.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let candy = searching ? _filteredCandies[indexPath.row] : _candies[indexPath.row]

        cell.textLabel!.text = candy.name
        cell.detailTextLabel!.text = candy.category
        
        return cell
    }
}

// MARK: - UISearchBarDelegate
extension MasterViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        _filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

// MARK: - UISearchResultsUpdating
extension MasterViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        _filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

// MARK: - Private
private extension MasterViewController {

    func _configureSearchController() {
        _searchController.searchResultsUpdater = self
        _searchController.dimsBackgroundDuringPresentation = false
        _searchController.searchBar.scopeButtonTitles = ["All", "Chocolate", "Hard", "Other"]
        _searchController.searchBar.delegate = self
        definesPresentationContext = true
        tableView.tableHeaderView = _searchController.searchBar
    }

    func _filterContentForSearchText(searchText: String, scope: String = "All") {
        _filteredCandies = _candies.filter {
            let nameMatch = $0.name.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
            if nameMatch == true {
                return scope != "All" ? scope == $0.category : true
            }
            return false
        }
        tableView.reloadData()
    }

    var searching: Bool {
        return _searchController.active && !_searchController.searchBar.text!.isEmpty
    }
}
