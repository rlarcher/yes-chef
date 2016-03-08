//
//  HomeViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UISearchBarDelegate, HomeConversationTopicEventHandler, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarOverlay: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var homeConversationTopic: HomeConversationTopic!
    
    required init?(coder aDecoder: NSCoder)
    {
        // Called as part of `storyboard.instantiateViewControllerWithIdentifier:` method.
        super.init(coder: aDecoder)
        self.homeConversationTopic = HomeConversationTopic(eventHandler: self)
        self.presenter = HomePresenter(viewController: self, conversationTopic: self.homeConversationTopic)
    }
    
    override func viewDidLoad()
    {
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self

        // Suppress some thin lines that appear at the top and bottom of the search bar:
        searchBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        
        refreshRecommendedRecipes()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        homeConversationTopic.topicDidGainFocus()
        
        homeConversationTopic.speakIntroduction(shouldSpeakFirstTimeIntroduction)
        shouldSpeakFirstTimeIntroduction = false
        
        selectedNewCuisine(.All)
        selectedNewCategory(.All)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        homeConversationTopic.topicDidLoseFocus()

    }
    
    // MARK: HomeConversationTopicEventHandler Protocol Methods
    
    func handleHelpCommand()
    {
        homeConversationTopic.speakHelpMessage()
    }
    
    func handleAvailableCommands()
    {
        // TODO: Present available commands list?
        homeConversationTopic.speakAvailableCommands()
    }
    
    func handleHomeCommand()
    {
        navigationController?.popToRootViewControllerAnimated(true)
        homeConversationTopic.speakIntroduction(false)
    }
    
    func handleBackCommand()
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func requestedSearchUsingParameters(searchParameters: SearchParameters)
    {
        selectedNewCategory(searchParameters.course)
        selectedNewCuisine(searchParameters.cuisine)
        self.searchParameters.query = searchParameters.query
        
        // TODO: Present intermediate "Loading" scene
        searchUsingParameters(searchParameters)
    }
    
    // MARK: UISearchBarDelegate Protocol Methods
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool
    {
        searchBar.setShowsCancelButton(true, animated: true)
        
        presenter.presentSearchOptions(searchParameters, presentationFrame: tableView.frame, passthroughViews: [searchBar])
        
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
    
    // MARK: UITableViewDelegate Protocol Methods
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let index = indexPath.row
        if index < recommendedListings.count {
            let recipeListing = recommendedListings[index]
            requestedRecipePresentationForListing(recipeListing)
        }
    }
    
    // MARK: UITableViewDataSource Protocol Methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let index = indexPath.row
        if
            let cell = tableView.dequeueReusableCellWithIdentifier("RecipeListingCell") as? RecipeListingCell
            where index < recommendedListings.count
        {
            let recipeListing = recommendedListings[index]
            cell.recipeNameLabel.text = recipeListing.name
            cell.thumbnailImageView.af_setImageWithURL(recipeListing.imageURL, placeholderImage: nil) // TODO: Add placeholder image
            
            cell.courseLabel.text = recipeListing.category == .All ? "" : recipeListing.category.rawValue   // Don't bother displaying "All Categories"
            
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
        return recommendedListings.count
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
    
    @IBAction func menuButtonTapped(sender: AnyObject)
    {
        presenter.presentMenu()
    }    
    
    private func searchUsingParameters(parameters: SearchParameters)
    {
        BigOvenAPIManager.sharedManager.searchForRecipeWithParameters(parameters) { response -> Void in
            switch response {
            case .Success(let recipeListings):
                if recipeListings.count > 0 {
                    self.presenter.presentSearchResults(recipeListings, forSearchParameters: parameters)
                }
                else {
                    self.notifyNoResultsForSearchParameters(parameters)
                }
            case .Failure(let errorMessage, _):
                self.presenter.presentErrorMessage(errorMessage)
            }
        }
    }
    
    private func refreshRecommendedRecipes()
    {
        BigOvenAPIManager.sharedManager.fetchRecommendedRecipes() { response in
            switch response {
            case .Success(let recipeListings):
                self.recommendedListings = recipeListings
                self.tableView.reloadData()
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
                self.presenter.presentRecipeDetails(recipe, shouldPopViewController: false)
            case .Failure(let errorMessage, _):
                self.presenter.presentErrorMessage(errorMessage)
            }
        }
    }
    
    private func notifyNoResultsForSearchParameters(parameters: SearchParameters)
    {
        // TODO: If search was performed via search bar, re-highlight the search bar?
        homeConversationTopic.speakNoResultsForSearchParameters(parameters)
    }
    
    private var recommendedListings = [RecipeListing]()
    private var searchParameters = SearchParameters.emptyParameters()
    private var shouldSpeakFirstTimeIntroduction = true
    private var presenter: HomePresenter!
}
