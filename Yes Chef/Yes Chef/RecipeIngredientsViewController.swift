//
//  RecipeIngredientsViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

class RecipeIngredientsViewController: UITableViewController, RecipeIngredientsConversationTopicEventHandler
{
    var recipeIngredientsConversationTopic: RecipeIngredientsConversationTopic!
    
    @IBOutlet var servingsCountLabel: UILabel!
    
    func updateRecipe(recipe: Recipe)
    {
        self.recipe = recipe
        recipeIngredientsConversationTopic.updateRecipe(recipe)
    }
    
    // MARK: Lifecycle
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.recipeIngredientsConversationTopic = RecipeIngredientsConversationTopic(eventHandler: self)
    }
    
    override func viewDidLoad()
    {

    }
    
    override func viewDidAppear(animated: Bool)
    {
        recipeIngredientsConversationTopic.topicDidGainFocus()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        recipeIngredientsConversationTopic.topicDidLoseFocus()
    }
    
    // MARK: ListConversationTopicEventHandler Protocol Methods
    
    func handleSelectCommand(command: SAYCommand)
    {
        print("RecipeIngredientsVC handleSelectCommand")
    }
    
    func handleSearchCommand(command: SAYCommand)
    {
        print("RecipeIngredientsVC handleSearchCommand")
    }
    
    func handlePlayCommand()
    {
        print("RecipeIngredientsVC handlePlayCommand")
    }
    
    func handlePauseCommand()
    {
        print("RecipeIngredientsVC handlePauseCommand")
    }
    
    func handleNextCommand()
    {
        print("RecipeIngredientsVC handleNextCommand")
    }
    
    func handlePreviousCommand()
    {
        print("RecipeIngredientsVC handlePreviousCommand")
    }
    
    private var recipe: Recipe!
}

class IngredientCell: UITableViewCell
{
    @IBOutlet var quantityUnitsLabel: UILabel!
    @IBOutlet var ingredientNameLabel: UILabel!
    
    @IBAction func addToGroceryListButtonTapped(sender: AnyObject)
    {
        // TODO
    }
}
