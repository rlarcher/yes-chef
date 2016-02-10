//
//  SearchResultsViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

class SearchResultsViewController: UITableViewController, SearchResultsConversationTopicEventHandler
{
    var searchResultsConversationTopic: SearchResultsConversationTopic!
    
    // MARK: Lifecycle
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.searchResultsConversationTopic = SearchResultsConversationTopic(eventHandler: self)
    }
    
    // Must be called immediately after instantiating the VC
    func setRecipes(recipes: [Recipe], forSearchQuery query: String)
    {
        self.recipes = recipes
        self.query = query
    }
    
    override func viewDidAppear(animated: Bool)
    {
        searchResultsConversationTopic.topicDidGainFocus()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        searchResultsConversationTopic.topicDidLoseFocus()
    }
    
    // MARK: ListConversationTopicEventHandler Protocol Methods
    
    func handleSelectCommand(command: SAYCommand)
    {
        print("SearchResultsVC handleSelectCommand")
    }
    
    func handleSearchCommand(command: SAYCommand)
    {
        print("SearchResultsVC handleSearchCommand")
    }
    
    func handlePlayCommand()
    {
        print("SearchResultsVC handlePlayCommand")
    }
    
    func handlePauseCommand()
    {
        print("SearchResultsVC handlePauseCommand")
    }
    
    func handleNextCommand()
    {
        print("SearchResultsVC handleNextCommand")
    }
    
    func handlePreviousCommand()
    {
        print("SearchResultsVC handlePreviousCommand")
    }
    
    // MARK: UITableViewDelegate Protocol Methods
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let index = indexPath.row
        if index < recipes.count {
            let recipe = recipes[index]
            presentRecipe(recipe)
        }
    }
    
    // MARK: UITableViewDataSource Protocol Methods
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let index = indexPath.row
        if
            let cell = tableView.dequeueReusableCellWithIdentifier("RecipeCell") as? RecipeCell
            where index < recipes.count
        {
            let recipe = recipes[index]
            cell.recipeNameLabel.text = recipe.name
            cell.thumbnailImageView.setImageWithURL(recipe.thumbnailImageURL, placeholderImage: nil) // TODO: Add placeholder image
            cell.preparationTimeLabel.text = String(recipe.totalPreparationTime) + " minutes"
            cell.ingredientCountLabel.text = String(recipe.ingredients.count) + " ingredients"
            cell.caloriesLabel.text = String(recipe.calories) + " calories"
            
            let ratingLabels = Utils.getLabelsForRating(recipe.rating)
            cell.ratingLabel.text = ratingLabels.textLabel
            cell.ratingLabel.accessibilityLabel = ratingLabels.accessibilityLabel
            
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return recipes.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    // MARK: Navigation Helpers
    
    private func presentRecipe(recipe: Recipe)
    {
        if let recipeTabBarController = storyboard?.instantiateViewControllerWithIdentifier("RecipeTabBarController") as? RecipeTabBarController {
            recipeTabBarController.setRecipe(recipe)
            dispatch_async(dispatch_get_main_queue()) {
                self.navigationController?.pushViewController(recipeTabBarController, animated: true)
                self.searchResultsConversationTopic.addSubtopic(recipeTabBarController.recipeNavigationConversationTopic)
            }
        }
    }
    
    private var recipes: [Recipe]! {
        didSet {
            // Keeps searchResultsCT's recipes in sync with searchResultsVC's recipes.
            searchResultsConversationTopic.updateResults(recipes)
        }
    }
    private var query: String! {
        didSet {
            // Keeps searchResultsCT's query in sync with searchResultsVC's query.
            searchResultsConversationTopic.updateSearchQuery(query)
        }
    }
}
