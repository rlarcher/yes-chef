//
//  SearchResultsViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

class SearchResultsViewController: UITableViewController, SearchResultsConversationTopicEventHandler, UISearchBarDelegate, CategoryCuisineSelectorEventHandler
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
        self.categoryCuisinePresenter = CategoryCuisinePresenter(presentingViewController: self, eventHandler: self)
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
    
    // MARK: IBAction Methods
    
    @IBAction func categoryButtonTapped(sender: AnyObject)
    {
        categoryCuisinePresenter.presentCategorySelector(initialCategory: activeCategory)
    }
    
    @IBAction func cuisineButtonTapped(sender: AnyObject)
    {
        categoryCuisinePresenter.presentCuisineSelector(initialCuisine: activeCuisine)
    }
    
    // MARK: UISearchBarDelegate Protocol Methods
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        if let query = searchBar.text {
            var category: Category? = nil
            if let categoryString = categoryButton.titleLabel?.text {
                category = Category(rawValue: categoryString)
            }
            
            var cuisine: Cuisine? = nil
            if let cuisineString = cuisineButton.titleLabel?.text {
                cuisine = Cuisine(rawValue: cuisineString)
            }
            
            searchUsingQuery(query, category: category, cuisine: cuisine)
        }
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
            cell.thumbnailImageView.af_setImageWithURL(recipeListing.thumbnailImageURL, placeholderImage: nil) // TODO: Add placeholder image
            cell.servingSizeLabel.text = "Serves: \(recipeListing.servingsQuantity)"
            
            let ratingLabels = Utils.getLabelsForRating(recipeListing.presentableRating)
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
    
    // MARK: CategoryCuisineSelectorEventHandler Protocol Methods
    
    func selectedNewCategory(category: Category)
    {
        activeCategory = category
        categoryButton.titleLabel?.text = category.rawValue
        categoryButton.updateConstraints()
    }
    
    func selectedNewCuisine(cuisine: Cuisine)
    {
        activeCuisine = cuisine
        cuisineButton.titleLabel?.text = cuisine.rawValue
        cuisineButton.updateConstraints()
    }
    
    private var categoryCuisinePresenter: CategoryCuisinePresenter!
    private var activeCategory = Category.All
    private var activeCuisine = Cuisine.All
    
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
