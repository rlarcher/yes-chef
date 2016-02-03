//
//  HomeViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UISearchBarDelegate
{
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var categoryButton: UIButton!

    override func viewDidLoad()
    {
        searchBar.delegate = self
    }
    
    @IBAction func categoryButtonTapped(sender: AnyObject)
    {
        // TODO
    }
    
    @IBAction func savedRecipesButtonTapped(sender: AnyObject)
    {
        presentSavedRecipes()
    }
    
    // MARK: UISearchBarDelegate Protocol Methods
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        if
            let query = searchBar.text,
            let category = categoryButton.titleLabel?.text
        {
            searchUsingQuery(query, category: category)
        }
    }
    
    // MARK: Navigation Helpers

    private func presentSavedRecipes()
    {
        if let savedRecipesVC = storyboard?.instantiateViewControllerWithIdentifier("SavedRecipesViewController") as? SavedRecipesViewController {
            savedRecipesVC.selectionBlock = { selectedRecipe in
                self.presentRecipe(selectedRecipe)
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.navigationController?.pushViewController(savedRecipesVC, animated: true)
            }
        }
    }
    
    private func presentRecipe(recipe: Recipe)
    {
        if let recipeTabBarController = storyboard?.instantiateViewControllerWithIdentifier("RecipeTabBarController") as? RecipeTabBarController {
            recipeTabBarController.recipe = recipe
            dispatch_async(dispatch_get_main_queue()) {
                self.navigationController?.pushViewController(recipeTabBarController, animated: true)
            }
        }
    }
    
    private func presentSearchResults(results: [Recipe], forQuery query: String)
    {
        if let searchResultsVC = storyboard?.instantiateViewControllerWithIdentifier("SearchResultsViewController") as? SearchResultsViewController {
            searchResultsVC.setRecipes(results, forSearchQuery: query)
            dispatch_async(dispatch_get_main_queue()) {
                self.navigationController?.pushViewController(searchResultsVC, animated: true)
            }
        }
    }
    
    // MARK: Helpers
    
    private func searchUsingQuery(query: String, category: String)
    {
        // TODO: Ask BigOvenAPIManager to do a search, async, and on finish:
        self.presentSearchResults([], forQuery: query)
        // TODO: else handle error
    }
}
