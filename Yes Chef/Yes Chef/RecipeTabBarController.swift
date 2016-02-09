//
//  RecipeTabBarController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

class RecipeTabBarController: UITabBarController, UITabBarControllerDelegate, RecipeNavigationConversationTopicEventHandler
{
    var recipeNavigationConversationTopic: RecipeNavigationConversationTopic!
    
    // MARK: Lifecycle
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        self.delegate = self
        captureTabs()
        initializeConversationTopic()
    }
    
    // Must be called immediately after instantiating the VC
    func setRecipe(recipe: Recipe)
    {
        self.recipe = recipe
        recipeNavigationConversationTopic.updateRecipe(recipe)
        
        updateTabsWithRecipe(recipe)
    }
    
    override func viewDidLoad()
    {
        navigationItem.title = recipe.name
    }
    
    override func viewDidAppear(animated: Bool)
    {
        // Note: When the TabBarController is first pushed on the stack, this `viewDidAppear` is triggered, but not any of its tabs' `viewDidAppears`, until we manually switch to a new tab. This is the one and only time `RecipeTabBarController` will "appear".
        recipeOverviewVC.didGainFocus(nil)
    }
    
    override func viewWillDisappear(animated: Bool)
    {

    }
    
    // MARK: RecipeNavigationConversationTopicEventHandler Protocol Methods
    
    func handleTabNavigationCommand(command: SAYCommand)
    {
        print("RecipeTabBarController handleTabNavigationCommand: \(command)")
    }
    
    // MARK: UITabBarControllerDelegate Protocol Methods
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController)
    {
        // This method is called when the user taps a tab.
        
        if let previousVC = tabBarController.selectedViewController as? ConversationalTabBarViewController {
            previousVC.didLoseFocus(nil)
        }
        
        if let tabBarVC = viewController as? ConversationalTabBarViewController {
            tabBarVC.didGainFocus(nil)
        }
    }
    
    // MARK: Helpers
    
    func switchToTab(tabViewController: ConversationalTabBarViewController, then completionBlock: (() -> Void)?)
    {
        // This method is called when the user speaks a command that wants to focus on a certain tab.
        if let selectedVC = tabViewController as? UIViewController {
            self.selectedViewController = selectedVC
            tabViewController.didGainFocus(completionBlock)                
        }
    }
    
    private func captureTabs()
    {
        if let tabViewControllers = viewControllers {
            for tabViewController in tabViewControllers {
                if let recipeOverviewVC = tabViewController as? RecipeOverviewViewController {
                    self.recipeOverviewVC = recipeOverviewVC
                }
                else if let recipeIngredientsVC = tabViewController as? RecipeIngredientsViewController {
                    self.recipeIngredientsVC = recipeIngredientsVC
                }
                else if let recipePreparationVC = tabViewController as? RecipePreparationViewController {
                    self.recipePreparationVC = recipePreparationVC
                }
            }
        }
    }
    
    private func initializeConversationTopic()
    {
        recipeNavigationConversationTopic = RecipeNavigationConversationTopic(eventHandler: self)
        recipeNavigationConversationTopic.addSubtopic(recipeOverviewVC.recipeOverviewConversationTopic)
        recipeNavigationConversationTopic.addSubtopic(recipeIngredientsVC.recipeIngredientsConversationTopic)
        recipeNavigationConversationTopic.addSubtopic(recipePreparationVC.recipePreparationConversationTopic)
    }
    
    private func updateTabsWithRecipe(recipe: Recipe)
    {
        recipeOverviewVC.updateRecipe(recipe)
        recipeIngredientsVC.updateRecipe(recipe)
        recipePreparationVC.updateRecipe(recipe)
    }
    
    private var recipe: Recipe!
    private weak var recipeOverviewVC: RecipeOverviewViewController!
    private weak var recipeIngredientsVC: RecipeIngredientsViewController!
    private weak var recipePreparationVC: RecipePreparationViewController!
}
