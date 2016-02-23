//
//  HomeViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UISearchBarDelegate, HomeConversationTopicEventHandler, SelectorPresenterEventHandler
{
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var categoryButton: UIButton!
    @IBOutlet var cuisineButton: UIButton!

    var homeConversationTopic: HomeConversationTopic!
    
    required init?(coder aDecoder: NSCoder)
    {
        // Called as part of `storyboard.instantiateViewControllerWithIdentifier:` method.
        super.init(coder: aDecoder)
        self.homeConversationTopic = HomeConversationTopic(eventHandler: self)
        self.selectorPresenter = SelectorPresenter(presentingViewController: self, eventHandler: self)
    }
    
    override func viewDidLoad()
    {
        searchBar.delegate = self
        categoryButton.titleLabel?.text = activeCategory.rawValue
        cuisineButton.titleLabel?.text = activeCuisine.rawValue
    }
    
    override func viewDidAppear(animated: Bool)
    {
        homeConversationTopic.topicDidGainFocus()
        
        homeConversationTopic.speakIntroduction(shouldSpeakFirstTimeIntroduction)
        shouldSpeakFirstTimeIntroduction = false
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        homeConversationTopic.topicDidLoseFocus()
    }
    
    // MARK: HomeConversationTopicEventHandler Protocol Methods
    
    func handleHelpCommand()
    {
        homeConversationTopic.speakHelpMessage()
    }
    
    func handleAvailableCommands()
    {
        // TODO: Present available commands list?
        homeConversationTopic.speakAvailableCommands()
    }
    
    func handleHomeCommand()
    {
        navigationController?.popToRootViewControllerAnimated(true)
        homeConversationTopic.speakIntroduction(false)
    }
    
    func handleBackCommand()
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func requestedSearchUsingQuery(searchQuery: String?, category: Category?, cuisine: Cuisine?)
    {
        if let query = searchQuery {
            searchUsingQuery(query, category: category, cuisine: cuisine)
        }
        else {
            // TODO: Do anything? Bonk?
        }
    }
    
    // MARK: IBAction Methods
    
    @IBAction func categoryButtonTapped(sender: AnyObject)
    {
        selectorPresenter.presentCategorySelector(initialCategory: activeCategory)
    }
    
    @IBAction func cuisineButtonTapped(sender: AnyObject)
    {
        selectorPresenter.presentCuisineSelector(initialCuisine: activeCuisine)
    }
    
    @IBAction func savedRecipesButtonTapped(sender: AnyObject)
    {
        presentSavedRecipes()
    }
    
    // MARK: UISearchBarDelegate Protocol Methods
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool
    {
        searchBar.setShowsCancelButton(true, animated: true)
        
        return true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar)
    {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        if let query = searchBar.text {
            searchUsingQuery(query, category: activeCategory, cuisine: activeCuisine)
        }
        
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
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
                self.homeConversationTopic.addSubtopic(savedRecipesVC.savedRecipesConversationTopic)
            }
        }
    }
    
    private func presentRecipeDetails(recipe: Recipe, shouldPopViewController: Bool)
    {
        if let recipeTabBarController = storyboard?.instantiateViewControllerWithIdentifier("RecipeTabBarController") as? RecipeTabBarController {
            recipeTabBarController.setRecipe(recipe)
            dispatch_async(dispatch_get_main_queue()) {
                if shouldPopViewController {
                    self.navigationController?.popThenPushViewController(recipeTabBarController, animated: true)
                }
                else {
                    self.navigationController?.pushViewController(recipeTabBarController, animated: true)
                }
                self.homeConversationTopic.addSubtopic(recipeTabBarController.recipeNavigationConversationTopic)
            }
        }
    }
    
    private func presentSearchResults(results: [RecipeListing], forQuery query: String)
    {
        if let searchResultsVC = storyboard?.instantiateViewControllerWithIdentifier("SearchResultsViewController") as? SearchResultsViewController {
            searchResultsVC.setRecipeListings(results, forSearchQuery: query)
            dispatch_async(dispatch_get_main_queue()) {
                self.navigationController?.popToRootThenPushViewController(searchResultsVC, animated: true) // Note: We use `popToRootThenPushVC` to avoid deep stacks of `SearchResultsVC`s when performing multiple searches in a row.
                self.homeConversationTopic.addSubtopic(searchResultsVC.searchResultsConversationTopic)
            }
        }
    }
    
    // MARK: CategoryCuisinePresenter Protocol Methods
    
    func selectedNewCategory(category: Category)
    {
        activeCategory = category
        dispatch_async(dispatch_get_main_queue()) {
            self.categoryButton.setTitle(category.rawValue, forState: .Normal)
        }
    }
    
    func selectedNewCuisine(cuisine: Cuisine)
    {
        activeCuisine = cuisine
        dispatch_async(dispatch_get_main_queue()) {
            self.cuisineButton.setTitle(cuisine.rawValue, forState: .Normal)
        }
    }
    
    func selectorCancelButtonTapped()
    {
        dispatch_async(dispatch_get_main_queue()) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: Helpers
    
    private func searchUsingQuery(query: String, category: Category?, cuisine: Cuisine?)
    {
        BigOvenAPIManager.sharedManager.searchForRecipeByName(query, category: category, cuisine: cuisine) { response -> Void in
            switch response {
            case .Success(let recipeListings):
                self.presentSearchResults(recipeListings, forQuery: query)
            case .Failure(let errorMessage, _):
                self.presentErrorMessage(errorMessage)
            }
        }
    }
    
    private func presentErrorMessage(message: String)
    {
        // TODO: GUI component? Popup?
        homeConversationTopic.speakErrorMessage(message)
    }
    
    private var selectorPresenter: SelectorPresenter!
    private var activeCategory = Category.All
    private var activeCuisine = Cuisine.All
    private var shouldSpeakFirstTimeIntroduction = true
}
