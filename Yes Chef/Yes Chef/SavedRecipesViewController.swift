//
//  SavedRecipesViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

class SavedRecipesViewController: UITableViewController, UISearchResultsUpdating
{
    var selectionBlock: (Recipe -> ())?
    
    override func viewDidLoad()
    {
        searchController = UISearchController(searchResultsController: nil)
        
        tableView.tableHeaderView = searchController?.searchBar
    }
    
    deinit {
        searchController?.view.removeFromSuperview() // Required to avoid warning when dismissing this VC: "Attempting to load the view of a view controller while it is deallocating is not allowed and may result in undefined behavior"
    }
    
    // MARK: UISearchResultsUpdating Protocol Methods
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        // TODO
    }
    
    private var searchController: UISearchController?
}

class RecipeCell: UITableViewCell
{
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var recipeNameLabel: UILabel!
    @IBOutlet var preparationTimeLabel: UILabel!
    @IBOutlet var ingredientCountLabel: UILabel!
    @IBOutlet var caloriesLabel: UILabel!
}
