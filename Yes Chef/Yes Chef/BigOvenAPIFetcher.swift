//
//  BigOvenAPIFetcher.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation
import AFNetworking
import SwiftyJSON

class BigOvenAPIFetcher: NSObject
{
//    From http://api.bigoven.com/documentation/response-codes
//    Response Code 	Description
//    200 OK 	Request was fulfilled.
//    201 CREATED 	POST request successfully created entity.
//    400 BAD REQUEST 	Invalid request or rate limit exceeded.
//    403 FORBIDDEN 	Failed authentication request.
//    404 NOT FOUND 	Request URI invalid.
//    500 INTERNAL ERROR 	Server error has occurred.
    
    class func searchForRecipeByName(query: String, completion: (BigOvenAPISearchResponse -> ()))
    {
        let parameters = ["api_key": kAPIKey, "title_kw": query]

        BigOvenAPIFetcher.sessionManager.GET("recipes", parameters: parameters, progress: nil,
            success: { (task, responseObject) -> Void in
                if let listings = BigOvenAPIFetcher.parseRecipeListingFromResponseObject(responseObject) {
                    completion(BigOvenAPISearchResponse(recipeListings: listings, bodyData: nil, responseError: nil))
                }
                else {
                    // TODO: Handle error
                }
            }, failure: { (task, error) -> Void in
                // TODO: Handle error
        })
    }
    
    class func recipeWithID(recipeId: String, completion: (BigOvenAPIRecipeResponse -> ()))
    {
        let parameters = ["api_key": kAPIKey]
        
        BigOvenAPIFetcher.sessionManager.GET("recipe/\(recipeId)", parameters: parameters, progress: nil,
            success: { (task, responseObject) -> Void in
                if let recipe = BigOvenAPIFetcher.parseRecipeFromResponseObject(responseObject) {
                    completion(BigOvenAPIRecipeResponse(recipe: recipe, bodyData: nil, responseError: nil))
                }
                else {
                    // TODO: Handle error
                }
            }, failure: { (task, error) -> Void in
                // TODO: Handle error
        })
    }
    
    /// Returns nil if the response object and its "Results" array couldn't be read. 
    /// Returns an empty array if no results were found. 
    /// Otherwise returns an array of RecipeListing.
    private class func parseRecipeListingFromResponseObject(responseObject: AnyObject?) -> [RecipeListing]?
    {
        if let object = responseObject {
            let root = JSON(object).dictionaryValue
            if let results = root["Results"]?.arrayValue {
                
                var recipeListings = [RecipeListing]()
                
                for recipeData in results {
                    if
                        let recipeID = recipeData["RecipeID"].string,
                        let recipeName = recipeData["Title"].string,
                        let ratingFloat = recipeData["StarRating"].float,
                        let thumbnailURLString = recipeData["ImageURL48"].string,
                        let thumbnailURL = NSURL(string: thumbnailURLString)
                    {
                        let rating = Int(round(ratingFloat))    // TODO: Revisit rounding? Maybe we want to round to nearest half?
                        
                        let listing = RecipeListing(recipeID: recipeID, name: recipeName, rating: rating, thumbnailImageURL: thumbnailURL)
                        recipeListings.append(listing)
                    }
                }
                
                return recipeListings
            }
        }
        
        return nil
    }
    
    /// Returns a Recipe if all went well. Otherwise returns nil.
    private class func parseRecipeFromResponseObject(responseObject: AnyObject?) -> Recipe?
    {
        if let object = responseObject {
            let root = JSON(object).dictionaryValue
            if
                let recipeId                = root["RecipeID"]?.string,
                let recipeName              = root["Title"]?.string,
                let description             = root["Description"]?.string,
                let ratingFloat             = root["StarRating"]?.float,
                let thumbnailURLString      = root["ImageURL48"]?.string,
                let thumbnailURL            = NSURL(string: thumbnailURLString),
                let heroImageURLString      = root["HeroPhotoUrl"]?.string,
                let heroImageURL            = NSURL(string: heroImageURLString),
                let ingredientsData         = root["Ingredients"]?.arrayValue,
                let ingredients             = parseIngredients(ingredientsData),
                let rawInstructions         = root["Instructions"]?.string,
                let preparationSteps        = parsePreparationSteps(rawInstructions),
                let totalPreparationTime    = root["TotalTime"]?.int,
                let activePreparationTime   = root["ActiveMinutes"]?.int,
                let servingSize             = root["YieldNumber"]?.int,
                let calories                = root["NutritionInfo"]?["TotalCalories"].int // TODO: Confirm this is available with the Basic plan
            {
                let rating = Int(round(ratingFloat))    // TODO: Revisit rounding? Maybe we want to round to nearest half?
                
                let recipe = Recipe(recipeID: recipeId,
                                    name: recipeName,
                                    rating:rating,
                                    description: description,
                                    ingredients: ingredients,
                                    preparationSteps: preparationSteps,
                                    totalPreparationTime: totalPreparationTime,
                                    activePreparationTime: activePreparationTime,
                                    servingSize: servingSize,
                                    calories: calories,
                                    thumbnailImageURL: thumbnailURL,
                                    heroImageURL: heroImageURL)
                return recipe
            }
        }

        return nil
    }
    
    /// Returns an array of ingredients parsed from the "Ingredients" JSON array.
    /// If there was an issue parsing any ingredient, returns nil.
    /// If there are no ingredients, returns an empty array.
    private class func parseIngredients(ingredientsData: [JSON]) -> [Ingredient]?
    {
        var ingredients = [Ingredient]()
        for ingredientData in ingredientsData {
            if
                let ingredientId        = ingredientData["IngredientID"].string,
                let name                = ingredientData["Name"].string,
                let quantityString      = ingredientData["DisplayQuantity"].string,
                let units               = ingredientData["Unit"].string,
                let preparationNotes    = ingredientData["PreparationNotes"].string
            {
                let notes: String? = preparationNotes == "null" ? nil : preparationNotes // If BigOven's notes are "null", just set ours to nil.
                let ingredient = Ingredient(ingredientID: ingredientId, name: name, quantityString:  quantityString, units: units, preparationNotes: notes)
                ingredients.append(ingredient)
            }
            else {
                return nil
            }
        }
        
        return ingredients
    }
    
    private class func parsePreparationSteps(rawInstructions: String) -> [String]?
    {
        // TODO
        return nil
    }
    
    private static let sessionManager: AFHTTPSessionManager = {
        let url = NSURL(string: "http://api.bigoven.com/")!

        let manager = AFHTTPSessionManager(baseURL: url)
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        return manager
    }()
    
    private static let kAPIKey = "12345678"
}

struct BigOvenAPISearchResponse
{
    let recipeListings: [RecipeListing]?
    
    let bodyData: NSDictionary?
    let responseError: NSError?
    
    var didSucceed: Bool {
        return recipeListings != nil && responseError == nil
    }
}

struct BigOvenAPIRecipeResponse
{
    let recipe: Recipe?
    
    let bodyData: NSDictionary?
    let responseError: NSError?
    
    var didSucceed: Bool {
        return recipe != nil && responseError == nil
    }
}
