//
//  CuisineSelectorViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/15.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

// TODO: Good candidate for Generics?
class CuisineSelectorViewController: UITableViewController {
    
    var cuisines = Cuisine.orderedValues
    var selectedRow: Int?
    
    var selectionBlock: (Cuisine -> ())?
    
    override func viewDidAppear(animated: Bool)
    {
        tableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedRow ?? 0, inSection: 0), animated: true, scrollPosition: .None)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cuisine = cuisines[indexPath.row]
        let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        cell.textLabel?.text = cuisine.rawValue
        cell.textLabel?.textAlignment = .Center
        if (indexPath.row == selectedRow) {
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return cuisines.count
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
        selectionBlock?(cuisines[indexPath.row])
    }
}
