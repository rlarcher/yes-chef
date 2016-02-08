//
//  RecipeIngredientsViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

class RecipeIngredientsViewController: UITableViewController, RecipeIngredientsConversationTopicEventHandler, ConversationalTabBarViewController
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

    }
    
    override func viewWillDisappear(animated: Bool)
    {

    }
    
    // MARK: ConversationTabBarViewController Methods
    
    func didGainFocus(completion: (() -> Void)?)
    {
        recipeIngredientsConversationTopic.topicDidGainFocus()
        if let completionBlock = completion {
            completionBlock()
        }
        else {
            // Do the default
            recipeIngredientsConversationTopic.speakIngredients()
        }
    }
    
    func didLoseFocus(completion: (() -> Void)?)
    {
        recipeIngredientsConversationTopic.topicDidLoseFocus()
        if let completionBlock = completion {
            completionBlock()
        }
        else {
            // Do the default
            recipeIngredientsConversationTopic.stopSpeaking()
        }
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
    
    // MARK: UITableViewDataSource Protocol Methods
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let index = indexPath.row
        if
            let cell = tableView.dequeueReusableCellWithIdentifier("IngredientCell") as? IngredientCell
            where index < recipe.ingredients.count
        {
            let ingredient = recipe.ingredients[index]
            cell.ingredientNameLabel.text = ingredient.name
            cell.quantityUnitsLabel.text = "\(ingredient.quantityString) \(ingredient.units)"
            
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return recipe.ingredients.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
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
