//
//  SavedRecipesViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

class SavedRecipesViewController: UITableViewController, UISearchResultsUpdating, SavedRecipesConversationTopicEventHandler
{
    var selectionBlock: (Recipe -> ())?
    var savedRecipesConversationTopic: SavedRecipesConversationTopic!
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.savedRecipesConversationTopic = SavedRecipesConversationTopic(eventHandler: self)
    }
    
    override func viewDidLoad()
    {
        searchController = UISearchController(searchResultsController: nil)
        tableView.tableHeaderView = searchController?.searchBar
        
        savedRecipes = SavedRecipesManager.sharedManager.loadSavedRecipes()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        // TODO: More appropriate place for this?
        self.savedRecipesConversationTopic.speakSavedRecipes(savedRecipes)
    }
    
    deinit {
        searchController?.view.removeFromSuperview() // Required to avoid warning when dismissing this VC: "Attempting to load the view of a view controller while it is deallocating is not allowed and may result in undefined behavior"
    }
    
    // MARK: ListConversationTopicEventHandler Protocol Methods
    
    func handleSelectCommand(command: SAYCommand)
    {
        print("SavedRecipesVC handleSelectCommand")
    }
    
    func handleSearchCommand(command: SAYCommand)
    {
        print("SavedRecipesVC handleSearchCommand")
    }
    
    func handlePlayCommand()
    {
        print("SavedRecipesVC handlePlayCommand")
    }
    
    func handlePauseCommand()
    {
        print("SavedRecipesVC handlePauseCommand")
    }
    
    func handleNextCommand()
    {
        print("SavedRecipesVC handleNextCommand")
    }
    
    func handlePreviousCommand()
    {
        print("SavedRecipesVC handlePreviousCommand")
    }
    
    // MARK: SavedRecipesConversationTopicEventHandler Protocol Methods
    
    func handleRemoveRecipeCommand(command: SAYCommand)
    {
        print("SavedRecipesVC handleRemoveRecipeCommand")
    }
    
    // MARK: UISearchResultsUpdating Protocol Methods
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        // TODO
    }
    
    // MARK: UITableViewDelegate Protocol Methods
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let index = indexPath.row
        if index < savedRecipes.count {
            selectionBlock?(savedRecipes[index])
        }
    }
    
    // MARK: UITableViewDataSource Protocol Methods
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let index = indexPath.row
        if
            let cell = tableView.dequeueReusableCellWithIdentifier("RecipeCell") as? RecipeCell
            where index < savedRecipes.count
        {
            let recipe = savedRecipes[index]
            cell.recipeNameLabel.text = recipe.name
            cell.thumbnailImageView.image = recipe.thumbnail
            cell.ratingLabel.text = String(recipe.rating)
            cell.preparationTimeLabel.text = String(recipe.preparationTime) // TODO: Format this
            cell.ingredientCountLabel.text = String(recipe.ingredients.count)
            cell.caloriesLabel.text = String(recipe.calories)
            
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return savedRecipes.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    private var savedRecipes = [Recipe]()
    private var searchController: UISearchController?
}

class RecipeCell: UITableViewCell
{
    @IBOutlet var recipeNameLabel: UILabel!    
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var preparationTimeLabel: UILabel!
    @IBOutlet var ingredientCountLabel: UILabel!
    @IBOutlet var caloriesLabel: UILabel!
}
