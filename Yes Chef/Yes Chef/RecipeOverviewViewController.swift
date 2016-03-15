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
    var delegate: RecipeContainerViewDelegate?
    
    @IBOutlet var recipeImageView: UIImageView!
    
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
        super.viewDidLoad()
        
        updateGUI(recipe)
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
    }
    
    // MARK: RecipeOverviewConversationTopicEventHandler Protocol Methods
    
    func handleOverviewCommand()
    {
        delegate?.requestedSwitchTab(.Overview) {
            self.recipeOverviewConversationTopic.speakOverview()
        }
    }
    
    func handleRatingCommand()
    {
        delegate?.requestedSwitchTab(.Overview) {
            self.recipeOverviewConversationTopic.speakRating()
        }
    }
    
    func handleRecipeNameCommand()
    {
        delegate?.requestedSwitchTab(.Overview) {
            self.recipeOverviewConversationTopic.speakRecipeName()
        }
    }
    
    func handleCaloriesCommand()
    {
        delegate?.requestedSwitchTab(.Overview) {
            self.recipeOverviewConversationTopic.speakCalories()
        }
    }
    
    func handleCuisineCategoryCommand()
    {
        delegate?.requestedSwitchTab(.Overview) {
            self.recipeOverviewConversationTopic.speakCuisineCategory()
        }
    }
    
    func handleNutritionInfoCommand()
    {
        delegate?.requestedSwitchTab(.Overview) {
            self.recipeOverviewConversationTopic.speakNutritionInfo()
        }
    }
    
    func handleDescriptionCommand()
    {
        delegate?.requestedSwitchTab(.Overview) {
            self.recipeOverviewConversationTopic.speakDescription()
        }
    }
    
    // MARK: Helpers
    
    private func updateGUI(recipe: Recipe?)
    {
        // TODO: Deprecated. Remove?
    }
    
    private var recipe: Recipe?
}
