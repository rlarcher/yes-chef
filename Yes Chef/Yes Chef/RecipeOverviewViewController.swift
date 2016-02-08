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
        let ratingLabels = Utils.getLabelsForRating(recipe.rating)
        ratingLabel.text = ratingLabels.textLabel
        ratingLabel.accessibilityLabel = ratingLabels.accessibilityLabel
        
        recipeImageView.image = recipe.thumbnail
    }
    
    override func viewDidAppear(animated: Bool)
    {
        recipeOverviewConversationTopic.topicDidGainFocus()
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        recipeOverviewConversationTopic.topicDidLoseFocus()
    }
    
    // MARK: RecipeOverviewConversationTopicEventHandler Protocol Methods
    
    func handleOverviewCommand()
    {
        if tabBarController?.selectedViewController == self {
            // If we're already focused on the Overview tab, have the overviewCT repeat its Overview.
            recipeOverviewConversationTopic.speakOverview()
        }
        else {
            // Otherwise, the overview will be spoken when we switch tabs.
            tabBarController?.selectedViewController = self
        }
    }
    
    private var recipe: Recipe!
}
