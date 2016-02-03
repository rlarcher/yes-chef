//
//  RecipeIngredientsViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

class RecipeIngredientsViewController: UITableViewController
{
    @IBOutlet var servingsCountLabel: UILabel!
}

class IngredientCell: UITableViewCell
{
    @IBOutlet var quantityUnitsLabel: UILabel!
    @IBOutlet var ingredientNameLabel: UILabel!
    
    @IBAction func addToGroceryListButtonTapped(sender: AnyObject)
    {
        // TODO
    }
}
