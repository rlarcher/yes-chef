//
//  RecipeOverviewViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

class RecipeOverviewViewController: UIViewController, RecipeOverviewConversationTopicEventHandler, ConversationalTabBarViewController
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

    }
    
    override func viewDidDisappear(animated: Bool)
    {

    }
    
    // MARK: ConversationTabBarViewController Methods
    
    func didGainFocus(completion: (() -> Void)?)
    {
        recipeOverviewConversationTopic.topicDidGainFocus()
        if let completionBlock = completion {
            completionBlock()
        }
        else {
            // Do the default
            recipeOverviewConversationTopic.speakOverview()
        }
    }
    
    func didLoseFocus(completion: (() -> Void)?)
    {
        recipeOverviewConversationTopic.topicDidLoseFocus()
        if let completionBlock = completion {
            completionBlock()
        }
        else {
            // Do the default
            recipeOverviewConversationTopic.stopSpeaking()
        }
    }
    
    // MARK: RecipeOverviewConversationTopicEventHandler Protocol Methods
    
    func handleOverviewCommand()
    {        
        (tabBarController as? RecipeTabBarController)?.switchToTab(self) {
            self.recipeOverviewConversationTopic.speakOverview()
        }
    }
    
    func handleRatingCommand()
    {
        tabBarController?.selectedViewController = self
        recipeOverviewConversationTopic.speakRating()
    }
    
    func handleRecipeNameCommand()
    {
        tabBarController?.selectedViewController = self
        recipeOverviewConversationTopic.speakRecipeName()
    }
    
    func handleCaloriesCommand()
    {
        tabBarController?.selectedViewController = self
        recipeOverviewConversationTopic.speakCalories()
    }
    
    private var recipe: Recipe!
}
