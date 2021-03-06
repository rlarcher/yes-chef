//
//  SearchResultsViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SearchResultsConversationTopicEventHandler, UISearchBarDelegate
{
    var searchResultsConversationTopic: SearchResultsConversationTopic!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarOverlay: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Lifecycle
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.searchResultsConversationTopic = SearchResultsConversationTopic(eventHandler: self)
        self.presenter = SearchResultsPresenter(viewController: self, conversationTopic: self.searchResultsConversationTopic)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        // Suppress some thin lines that appear at the top and bottom of the search bar:
        searchBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        
        syncSearchBar()
        
        selectedNewCategory(searchParameters.course ?? .All)
        selectedNewCuisine(searchParameters.cuisine ?? .All)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        searchResultsConversationTopic.topicDidGainFocus()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        searchResultsConversationTopic.topicDidLoseFocus()
        
        super.viewWillDisappear(animated)
    }
    
    // Must be called immediately after instantiating the VC
    func updateListings(recipeListings: [RecipeListing], forSearchParameters parameters: SearchParameters)
    {
        self.recipeListings = recipeListings
        self.searchParameters = parameters
        
        self.searchResultsConversationTopic.updateListings(recipeListings, forSearchParameters: parameters)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView?.reloadData()
        }
    }
    
     // MARK: UISearchBarDelegate Protocol Methods
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool
    {
        searchBar.setShowsCancelButton(true, animated: true)
        
        presenter.presentSearchOptions(searchParameters, presentationFrame: tableView.frame, passthroughViews: [searchBarOverlay])
        
        return true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar)
    {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)    // Dismisses the SearchOptionsController
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        dismissViewControllerAnimated(true) {    // Dismisses the SearchOptionsController
            if let query = searchBar.text {
                self.searchParameters.query = query
                self.searchUsingParameters(self.searchParameters)
            }
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
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView?.selectRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
        }
    }
    
    func finishedSpeakingItemAtIndex(index: Int)
    {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView?.deselectRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: true)
        }
    }
    
    // MARK: UITableViewDelegate Protocol Methods
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let index = indexPath.row
        if index < recipeListings.count {
            let recipeListing = recipeListings[index]
            requestedRecipePresentationForListing(recipeListing)
        }
    }
    
    // MARK: UITableViewDataSource Protocol Methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let index = indexPath.row
        if
            let cell = tableView.dequeueReusableCellWithIdentifier("RecipeListingCell") as? RecipeListingCell
            where index < recipeListings.count
        {
            let recipeListing = recipeListings[index]
            cell.recipeNameLabel.text = recipeListing.name
            cell.thumbnailImageView.af_setImageWithURL(recipeListing.imageURL, placeholderImage: Utils.placeholderImage())
            
            cell.courseLabel.text = recipeListing.displayableCourseCuisine
            
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return recipeListings.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
        
    // MARK: Helpers
    
    func selectedNewCategory(category: Category)
    {
        searchParameters.course = category
    }
    
    func selectedNewCuisine(cuisine: Cuisine)
    {
        searchParameters.cuisine = cuisine
    }
    
    private func syncSearchBar()
    {
        dispatch_async(dispatch_get_main_queue()) { 
            self.searchBar.text = self.searchParameters.query
        }
    }
    
    @IBAction func backButtonTapped(sender: AnyObject)
    {
        presenter.popBack()
    }
    
    private func searchUsingParameters(parameters: SearchParameters)
    {
        BigOvenAPIManager.sharedManager.searchForRecipeWithParameters(parameters) { response -> Void in
            switch response {
            case .Success(let recipeListings):
                if recipeListings.count > 0 {
                    self.updateListings(recipeListings, forSearchParameters: parameters)
                    self.searchResultsConversationTopic.speakResults()
                }
                else {
                    self.notifyNoResultsForSearchParameters(parameters)
                }
            case .Failure(let errorMessage, _):
                self.presenter.presentErrorMessage(errorMessage)
            }
        }
    }
    
    private func requestedRecipePresentationForListing(recipeListing: RecipeListing)
    {
        BigOvenAPIManager.sharedManager.fetchRecipe(recipeListing.recipeId) { response -> Void in
            switch response {
            case .Success(let recipe):
                self.presenter.presentRecipe(recipe)
            case .Failure(let errorMessage, _):
                self.presenter.presentErrorMessage(errorMessage)
            }
        }
    }
    
    private func notifyNoResultsForSearchParameters(parameters: SearchParameters)
    {
        // TODO: If search was performed via search bar, re-highlight the search bar?
        searchResultsConversationTopic.speakNoResultsForSearchParameters(parameters)
    }
    
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
    
    private var presenter: SearchResultsPresenter!
}

class RecipeListingCell: UITableViewCell
{
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var itemNumberLabel: UILabel!
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
