//
//  RecipeTabBarController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

class RecipeTabBarController: AdjustableTabBarController, UITabBarControllerDelegate, RecipeNavigationConversationTopicEventHandler
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
        super.viewDidLoad()
        
        navigationItem.title = recipe.name
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "♡", style: .Plain, target: self, action: "favoriteButtonTapped")
        navigationItem.rightBarButtonItem?.enabled = false  // TODO: Activate this
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "X", style: .Plain, target: self, action: "backButtonTapped") // TODO: Just customize the existing back button, with proper image.
        
        // Roundabout way to make the navigation bar's background completely invisible:
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    // TODO: Clean this up
    private static var didLayout = false
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        if !RecipeTabBarController.didLayout {
            // Only want to set this once.
            RecipeTabBarController.didLayout = true
            setTabBarToBottom()
        }
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        // Note: When the TabBarController is first pushed on the stack, this `viewDidAppear` is triggered, but not any of its tabs' `viewDidAppears`, until we manually switch to a new tab. This is the one and only time `RecipeTabBarController` will "appear".
        recipeOverviewVC.didGainFocus(nil)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        recipeNavigationConversationTopic.topicDidLoseFocus()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        super.viewWillDisappear(animated)
    }
    
    // MARK: RecipeNavigationConversationTopicEventHandler Protocol Methods
    
    func requestedSwitchTab(newTab: RecipeTab)
    {
        switch newTab {
        case .Overview:
            switchToTab(recipeOverviewVC, then: nil)
        case .Preparation:
            switchToTab(recipePreparationVC, then: nil)
        case .Ingredients:
            switchToTab(recipeIngredientsVC, then: nil)
        }
    }
    
    // MARK: UITabBarControllerDelegate Protocol Methods
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool
    {
        // This method is called when the user taps a tab.
        
        if let previousVC = tabBarController.selectedViewController as? ConversationalTabBarViewController {
            previousVC.didLoseFocus(nil)
        }
        
        if let tabBarVC = viewController as? ConversationalTabBarViewController {
            tabBarVC.didGainFocus(nil)
        }
        
        return true
    }
    
    // MARK: Helpers
    
    func switchToTab(tabViewController: ConversationalTabBarViewController, then completionBlock: (() -> Void)?)
    {
        // This method is called when the user speaks a command that wants to focus on a certain tab.
        
        // TODO: Any way to just call this on previousVC?
        recipeOverviewVC.didLoseFocus(nil)
        recipeIngredientsVC.didLoseFocus(nil)
        recipePreparationVC.didLoseFocus(nil)
        
        if let selectedVC = tabViewController as? UIViewController {
            self.selectedViewController = selectedVC
            tabViewController.didGainFocus(completionBlock)                
        }
    }
    
    func favoriteButtonTapped()
    {
        // TODO
        print("RecipeTabBarController favoriteButtonTapped")
    }
    
    func backButtonTapped()
    {
        navigationController?.popViewControllerAnimated(true)
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

enum RecipeTab: String
{
    case Overview = "Overview"
    case Preparation = "Preparation"
    case Ingredients = "Ingredients"
    
    static func orderedCases() -> [RecipeTab]
    {
        return [.Overview, .Preparation, .Ingredients]
    }
}
