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
    func setRecipeListings(recipeListings: [RecipeListing], forSearchQuery query: String)
    {
        self.recipeListings = recipeListings
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
    
    func selectedItemWithName(name: String?, index: Int?)
    {
        if
            let listingName = name,
            let selectedListing = listingWithName(listingName)
        {
            requestedRecipePresentationForListing(selectedListing)
        }
        else if
            let listingIndex = index,
            let selectedListing = listingAtIndex(listingIndex)
        {
            requestedRecipePresentationForListing(selectedListing)
        }
        else {
            // TODO: Handle error / followup
        }
    }
    
    func handlePlayCommand()
    {
        print("SearchResultsVC handlePlayCommand")
        // TODO: Interact with the command bar playback controls - change middle button to Pause
    }
    
    func handlePauseCommand()
    {
        print("SearchResultsVC handlePauseCommand")
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
    
    // MARK: UITableViewDelegate Protocol Methods
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let index = indexPath.row
        if index < recipeListings.count {
            let recipeListing = recipeListings[index]
            requestedRecipePresentationForListing(recipeListing)
        }
    }
    
    // MARK: UITableViewDataSource Protocol Methods
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let index = indexPath.row
        if
            let cell = tableView.dequeueReusableCellWithIdentifier("RecipeListingCell") as? RecipeListingCell
            where index < recipeListings.count
        {
            let recipeListing = recipeListings[index]
            cell.recipeNameLabel.text = recipeListing.name
            cell.thumbnailImageView.af_setImageWithURL(recipeListing.thumbnailImageURL, placeholderImage: nil) // TODO: Add placeholder image
            cell.servingSizeLabel.text = "Serves: \(recipeListing.servingSize)"
            
            let ratingLabels = Utils.getLabelsForRating(recipeListing.rating)
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
        return recipeListings.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    // MARK: Helpers
    
    func listingWithName(name: String) -> RecipeListing?
    {
        let matchingListing = recipeListings.filter({ $0.name.lowercaseString == name.lowercaseString }).first // TODO: Improve how we check for a match
        return matchingListing
    }
    
    func listingAtIndex(index: Int) -> RecipeListing?
    {
        if index > 0 && index < recipeListings.count {
            return recipeListings[index]
        }
        else {
            return nil
        }
    }
    
    // MARK: Navigation Helpers
    
    private func requestedRecipePresentationForListing(recipeListing: RecipeListing)
    {
        BigOvenAPIManager.sharedManager.fetchRecipe(recipeListing.recipeId) { response -> Void in
            if let recipe = response.recipe {
                self.presentRecipe(recipe)
            }
            else {
                // TODO: Handle error
            }
        }
    }
    
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
    
    private var recipeListings: [RecipeListing]! {
        didSet {
            // Keeps searchResultsCT's recipeListings in sync with searchResultsVC's recipeListings.
            searchResultsConversationTopic.updateResults(recipeListings)
        }
    }
    private var query: String! {
        didSet {
            // Keeps searchResultsCT's query in sync with searchResultsVC's query.
            searchResultsConversationTopic.updateSearchQuery(query)
        }
    }
}

class RecipeListingCell: UITableViewCell
{
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var servingSizeLabel: UILabel!
}
