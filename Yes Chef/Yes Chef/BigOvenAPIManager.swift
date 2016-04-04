//
//  BigOvenAPIManager.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation
import AlamofireImage

class BigOvenAPIManager
{
    static var sharedManager: BigOvenAPIManager {
        get {
            if underlyingInstance == nil {
                underlyingInstance = BigOvenAPIManager(apiFetcher: BigOvenAPIFetcher())
            }
            
            return underlyingInstance!
        }
    }
    
    init(apiFetcher: BigOvenAPIFetcher)
    {
        self.apiFetcher = apiFetcher
    }
    
    func searchForRecipeWithParameters(parameters: SearchParameters, completion: (SearchResponse -> Void))
    {
        searchForRecipeWithParameters(parameters, pageNumber: 1, completion: completion)
    }
    
    // Performs an empty search for a random page, containing recipes determined by BigOven's default sorting algorithm.
    func fetchRecommendedRecipes(completion: (SearchResponse -> Void))
    {
        let emptySearchParameters = SearchParameters.emptyParameters()
        let randomPage = Int(arc4random_uniform(51) + 1) // Return one of the first 50 pages of a blank search
        
        searchForRecipeWithParameters(emptySearchParameters, pageNumber: randomPage, completion: completion)
    }
    
    func fetchRecipe(recipeId: String, completion: (RecipeResponse -> Void)?)
    {
        if let recipe = retrieveRecipeFromCache(recipeId) {
            completion?(.Success(recipe: recipe))
        }
        else {
            apiFetcher.recipeWithId(recipeId, completion: { (response) -> () in
                switch response {
                case .Success(let recipe):
                    self.addRecipeToCache(recipe)
                    completion?(.Success(recipe: recipe))
                case .ConnectionError(let error):
                    let errorMessage = error.userInfo[kUserFriendlyErrorMessageKey] as? String ?? _prompt("error:recipe_search_default_connection_error", comment: "Default message when we encounter a connection error during a recipe details search")
                    completion?(.Failure(message: errorMessage, error: error))
                case .UnexpectedBodyFormat(let error):
                    let errorMessage = error.userInfo[kUserFriendlyErrorMessageKey] as? String ?? _prompt("error:recipe_search_default_unexpected_error", comment: "Default message when we encounter an unexpected error during a recipe details search")
                    completion?(.Failure(message: errorMessage, error: error))
                }
            })
        }
    }

    private func searchForRecipeWithParameters(parameters: SearchParameters, pageNumber: Int, completion: (SearchResponse -> Void))
    {
        let listingsFetchManager = RecipeListingsFetchManager(apiManager: self, apiFetcher: apiFetcher)
        listingsFetchManager.fetchValidListings(parameters, pageNumber: pageNumber, completion: completion)
    }
    
    private let apiFetcher: BigOvenAPIFetcher
    static private var underlyingInstance: BigOvenAPIManager?
    
    // MARK: Recipe Caching
    
    // cache of recipes recently fetched
    // (stored as an array because we need to size-limit it FIFO, and it should be small enough to get away with the linear access time)
    private let kMaxRecipeCacheSize = 30
    private var recipeCache: [Recipe] = Utils.stubRecipes() // TODO: Temp stubbing. // = []
    private let cacheAccessQueue = dispatch_queue_create("com.conversantlabs.yeschef.BigOvenAPIManager.cacheAccessQueue", nil)
    
    private func addRecipeToCache(recipe: Recipe) {
        dispatch_sync(cacheAccessQueue) {
            self.recipeCache.append(recipe)
            if (self.recipeCache.count > self.kMaxRecipeCacheSize) {
                self.recipeCache.removeAtIndex(0)
            }
        }
        
        // TODO: revisit this strategy
        // pre-cache each item's thumbnail and hero image
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
            UIImageView().af_setImageWithURL(recipe.heroImageURL, placeholderImage: Utils.placeholderImage())
        })
    }
    
    private func retrieveRecipeFromCache(recipeId: String) -> Recipe? {
        var matches: [Recipe]!
        dispatch_sync(cacheAccessQueue) {
            matches = self.recipeCache.filter({ $0.recipeId == recipeId })
        }
        return matches.first
    }
}

enum SearchResponse
{
    case Success(recipeListings: [RecipeListing])
    case Failure(message: String, error: NSError)
}

enum RecipeResponse
{
    case Success(recipe: Recipe)
    case Failure(message: String, error: NSError)
}
