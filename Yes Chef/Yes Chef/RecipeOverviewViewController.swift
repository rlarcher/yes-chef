//
//  RecipeOverviewViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

class RecipeOverviewViewController: UIViewController, RecipeOverviewConversationTopicEventHandler
{
    var recipeOverviewConversationTopic: RecipeOverviewConversationTopic!
    
    @IBOutlet var recipeImageView: UIImageView!
    @IBOutlet var ratingLabel: UILabel!
    
    // MARK: Lifecycle
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.recipeOverviewConversationTopic = RecipeOverviewConversationTopic(eventHandler: self)
    }
    
    // Must be called immediately after instantiating the VC
    func updateRecipe(recipe: Recipe)
    {
        self.recipe = recipe
        recipeOverviewConversationTopic.updateRecipe(recipe)
    }
    
    override func viewDidLoad()
    {

    }
    
    override func viewDidAppear(animated: Bool)
    {
        recipeOverviewConversationTopic.topicDidGainFocus()
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        recipeOverviewConversationTopic.topicDidLoseFocus()
    }
    
    private var recipe: Recipe!
}
