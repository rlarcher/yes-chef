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
    @IBOutlet var cuisineButton: UIButton!

    var homeConversationTopic: HomeConversationTopic!
    
    required init?(coder aDecoder: NSCoder)
    {
        // Called as part of `storyboard.instantiateViewControllerWithIdentifier:` method.
        super.init(coder: aDecoder)
        self.homeConversationTopic = HomeConversationTopic(eventHandler: self)
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
            // TODO: Prompt for clarification ("Search for what?")
        }
    }
    
    // MARK: IBAction Methods
    
    @IBAction func categoryButtonTapped(sender: AnyObject)
    {
        presentCategorySelector()
    }
    
    @IBAction func cuisineButtonTapped(sender: AnyObject)
    {
        presentCuisineSelector()
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
        if let query = searchBar.text {
            var category: Category? = nil
            if let categoryString = categoryButton.titleLabel?.text {
                category = Category(rawValue: categoryString)
            }
            
            var cuisine: Cuisine? = nil
            if let cuisineString = cuisineButton.titleLabel?.text {
                cuisine = Cuisine(rawValue: cuisineString)
            }

            searchUsingQuery(query, category: category, cuisine: cuisine)
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
                self.navigationController?.pushViewController(searchResultsVC, animated: true)
                self.homeConversationTopic.addSubtopic(searchResultsVC.searchResultsConversationTopic)
            }
        }
    }
    
    private func presentCategorySelector() {
        let categories = Category.orderedValues
        
        let selectorVC = CategorySelectorViewController()
        selectorVC.categories = categories
        selectorVC.selectedRow = categories.indexOf(activeCategory)
        
        selectorVC.selectionBlock = { selectedCategory in
            self.dismissViewControllerAnimated(true, completion: nil)
            self.setActiveCategory(selectedCategory)
        }
        
        // embed in a nav controller and add cancel button
        let navVC = UINavigationController(rootViewController: selectorVC)
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "presentedViewControllerCancelButtonTapped")
        selectorVC.navigationItem.leftBarButtonItem = cancelButton
        
        self.presentViewController(navVC, animated: true, completion: nil)
    }
    
    private func presentCuisineSelector() {
        let cuisines = Cuisine.orderedValues
        
        let selectorVC = CuisineSelectorViewController()
        selectorVC.cuisines = cuisines
        selectorVC.selectedRow = cuisines.indexOf(activeCuisine)
        
        selectorVC.selectionBlock = { selectedCuisine in
            self.dismissViewControllerAnimated(true, completion: nil)
            self.setActiveCuisine(selectedCuisine)
        }
        
        // embed in a nav controller and add cancel button
        let navVC = UINavigationController(rootViewController: selectorVC)
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "presentedViewControllerCancelButtonTapped")
        selectorVC.navigationItem.leftBarButtonItem = cancelButton
        
        self.presentViewController(navVC, animated: true, completion: nil)
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
    
    func presentedViewControllerCancelButtonTapped()
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func setActiveCategory(category: Category)
    {
        activeCategory = category
        categoryButton.titleLabel?.text = category.rawValue
        categoryButton.updateConstraints()
    }
    
    private func setActiveCuisine(cuisine: Cuisine)
    {
        activeCuisine = cuisine
        cuisineButton.titleLabel?.text = cuisine.rawValue
        cuisineButton.updateConstraints()
    }
    
    private var activeCategory = Category.All
    private var activeCuisine = Cuisine.All
    private var shouldSpeakFirstTimeIntroduction = true
}
