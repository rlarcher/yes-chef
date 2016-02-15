//
//  CategorySelectorViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/15.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

class CategorySelectorViewController: UITableViewController {
    
    var categories: [Category] = []
    var selectedRow: Int?
    
    var selectionBlock: (Category -> ())?
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let category = categories[indexPath.row]
        let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        cell.textLabel?.text = category.rawValue
        if (indexPath.row == selectedRow) {
            cell.accessoryType = .Checkmark
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
    case Dessert =    "dessert"
    case Appetizer =  "appetizer"
    case Bread =      "bread"
    case Breakfast =  "breakfast"
    case Drinks =     "drinks"
    case MainDish =   "main dish"
    case Salad =      "salad"
    case SideDish =   "side dish"
    case Soup =       "soup"
    case Marinade =   "marinade"
    case Other =      "other"
    
    static let orderedValues: [Category] = [
        All,
        Dessert,
        Appetizer,
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
        for category in Category.orderedValues {
            if text.lowercaseString.containsString(category.rawValue.lowercaseString) { // TODO: Improve how we make matches
                return category
            }
        }
        
        return nil
    }
}
