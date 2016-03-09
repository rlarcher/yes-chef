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
        super.viewDidLoad()
        
        updateGUI(recipe)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        // TODO: Move to didLayout?
//        (tabBarController as? RecipeTabBarController)?.setTabBarToBottom()
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
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
        delegate?.requestedSwitchToTab(self) {
            self.recipeOverviewConversationTopic.speakOverview()
        }
    }
    
    func handleRatingCommand()
    {
        delegate?.requestedSwitchToTab(self) {
            self.recipeOverviewConversationTopic.speakRating()
        }
    }
    
    func handleRecipeNameCommand()
    {
        delegate?.requestedSwitchToTab(self) {
            self.recipeOverviewConversationTopic.speakRecipeName()
        }
    }
    
    func handleCaloriesCommand()
    {
        delegate?.requestedSwitchToTab(self) {
            self.recipeOverviewConversationTopic.speakCalories()
        }
    }
    
    func handleCuisineCategoryCommand()
    {
        delegate?.requestedSwitchToTab(self) {
            self.recipeOverviewConversationTopic.speakCuisineCategory()
        }
    }
    
    func handleNutritionInfoCommand()
    {
        delegate?.requestedSwitchToTab(self) {
            self.recipeOverviewConversationTopic.speakNutritionInfo()
        }
    }
    
    func handleDescriptionCommand()
    {
        delegate?.requestedSwitchToTab(self) {
            self.recipeOverviewConversationTopic.speakDescription()
        }
    }
    
    // MARK: Helpers
    
    private func updateGUI(recipe: Recipe?)
    {
        if let newRecipe = recipe {
            let ratingLabels = Utils.getLabelsForRating(newRecipe.presentableRating)
            ratingLabel.text = ratingLabels.textLabel
            ratingLabel.accessibilityLabel = ratingLabels.accessibilityLabel
            
            recipeImageView.af_setImageWithURL(newRecipe.heroImageURL, placeholderImage: nil) // TODO: Add placeholder image
        }
    }
    
    private var recipe: Recipe?
}
