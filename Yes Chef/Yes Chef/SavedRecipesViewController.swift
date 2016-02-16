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
    
    // MARK: Lifecycle
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.savedRecipesConversationTopic = SavedRecipesConversationTopic(eventHandler: self)
    }
    
    override func viewDidLoad()
    {
        searchController = UISearchController(searchResultsController: nil)
        savedRecipes = SavedRecipesManager.sharedManager.loadSavedRecipes()
        
        tableView.tableHeaderView = searchController?.searchBar
    }
    
    override func viewDidAppear(animated: Bool)
    {
        savedRecipesConversationTopic.topicDidGainFocus()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        savedRecipesConversationTopic.topicDidLoseFocus()
    }
    
    deinit {
        searchController?.view.removeFromSuperview() // Required to avoid warning when dismissing this VC: "Attempting to load the view of a view controller while it is deallocating is not allowed and may result in undefined behavior"
    }
    
    // MARK: ListConversationTopicEventHandler Protocol Methods
    
    func selectedItemWithName(name: String?, index: Int?)
    {
        if
            let recipeName = name,
            let selectedRecipe = recipeWithName(recipeName)
        {
            selectionBlock?(selectedRecipe)
        }
        else if
            let recipeIndex = index,
            let selectedRecipe = recipeAtIndex(recipeIndex)
        {
            selectionBlock?(selectedRecipe)
        }
        else {
            // TODO: Handle error / followup
        }
    }
    
    func handlePlayCommand()
    {
        print("SavedRecipesVC handlePlayCommand")
        // TODO: Interact with the command bar playback controls - change middle button to Pause
    }
    
    func handlePauseCommand()
    {
        print("SavedRecipesVC handlePauseCommand")
        // TODO: Interact with the command bar playback controls - change middle button to Play
    }
    
    func beganSpeakingItemAtIndex(index: Int)
    {
        print("SavedRecipesVC beganSpeakingItemAtIndex: \(index)")
        tableView?.selectRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
    }
    
    func finishedSpeakingItemAtIndex(index: Int)
    {
        print("SavedRecipesVC finishedSpeakingItemAtIndex: \(index)")
        tableView?.deselectRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: true)
    }
    
    // MARK: SavedRecipesConversationTopicEventHandler Protocol Methods
    
    func requestedRemoveItemWithName(name: String?, index: Int)
    {
        print("SavedRecipesVC handleRemoveRecipeCommand")
        // TODO: Interact with Saved Recipes manager
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
            cell.thumbnailImageView.af_setImageWithURL(recipe.heroImageURL, placeholderImage: nil) // TODO: Add placeholder image
            cell.servingSizeLabel.text = "Serves: \(recipe.servingSize)"
            if let prepTime = recipe.totalPreparationTime {
                cell.totalPreparationTimeLabel.text = "\(prepTime) Minutes"
            }
            else {
                cell.totalPreparationTimeLabel.text = "Unknown Prep Time"
            }
            cell.ingredientsLabel.text = "\(recipe.ingredients.count) Ingredients"
            
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
        return savedRecipes.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    // MARK: Helpers
    
    func recipeWithName(name: String) -> Recipe?
    {
        let matchingRecipe = savedRecipes.filter({ $0.name.lowercaseString == name.lowercaseString }).first // TODO: Improve how we check for a match
        return matchingRecipe
    }
    
    func recipeAtIndex(index: Int) -> Recipe?
    {
        if index > 0 && index < savedRecipes.count {
            return savedRecipes[index]
        }
        else {
            return nil
        }
    }
    
    private var savedRecipes: [Recipe]! {
        didSet {
            // Keeps savedRecipesCT's recipes in sync with savedRecipesVC's recipes.
            savedRecipesConversationTopic.updateSavedRecipes(savedRecipes)
        }
    }
    private var searchController: UISearchController?
}

class RecipeCell: UITableViewCell
{
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var totalPreparationTimeLabel: UILabel!
    @IBOutlet weak var servingSizeLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
}
