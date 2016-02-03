//
//  HomeViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UISearchBarDelegate, HomeConversationTopicEventHandler
{
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var categoryButton: UIButton!

    var homeConversationTopic: HomeConversationTopic?
    
    override func viewDidLoad()
    {
        searchBar.delegate = self
    }
    
    override func viewDidAppear(animated: Bool)
    {
        homeConversationTopic?.removeAllSubtopics() // TODO: Think of a better way to clean up popped subtopics. Override navigation methods? Independent navigation management?
    }
    
    // MARK: HomeConversationTopicEventHandler Protocol Methods
    
    func handleAvailableCommands()
    {
        print("HomeVC handleAvailableCommands!")
    }
    
    func handleSearchCommand(command: SAYCommand)
    {
        print("HomeVC handleSearchCommand: \(command)")
    }
    
    func handleHomeCommand()
    {
        print("HomeVC handleHomeCommand!")
    }
    
    func handleBackCommand()
    {
        print("HomeVC handleBackCommand")
    }
    
    // MARK: IBAction Methods
    
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
                self.presentRecipeDetails(selectedRecipe, shouldPopViewController: true)
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.navigationController?.pushViewController(savedRecipesVC, animated: true)
                let savedRecipesCT = SavedRecipesConversationTopic(eventHandler: savedRecipesVC)
                savedRecipesVC.savedRecipesConversationTopic = savedRecipesCT
                self.homeConversationTopic?.addSubtopic(savedRecipesCT) // TODO: BLEHHH. Gross initialization.
            }
        }
    }
    
    private func presentRecipeDetails(recipe: Recipe, shouldPopViewController: Bool)
    {
        if let recipeTabBarController = storyboard?.instantiateViewControllerWithIdentifier("RecipeTabBarController") as? RecipeTabBarController {
            recipeTabBarController.recipe = recipe
            dispatch_async(dispatch_get_main_queue()) {
                if shouldPopViewController {
                    self.navigationController?.popThenPushViewController(recipeTabBarController, animated: true)
                }
                else {
                    self.navigationController?.pushViewController(recipeTabBarController, animated: true)
                }
                self.homeConversationTopic?.addSubtopic(RecipeNavigationConversationTopic())
            }
        }
    }
    
    private func presentSearchResults(results: [Recipe], forQuery query: String)
    {
        if let searchResultsVC = storyboard?.instantiateViewControllerWithIdentifier("SearchResultsViewController") as? SearchResultsViewController {
            searchResultsVC.setRecipes(results, forSearchQuery: query)
            dispatch_async(dispatch_get_main_queue()) {
                self.navigationController?.pushViewController(searchResultsVC, animated: true)
                self.homeConversationTopic?.addSubtopic(SearchResultsConversationTopic())
            }
        }
    }
    
    // MARK: Helpers
    
    private func searchUsingQuery(query: String, category: String)
    {
        BigOvenAPIManager.sharedManager.search(query, category: category) { (results, error) -> Void in
            if error == nil {
                self.presentSearchResults(results, forQuery: query)
            }
            else {
                // TODO: Handle error
            }
        }
    }
}
