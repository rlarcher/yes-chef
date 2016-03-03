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

        // Suppress some thin lines that appear at the top and bottom of the search bar:
        searchBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        homeConversationTopic.topicDidGainFocus()
        
        homeConversationTopic.speakIntroduction(shouldSpeakFirstTimeIntroduction)
        shouldSpeakFirstTimeIntroduction = false
        
        selectedNewCuisine(.All)
        selectedNewCategory(.All)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        homeConversationTopic.topicDidLoseFocus()
        navigationController?.setNavigationBarHidden(false, animated: true)
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
    
    func requestedSearchUsingParameters(searchParameters: SearchParameters)
    {
        selectedNewCategory(searchParameters.course)
        selectedNewCuisine(searchParameters.cuisine)
        self.searchParameters.query = searchParameters.query
        
        // TODO: Present intermediate "Loading" scene
        searchUsingParameters(searchParameters)
    }
    
    // MARK: IBAction Methods
    
    @IBAction func categoryButtonTapped(sender: AnyObject)
    {
        selectorPresenter.presentCategorySelector(initialCategory: searchParameters.course)
    }
    
    @IBAction func cuisineButtonTapped(sender: AnyObject)
    {
        selectorPresenter.presentCuisineSelector(initialCuisine: searchParameters.cuisine)
    }
    
    @IBAction func savedRecipesButtonTapped(sender: AnyObject)
    {
        presentSavedRecipes()
    }
    
    @IBAction func menuButtonTapped(sender: AnyObject)
    {
        // TODO
        print("HomeViewController menuButtonTapped")
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
            searchParameters.query = query
            searchUsingParameters(searchParameters)
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
    
    private func presentSearchResults(results: [RecipeListing], forSearchParameters parameters: SearchParameters)
    {
        if let searchResultsVC = storyboard?.instantiateViewControllerWithIdentifier("SearchResultsViewController") as? SearchResultsViewController {
            searchResultsVC.setRecipeListings(results, forSearchParameters: parameters)
            dispatch_async(dispatch_get_main_queue()) {
                self.navigationController?.popToRootThenPushViewController(searchResultsVC, animated: true) // Note: We use `popToRootThenPushVC` to avoid deep stacks of `SearchResultsVC`s when performing multiple searches in a row.
                self.homeConversationTopic.addSubtopic(searchResultsVC.searchResultsConversationTopic)
            }
        }
    }
    
    // MARK: CategoryCuisinePresenter Protocol Methods
    
    func selectedNewCategory(category: Category)
    {
        searchParameters.course = category
    }
    
    func selectedNewCuisine(cuisine: Cuisine)
    {
        searchParameters.cuisine = cuisine
    }
    
    func selectorCancelButtonTapped()
    {
        dispatch_async(dispatch_get_main_queue()) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: Helpers
    
    private func searchUsingParameters(parameters: SearchParameters)
    {
        BigOvenAPIManager.sharedManager.searchForRecipeWithParameters(parameters) { response -> Void in
            switch response {
            case .Success(let recipeListings):
                if recipeListings.count > 0 {
                    self.presentSearchResults(recipeListings, forSearchParameters: parameters)
                }
                else {
                    self.notifyNoResultsForSearchParameters(parameters)
                }
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
    
    private func notifyNoResultsForSearchParameters(parameters: SearchParameters)
    {
        // TODO: If search was performed via search bar, re-highlight the search bar?
        homeConversationTopic.speakNoResultsForSearchParameters(parameters)
    }
    
    private var selectorPresenter: SelectorPresenter!
    private var searchParameters = SearchParameters.emptyParameters()
    private var shouldSpeakFirstTimeIntroduction = true
}
