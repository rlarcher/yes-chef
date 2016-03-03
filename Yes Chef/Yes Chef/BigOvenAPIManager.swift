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
        apiFetcher.searchForRecipeWithParameters(parameters) { (response) -> () in
            switch response {
            case .Success(let recipeListings):
                for listing in recipeListings {
                    self.fetchRecipe(listing.recipeId, completion: nil) // Prefetch corresponding recipes
                }
                completion(.Success(recipeListings: recipeListings))
            case .ConnectionError(let error):
                let errorMessage = error.userInfo[kUserFriendlyErrorMessageKey] as? String ?? "I encountered a problem while searching for recipes. Please try again later."
                completion(.Failure(message: errorMessage, error: error))
            case .UnexpectedBodyFormat(let error):
                let errorMessage = error.userInfo[kUserFriendlyErrorMessageKey] as? String ?? "I encountered a problem while searching for recipes."
                completion(.Failure(message: errorMessage, error: error))
            }
        }
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
                    let errorMessage = error.userInfo[kUserFriendlyErrorMessageKey] as? String ?? "I encountered a problem while looking up a recipe. Please try again later."
                    completion?(.Failure(message: errorMessage, error: error))
                case .UnexpectedBodyFormat(let error):
                    let errorMessage = error.userInfo[kUserFriendlyErrorMessageKey] as? String ?? "I encountered a problem while looking up a recipe."
                    completion?(.Failure(message: errorMessage, error: error))
                }
            })
        }
    }
    
    func fetchRecommendedRecipes(completion: (SearchResponse -> Void))
    {
        // TODO
        completion(.Success(recipeListings: Utils.stubRecipeListings()))
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
            UIImageView().af_setImageWithURL(recipe.heroImageURL, placeholderImage: nil)  // TODO: Add placeholder image
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
