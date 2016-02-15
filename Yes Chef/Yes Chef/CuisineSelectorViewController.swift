//
//  CuisineSelectorViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/15.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

class CuisineSelectorViewController: UITableViewController {
    
    var cuisines: [Cuisine] = []
    var selectedRow: Int?
    
    var selectionBlock: (Cuisine -> ())?
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cuisine = cuisines[indexPath.row]
        let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        cell.textLabel?.text = cuisine.rawValue
        if (indexPath.row == selectedRow) {
            cell.accessoryType = .Checkmark
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

enum Cuisine: String
{
    case All =              "All Cuisines"
    case Afghan =           "Afghan"
    case African =          "African"
    case American =         "American"
    case AmericanSouth =    "American-South"
    case Asian =            "Asian"
    case Australian =       "Australian"
    case Brazilian =        "Brazilian"
    case Cajun =            "Cajun"
    case Canadian =         "Canadian"
    case Caribbean =        "Caribbean"
    case Chinese =          "Chinese"
    case Croatian =         "Croatian"
    case Cuban =            "Cuban"
    case Dessert =          "Dessert"
    case EasternEuropean =  "Eastern European"
    case English =          "English"
    case French =           "French"
    case German =           "German"
    case Greek =            "Greek"
    case Hawaiian =         "Hawaiian"
    case Hungarian =        "Hungarian"
    case India =            "India"
    case Indian =           "Indian"
    case Irish =            "Irish"
    case Japanese =         "Japanese"
    case Jewish =           "Jewish"
    case Korean =           "Korean"
    case Latin =            "Latin"
    case Mediterranean =    "Mediterranean"
    case Mexican =          "Mexican"
    case MiddleEastern =    "Middle Eastern"
    case Moroccan =         "Moroccan"
    case Polish =           "Polish"
    case Russian =          "Russian"
    case Scandanavian =     "Scandanavian"  // [sic], from docs
    case Seafood =          "Seafood"
    case Southern =         "Southern"
    case Southwestern =     "Southwestern"
    case Spanish =          "Spanish"
    case TexMex =           "Tex-Mex"
    case Thai =             "Thai"
    case Vegan =            "Vegan"
    case Vegetarian =       "Vegetarian"
    case Vietnamese =       "Vietnamese"
    
    static let orderedValues: [Cuisine] = [
        All,
        Afghan,
        African,
        American,
        AmericanSouth,
        Asian,
        Australian,
        Brazilian,
        Cajun,
        Canadian,
        Caribbean,
        Chinese,
        Croatian,
        Cuban,
        Dessert,
        EasternEuropean,
        English,
        French,
        German,
        Greek,
        Hawaiian,
        Hungarian,
        India,
        Indian,
        Irish,
        Japanese,
        Jewish,
        Korean,
        Latin,
        Mediterranean,
        Mexican,
        MiddleEastern,
        Moroccan,
        Polish,
        Russian,
        Scandanavian,
        Seafood,
        Southern,
        Southwestern,
        Spanish,
        TexMex,
        Thai,
        Vegan,
        Vegetarian,
        Vietnamese
    ]
    
    static func cuisineFoundInText(text: String) -> Cuisine?
    {
        for cuisine in Cuisine.orderedValues {
            if text.lowercaseString.containsString(cuisine.rawValue.lowercaseString) { // TODO: Improve how we make matches
                return cuisine
            }
        }
        
        return nil
    }
}
