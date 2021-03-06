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
        super.viewDidLoad()        
        
        searchController = UISearchController(searchResultsController: nil)
        savedRecipes = SavedRecipesManager.sharedManager.loadSavedRecipes()
        
        tableView.tableHeaderView = searchController?.searchBar
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        savedRecipesConversationTopic.topicDidGainFocus()
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        savedRecipesConversationTopic.topicDidLoseFocus()
        
        super.viewWillDisappear(animated)
    }
    
    deinit {
        searchController?.view.removeFromSuperview() // Required to avoid warning when dismissing this VC: "Attempting to load the view of a view controller while it is deallocating is not allowed and may result in undefined behavior"
    }
    
    // MARK: ListConversationTopicEventHandler Protocol Methods
    
    func selectedRecipe(recipe: Recipe?)
    {
        if let selectedRecipe = recipe {
            selectionBlock?(selectedRecipe)
        }
        else {
            // TODO: Visual feedback?
            print("SavedRecipesVC selectedRecipe, no recipe could be selected.")
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
        tableView?.selectRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
    }
    
    func finishedSpeakingItemAtIndex(index: Int)
    {
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
            cell.thumbnailImageView.af_setImageWithURL(recipe.heroImageURL, placeholderImage: Utils.placeholderImage())
                        
            let ratingLabels = Utils.getLabelsForRating(recipe.presentableRating)
            cell.ratingLabel.text = ratingLabels.textLabel
            cell.ratingLabel.accessibilityLabel = ratingLabels.accessibilityLabel
            
            cell.itemNumberLabel.text = "\(index + 1)."    // Convert 0-based index to 1-based item number.
            
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
    @IBOutlet weak var itemNumberLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var backdropView: UIView!
    
    override func setHighlighted(highlighted: Bool, animated: Bool)
    {
        // Workaround for bug (feature?) that sets any subviews' backgroundColor to (0,0,0,0) when its parent cell is selected.
        let backgroundColor = backdropView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        backdropView.backgroundColor = backgroundColor
    }
    
    override func setSelected(selected: Bool, animated: Bool)
    {
        // Workaround for bug (feature?) that sets any subviews' backgroundColor to (0,0,0,0) when its parent cell is selected.
        let backgroundColor = backdropView.backgroundColor
        super.setSelected(selected, animated: animated)
        backdropView.backgroundColor = backgroundColor
    }
}
