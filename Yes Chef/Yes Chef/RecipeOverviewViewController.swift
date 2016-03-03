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
        let ratingLabels = Utils.getLabelsForRating(recipe.presentableRating)
        ratingLabel.text = ratingLabels.textLabel
        ratingLabel.accessibilityLabel = ratingLabels.accessibilityLabel
        
        recipeImageView.af_setImageWithURL(recipe.heroImageURL, placeholderImage: nil) // TODO: Add placeholder image
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
        (tabBarController as? RecipeTabBarController)?.switchToTab(self) {
            self.recipeOverviewConversationTopic.speakRating()
        }
    }
    
    func handleRecipeNameCommand()
    {
        (tabBarController as? RecipeTabBarController)?.switchToTab(self) {
            self.recipeOverviewConversationTopic.speakRecipeName()
        }
    }
    
    func handleCaloriesCommand()
    {
        (tabBarController as? RecipeTabBarController)?.switchToTab(self) {
            self.recipeOverviewConversationTopic.speakCalories()
        }
    }
    
    func handleCuisineCategoryCommand()
    {
        (tabBarController as? RecipeTabBarController)?.switchToTab(self) {
            self.recipeOverviewConversationTopic.speakCuisineCategory()
        }
    }
    
    func handleNutritionInfoCommand()
    {
        (tabBarController as? RecipeTabBarController)?.switchToTab(self) {
            self.recipeOverviewConversationTopic.speakNutritionInfo()
        }
    }
    
    func handleDescriptionCommand()
    {
        (tabBarController as? RecipeTabBarController)?.switchToTab(self) {
            self.recipeOverviewConversationTopic.speakDescription()
        }
    }
    
    private var recipe: Recipe!
}
