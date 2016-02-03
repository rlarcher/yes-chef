//
//  SearchResultsViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

class SearchResultsViewController: UITableViewController
{
    func setRecipes(recipes: [Recipe], forSearchQuery query: String)
    {
        self.recipes = recipes
        self.query = query
    }
    
    // MARK: UITableViewDelegate Protocol Methods
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let index = indexPath.row
        if index < recipes.count {
            let recipe = recipes[index]
            presentRecipe(recipe)
        }
    }
    
    // MARK: UITableViewDataSource Protocol Methods
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let index = indexPath.row
        if
            let cell = tableView.dequeueReusableCellWithIdentifier("RecipeCell") as? RecipeCell
            where index < recipes.count
        {
            let recipe = recipes[index]
            cell.recipeNameLabel.text = recipe.name
            cell.thumbnailImageView.image = recipe.thumbnail
            cell.ratingLabel.text = String(recipe.rating)
            cell.preparationTimeLabel.text = String(recipe.preparationTime) // TODO: Format this
            cell.ingredientCountLabel.text = String(recipe.ingredients.count)
            cell.caloriesLabel.text = String(recipe.calories)
            
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return recipes.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    // MARK: Navigation Helpers
    
    private func presentRecipe(recipe: Recipe)
    {
        if let recipeTabBarController = storyboard?.instantiateViewControllerWithIdentifier("RecipeTabBarController") as? RecipeTabBarController {
            recipeTabBarController.recipe = recipe
            dispatch_async(dispatch_get_main_queue()) {
                self.navigationController?.pushViewController(recipeTabBarController, animated: true)
            }
        }
    }
    
    private var recipes = [Recipe]()
    private var query: String = ""
}
