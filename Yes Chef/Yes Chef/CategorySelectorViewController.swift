//
//  CategorySelectorViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/15.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

class CategorySelectorViewController: UITableViewController {
    
    var categories = Category.orderedValues
    var selectedRow: Int?
    
    var selectionBlock: (Category -> ())?
    
    override func viewDidAppear(animated: Bool)
    {
        tableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedRow ?? 0, inSection: 0), animated: true, scrollPosition: .None)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let category = categories[indexPath.row]
        let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        cell.textLabel?.text = category.rawValue
        cell.textLabel?.textAlignment = .Center
        if (indexPath.row == selectedRow) {
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return categories.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        // update the checkmark UI
        let oldRow = selectedRow
        selectedRow = indexPath.row
        
        var pathsToRefresh = [indexPath]
        if let oldRow = oldRow where oldRow != indexPath.row {
            // Also refresh the old row, if it's not the same as the new row (avoid refreshing the same cell twice).
            pathsToRefresh.append(NSIndexPath(forRow: oldRow, inSection: 0))
        }
        
        tableView.reloadRowsAtIndexPaths(pathsToRefresh, withRowAnimation: .None)
        
        // notify client via the selection closure
        selectionBlock?(categories[indexPath.row])
    }
}

enum Category: String
{
    case All =        "All Categories"
    case Desserts =   "Desserts"    // NOTE: Differs from docs, which says "dessert" without the "s".
    case Appetizers = "Appetizers"  // NOTE: Differs from docs, which says "appetizer" without the "s".
    case Bread =      "Bread"
    case Breakfast =  "Breakfast"
    case Drinks =     "Drinks"
    case MainDish =   "Main Dish"
    case Salad =      "Salad"
    case SideDish =   "Side Dish"
    case Soup =       "Soup"        // TODO: May actually be "Soups Stews and Chili", according to a regular BigOven search
    case Marinade =   "Marinade"    // TODO: May actually be "Marinades and Sauces", according to a regular BigOven search
    case Other =      "Other"
    
    static let orderedValues: [Category] = [
        All,
        Desserts,
        Appetizers,
        Bread,
        Breakfast,
        Drinks,
        MainDish,
        Salad,
        SideDish,
        Soup,
        Marinade,
        Other
    ]
    
    static func categoryFoundInText(text: String) -> Category?
    {
        let categoryNames = Category.orderedValues.map({ $0.rawValue })
        if let index = Utils.fuzzyIndexOfItemWithName(text, inList: categoryNames) {
            return Category.orderedValues[index]
        }
        
        return nil
    }
}
