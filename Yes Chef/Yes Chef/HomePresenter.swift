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
    init(viewController: HomeViewController, conversationTopic: HomeConversationTopic)
    {
        self.homeViewController = viewController
        self.homeConversationTopic = conversationTopic
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
        if let recipeContainerViewController = homeViewController.storyboard?.instantiateViewControllerWithIdentifier("RecipeContainerViewController") as? RecipeContainerViewController {
            recipeContainerViewController.setRecipe(recipe)
            dispatch_async(dispatch_get_main_queue()) {
                if shouldPopViewController {
                    self.homeViewController.navigationController?.popThenPushViewController(recipeContainerViewController, animated: true)
                }
                else {
                    self.homeViewController.navigationController?.pushViewController(recipeContainerViewController, animated: true)
                }
                self.homeConversationTopic.addSubtopic(recipeContainerViewController.recipeNavigationConversationTopic)
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
    
    func presentIntroSlides()
    {
        if let introPageViewController = homeViewController.storyboard?.instantiateViewControllerWithIdentifier("IntroPageViewController") as? IntroPageViewController {
            let presentationController = IntroPresentationController(presentedViewController: introPageViewController, presentingViewController: homeViewController)
            introPageViewController.transitioningDelegate = presentationController
            introPageViewController.dismissalBlock = nil
            
            homeViewController.presentViewController(introPageViewController, animated: true, completion: nil)
        }
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
    
    func requestedPresentIntroSlides()
    {
        presentIntroSlides()
    }
    
    private let homeConversationTopic: HomeConversationTopic
    private let homeViewController: HomeViewController
}
