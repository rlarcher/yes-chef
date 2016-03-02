//
//  SearchResultsViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

class SearchResultsViewController: UITableViewController, SearchResultsConversationTopicEventHandler, UISearchBarDelegate, SelectorPresenterEventHandler
{
    var searchResultsConversationTopic: SearchResultsConversationTopic!
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var categoryButton: UIButton!
    @IBOutlet var cuisineButton: UIButton!
    
    // MARK: Lifecycle
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.searchResultsConversationTopic = SearchResultsConversationTopic(eventHandler: self)
        self.selectorPresenter = SelectorPresenter(presentingViewController: self, eventHandler: self)
    }
    
    // Must be called immediately after instantiating the VC
    func setRecipeListings(recipeListings: [RecipeListing], forSearchParameters parameters: SearchParameters)
    {
        self.recipeListings = recipeListings
        self.searchParameters = parameters
        
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView?.reloadData()
        }
    }
    
    override func viewDidLoad()
    {
        searchBar.delegate = self
        
        selectedNewCategory(searchParameters.course)
        selectedNewCuisine(searchParameters.cuisine)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        searchResultsConversationTopic.topicDidGainFocus()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        searchResultsConversationTopic.topicDidLoseFocus()
    }
    
    // MARK: IBAction Methods
    
    @IBAction func categoryButtonTapped(sender: AnyObject)
    {
        selectorPresenter.presentCategorySelector(initialCategory: searchParameters.course)
    }
    
    @IBAction func cuisineButtonTapped(sender: AnyObject)
    {
        selectorPresenter.presentCuisineSelector(initialCuisine: searchParameters.cuisine)
    }
    
    // MARK: UISearchBarDelegate Protocol Methods
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool
    {
        searchBar.setShowsCancelButton(true, animated: true)
        
        return true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar)
    {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        if let query = searchBar.text {
            searchParameters.query = query
            searchUsingParameters(searchParameters)
        }
        
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
    
    // MARK: ListConversationTopicEventHandler Protocol Methods
    
    func selectedRecipeListing(recipeListing: RecipeListing?)
    {
        if let selectedListing = recipeListing {
            requestedRecipePresentationForListing(selectedListing)
        }
        else {
            // TODO: Visual feedback?
            print("SearchResultsVC selectedRecipeListing, couldn't select a listing.")
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
            cell.thumbnailImageView.af_setImageWithURL(recipeListing.imageURL, placeholderImage: nil) // TODO: Add placeholder image
            
            cell.servingSizeLabel.text = recipeListing.presentableServingsText
            
            let ratingLabels = Utils.getLabelsForRating(recipeListing.presentableRating)
            cell.ratingLabel.text = ratingLabels.textLabel
            cell.ratingLabel.accessibilityLabel = ratingLabels.accessibilityLabel
            
            cell.itemNumberLabel.text = "\(index + 1)."   // Convert 0-based index to 1-based item number.
            
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
    
    // MARK: Navigation Helpers
    
    private func requestedRecipePresentationForListing(recipeListing: RecipeListing)
    {
        BigOvenAPIManager.sharedManager.fetchRecipe(recipeListing.recipeId) { response -> Void in
            switch response {
            case .Success(let recipe):
                self.presentRecipe(recipe)
            case .Failure(let errorMessage, _):
                self.presentErrorMessage(errorMessage)
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
    
    private func presentErrorMessage(message: String)
    {
        // TODO: GUI component? Popup?
        searchResultsConversationTopic.speakErrorMessage(message)
    }
    
    // MARK: SelectorPresenterEventHandler Protocol Methods
    
    func selectedNewCategory(category: Category)
    {
        searchParameters.course = category
        dispatch_async(dispatch_get_main_queue()) {
            self.categoryButton.setTitle(category.rawValue, forState: .Normal)
            self.categoryButton.updateConstraints()
        }
    }
    
    func selectedNewCuisine(cuisine: Cuisine)
    {
        searchParameters.cuisine = cuisine
        dispatch_async(dispatch_get_main_queue()) {
            self.cuisineButton.setTitle(cuisine.rawValue, forState: .Normal)
            self.cuisineButton.updateConstraints()
        }
    }
    
    func selectorCancelButtonTapped()
    {
        dispatch_async(dispatch_get_main_queue()) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    private func searchUsingParameters(parameters: SearchParameters)
    {
        BigOvenAPIManager.sharedManager.searchForRecipeWithParameters(parameters) { response -> Void in
            switch response {
            case .Success(let recipeListings):
                if recipeListings.count > 0 {
                    self.setRecipeListings(recipeListings, forSearchParameters: parameters)
                    self.searchResultsConversationTopic.speakResults()
                }
                else {
                    self.notifyNoResultsForSearchParameters(parameters)
                }
            case .Failure(let errorMessage, _):
                self.presentErrorMessage(errorMessage)
            }
        }
    }
    
    private func notifyNoResultsForSearchParameters(parameters: SearchParameters)
    {
        // TODO: If search was performed via search bar, re-highlight the search bar?
        searchResultsConversationTopic.speakNoResultsForSearchParameters(parameters)
    }
    
    private var selectorPresenter: SelectorPresenter!
    
    private var recipeListings: [RecipeListing]! {
        didSet {
            // Keeps searchResultsCT's recipeListings in sync with searchResultsVC's recipeListings.
            searchResultsConversationTopic.updateResults(recipeListings)
        }
    }
    private var searchParameters: SearchParameters! {
        didSet {
            // Keeps searchResultsCT's search parameters in sync with searchResultsVC's.
            searchResultsConversationTopic.updateSearchParameters(searchParameters)
        }
    }
}

class RecipeListingCell: UITableViewCell
{
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var servingSizeLabel: UILabel!
    @IBOutlet weak var itemNumberLabel: UILabel!
}
