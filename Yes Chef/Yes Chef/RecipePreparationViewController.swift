//
//  RecipePreparationViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

class RecipePreparationViewController: UITableViewController, RecipePreparationConversationTopicEventHandler
{
    var recipePreparationConversationTopic: RecipePreparationConversationTopic!
    
    @IBOutlet var activeTimeLabel: UILabel!
    
    func updateRecipe(recipe: Recipe)
    {
        self.recipe = recipe
        recipePreparationConversationTopic.updateRecipe(recipe)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.recipePreparationConversationTopic = RecipePreparationConversationTopic(eventHandler: self)
    }
    
    override func viewDidLoad()
    {

    }
    
    override func viewDidAppear(animated: Bool)
    {
        recipePreparationConversationTopic.topicDidGainFocus()
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        recipePreparationConversationTopic.topicDidLoseFocus()
    }
    
    // MARK: ListConversationTopicEventHandler Protocol Methods
    
    func handleSelectCommand(command: SAYCommand)
    {
        print("RecipePreparationVC handleSelectCommand")
    }
    
    func handleSearchCommand(command: SAYCommand)
    {
        print("RecipePreparationVC handleSearchCommand")
    }
    
    func handlePlayCommand()
    {
        print("RecipePreparationVC handlePlayCommand")
    }
    
    func handlePauseCommand()
    {
        print("RecipePreparationVC handlePauseCommand")
    }
    
    func handleNextCommand()
    {
        print("RecipePreparationVC handleNextCommand")
    }
    
    func handlePreviousCommand()
    {
        print("RecipePreparationVC handlePreviousCommand")
    }
    
    // MARK: UITableViewDataSource Protocol Methods
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let index = indexPath.row
        if
            let cell = tableView.dequeueReusableCellWithIdentifier("PreparationStepCell") as? PreparationStepCell
            where index < recipe.preparationSteps.count
        {
            cell.stepNumberLabel.text = "\(index + 1)"  // base-1
            cell.instructionsTextView.text = recipe.preparationSteps[index]
            
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return recipe.preparationSteps.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    private var recipe: Recipe!
}

class PreparationStepCell: UITableViewCell
{
    @IBOutlet var stepNumberLabel: UILabel!
    @IBOutlet var instructionsTextView: UITextView!
}
