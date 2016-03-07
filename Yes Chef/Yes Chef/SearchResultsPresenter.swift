//
//  SearchResultsPresenter.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/7/3.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class SearchResultsPresenter
{
    init(viewController: SearchResultsViewController, conversationTopic: SearchResultsConversationTopic)
    {
        self.searchResultsViewController = viewController
        self.searchResultsConversationTopic = conversationTopic
    }
    
    func popBack()
    {
       searchResultsViewController.navigationController?.popViewControllerAnimated(true)
    }
    
    func presentRecipe(recipe: Recipe)
    {
        if let recipeTabBarController = searchResultsViewController.storyboard?.instantiateViewControllerWithIdentifier("RecipeTabBarController") as? RecipeTabBarController {
            recipeTabBarController.setRecipe(recipe)
            dispatch_async(dispatch_get_main_queue()) {
                self.searchResultsViewController.navigationController?.pushViewController(recipeTabBarController, animated: true)
                self.searchResultsConversationTopic.addSubtopic(recipeTabBarController.recipeNavigationConversationTopic)
            }
        }
    }
    
    func presentSearchOptions(searchParameters: SearchParameters, presentationFrame: CGRect, passthroughViews: [UIView])
    {
        let searchOptionsController = SearchOptionsController(searchParameters: searchParameters)
        searchOptionsController.cuisineSelectionBlock = { selectedCuisine in
            self.searchResultsViewController.selectedNewCuisine(selectedCuisine)
        }
        searchOptionsController.courseSelectionBlock = { selectedCourse in
            self.searchResultsViewController.selectedNewCategory(selectedCourse)
        }
        
        let presentationController = SearchOptionsPresentationController(presentedViewController: searchOptionsController, presentingViewController: searchResultsViewController)
        presentationController.presentationFrame = presentationFrame
        presentationController.passthroughViews = passthroughViews
        
        searchOptionsController.transitioningDelegate = presentationController
        
        searchResultsViewController.presentViewController(searchOptionsController, animated: true, completion: nil)
    }
    
    func presentErrorMessage(message: String)
    {
        // TODO: GUI component? Popup?
        searchResultsConversationTopic.speakErrorMessage(message)
    }
    
    private var searchResultsViewController: SearchResultsViewController
    private var searchResultsConversationTopic: SearchResultsConversationTopic
}
