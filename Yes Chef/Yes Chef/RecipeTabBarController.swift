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
        recipeOverviewVC.recipeOverviewConversationTopic.topicDidGainFocus()
    }
    
    override func viewWillDisappear(animated: Bool)
    {

    }
    
    // MARK: UITabBarControllerDelegate Protocol Methods
    
//    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController)
//    {
//        if viewController is RecipeOverviewViewController {
//            // TODO: Give focus to OverviewCT
//        }
//        else if viewController is RecipeIngredientsViewController {
//            // TODO: Give focus to IngredientsCT
//        }
//        else if viewController is RecipePreparationViewController {
//            // TODO: Give focus to PreparationCT
//        }
//    }
    
    // MARK: Helpers
    
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
        let topic = RecipeNavigationConversationTopic(eventHandler: self)
        topic.addSubtopic(recipeOverviewVC.recipeOverviewConversationTopic)
        topic.addSubtopic(recipeIngredientsVC.recipeIngredientsConversationTopic)
        topic.addSubtopic(recipePreparationVC.recipePreparationConversationTopic)
        
        self.recipeNavigationConversationTopic = topic
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
