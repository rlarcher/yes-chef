//
//  RecipeTabBarController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

class RecipeTabBarController: UITabBarController, RecipeNavigationConversationTopicEventHandler
{
    var recipeNavigationConversationTopic: RecipeNavigationConversationTopic!
    
    // MARK: Lifecycle
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.recipeNavigationConversationTopic = RecipeNavigationConversationTopic(eventHandler: self)
    }
    
    override func viewDidLoad()
    {
        navigationItem.title = recipe.name
    }
    
    // Must be called immediately after instantiating the VC
    func setRecipe(recipe: Recipe)
    {
        self.recipe = recipe
    }
    
    private var recipe: Recipe! {
        didSet {
            // TODO: Update CT
        }
    }
}
