//
//  HomePresenter.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/7/3.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class HomePresenter: MenuViewControllerDelegate
{
    init(homeViewController: HomeViewController, homeConversationTopic: HomeConversationTopic)
    {
        self.homeViewController = homeViewController
        self.homeConversationTopic = homeConversationTopic
    }
    
    func presentSavedRecipes()
    {
        if let savedRecipesVC = homeViewController.storyboard?.instantiateViewControllerWithIdentifier("SavedRecipesViewController") as? SavedRecipesViewController {
            savedRecipesVC.selectionBlock = { selectedRecipe in
                self.presentRecipeDetails(selectedRecipe, shouldPopViewController: true)
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.homeViewController.navigationController?.pushViewController(savedRecipesVC, animated: true)
                self.homeConversationTopic.addSubtopic(savedRecipesVC.savedRecipesConversationTopic)
            }
        }
    }
    
    func presentRecipeDetails(recipe: Recipe, shouldPopViewController: Bool)
    {
        if let recipeTabBarController = homeViewController.storyboard?.instantiateViewControllerWithIdentifier("RecipeTabBarController") as? RecipeTabBarController {
            recipeTabBarController.setRecipe(recipe)
            dispatch_async(dispatch_get_main_queue()) {
                if shouldPopViewController {
                    self.homeViewController.navigationController?.popThenPushViewController(recipeTabBarController, animated: true)
                }
                else {
                    self.homeViewController.navigationController?.pushViewController(recipeTabBarController, animated: true)
                }
                self.homeConversationTopic.addSubtopic(recipeTabBarController.recipeNavigationConversationTopic)
            }
        }
    }
    
    func presentSearchResults(results: [RecipeListing], forSearchParameters parameters: SearchParameters)
    {
        if let searchResultsVC = homeViewController.storyboard?.instantiateViewControllerWithIdentifier("SearchResultsViewController") as? SearchResultsViewController {
            searchResultsVC.updateListings(results, forSearchParameters: parameters)
            dispatch_async(dispatch_get_main_queue()) {
                self.homeViewController.navigationController?.popToRootThenPushViewController(searchResultsVC, animated: true) // Note: We use `popToRootThenPushVC` to avoid deep stacks of `SearchResultsVC`s when performing multiple searches in a row.
                self.homeConversationTopic.addSubtopic(searchResultsVC.searchResultsConversationTopic)
            }
        }
    }
    
    func presentMenu()
    {
        if let menuViewController = homeViewController.storyboard?.instantiateViewControllerWithIdentifier("MenuViewController") as? MenuViewController {
            let presentationController = MenuPresentationController(presentedViewController: menuViewController, presentingViewController: homeViewController)
            menuViewController.transitioningDelegate = presentationController
            menuViewController.selectionDelegate = self
            
            homeViewController.presentViewController(menuViewController, animated: true, completion: nil)
        }
    }
    
    func presentSearchOptions(searchParameters: SearchParameters, presentationFrame: CGRect, passthroughViews: [UIView])
    {
        let searchOptionsController = SearchOptionsController(searchParameters: searchParameters)
        searchOptionsController.cuisineSelectionBlock = { selectedCuisine in
            self.homeViewController.selectedNewCuisine(selectedCuisine)
        }
        searchOptionsController.courseSelectionBlock = { selectedCourse in
            self.homeViewController.selectedNewCategory(selectedCourse)
        }
        
        let presentationController = SearchOptionsPresentationController(presentedViewController: searchOptionsController, presentingViewController: homeViewController)
        presentationController.presentationFrame = presentationFrame
        presentationController.passthroughViews = passthroughViews
        
        searchOptionsController.transitioningDelegate = presentationController
        
        homeViewController.presentViewController(searchOptionsController, animated: true, completion: nil)
    }
    
    func presentErrorMessage(message: String)
    {
        // TODO: GUI component? Popup?
        homeConversationTopic.speakErrorMessage(message)
    }
    
    // MARK: MenuViewControllerDelegate Protocol Methods
    
    func requestedPresentSavedRecipes()
    {
        presentSavedRecipes()
    }
    
    private let homeConversationTopic: HomeConversationTopic
    private let homeViewController: HomeViewController
}
