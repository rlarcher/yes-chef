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
    
    
    private var recipe: Recipe!
}

class PreparationStepCell: UITableViewCell
{
    @IBOutlet var stepNumberLabel: UILabel!
    @IBOutlet var instructionsTextView: UITextView!
}
