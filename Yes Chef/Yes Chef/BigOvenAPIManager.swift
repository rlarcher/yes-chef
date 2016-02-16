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
    
    func searchForRecipeByName(query: String, category: Category?, cuisine: Cuisine?, completion: (SearchResponse -> Void))
    {
        apiFetcher.searchForRecipeByName(query, category: category?.rawValue, cuisine: cuisine?.rawValue) { (response) -> () in
            if let recipeListings = response.recipeListings where response.didSucceed {
                for listing in recipeListings {
                    self.fetchRecipe(listing.recipeId, completion: nil) // Prefetch corresponding recipes
                }
                completion(SearchResponse(recipeListings: recipeListings, error: nil))
            }
            else {
                let wrappedError = self.wrapSearchError(response.responseError!, bodyData: response.bodyData)
                completion(SearchResponse(recipeListings: nil, error: wrappedError))
            }
        }
    }
    
    func fetchRecipe(recipeId: String, completion: (RecipeResponse -> Void)?)
    {
        if let recipe = retrieveRecipeFromCache(recipeId) {
            completion?(RecipeResponse(recipe: recipe, error: nil))
        }
        else {
            apiFetcher.recipeWithId(recipeId, completion: { (response) -> () in
                if let recipe = response.recipe where response.didSucceed {
                    self.addRecipeToCache(recipe)
                    completion?(RecipeResponse(recipe: recipe, error: nil))
                }
                else {
                    let wrappedError = self.wrapRecipeError(response.responseError!, bodyData: response.bodyData)
                    completion?(RecipeResponse(recipe: nil, error: wrappedError))
                }
            })
        }
    }
    
    // MARK: Error Handling
    
    private func wrapSearchError(error: NSError, bodyData: NSDictionary?) -> NSError
    {
        // TODO
        return NSError(domain: "TODO", code: 0, userInfo: nil)
    }
    
    private func wrapRecipeError(error: NSError, bodyData: NSDictionary?) -> NSError
    {
        // TODO
        return NSError(domain: "TODO", code: 0, userInfo: nil)
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

struct SearchResponse
{
    let recipeListings: [RecipeListing]?
    let error: NSError?
}

struct RecipeResponse
{
    let recipe: Recipe?
    let error: NSError?
}

let kSearchErrorDomain = "searchErrorDomain"
enum SearchErrorCode: Int
{
    case LocalConnectionError = 1
    case ServerConnectionError = 2
    case UnexpectedResponseFormat = 3
}
let kSearchErrorUnderlyingJSONObjectKey = "SearchErrorUnderlyingJSONObjectKey"

let kRecipeErrorDomain = "recipeErrorDomain"
enum RecipeErrorCode: Int
{
    case LocalConnectionError = 1
    case ServerConnectionError = 2
    case UnexpectedResponseFormat = 3
}
let kRecipeErrorUnderlyingJSONObjectKey = "RecipeErrorUnderlyingJSONObjectKey"
