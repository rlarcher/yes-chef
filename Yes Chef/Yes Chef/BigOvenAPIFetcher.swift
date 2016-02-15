//
//  BigOvenAPIFetcher.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation
import AFNetworking
import Alamofire
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
    
    func searchForRecipeByName(query: String, category: String?, completion: (BigOvenAPISearchResponse -> ()))
    {
        if let apiKey = BigOvenAPIFetcher.kAPIKey {
            let parameters = ["api_key": apiKey, "any_kw": query, "pg": 1, "rpp": 10] as [String: AnyObject]
            // TODO: Add category parameter
            
            sessionManager.request(.GET, "http://api.bigoven.com/recipes", parameters: parameters)
                          .responseJSON { response in
                            switch response.result {
                            case .Success(let jsonObject):
                                if let listings = self.parseRecipeListingFromJSONObject(jsonObject) {
                                    completion(BigOvenAPISearchResponse(recipeListings: listings, bodyData: nil, responseError: nil))
                                }
                                else {
                                    // TODO: Handle parsing error
                                }
                            case .Failure(let error):
                                // TODO: Handle connection error
                                print(error)
                            }
            }
        }
        else {
            let stubRecipeListings = Utils.stubRecipeListings()
            
            completion(BigOvenAPISearchResponse(recipeListings: stubRecipeListings, bodyData: nil, responseError: nil))
            
            return
        }
    }
    
    func recipeWithId(recipeId: String, completion: (BigOvenAPIRecipeResponse -> ()))
    {
        if let apiKey = BigOvenAPIFetcher.kAPIKey {
            let parameters = ["api_key": apiKey] as [String: AnyObject]
            
            sessionManager.request(.GET, "http://api.bigoven.com/recipe/\(recipeId)", parameters: parameters)
                          .responseJSON { response in
                            switch response.result {
                            case .Success(let jsonObject):
                                if let recipe = self.parseRecipeFromJSONObject(jsonObject) {
                                    completion(BigOvenAPIRecipeResponse(recipe: recipe, bodyData: nil, responseError: nil))
                                }
                                else {
                                    // TODO: Handle parsing error
                                }
                            case .Failure(let error):
                                // TODO: Handle connection error
                                print(error)
                            }
            }
        }
        else {
            let stubRecipe = Utils.stubRecipes()[0]
            
            completion(BigOvenAPIRecipeResponse(recipe: stubRecipe, bodyData: nil, responseError: nil))
            return
        }
    }
    
    /// Returns nil if the response object and its "Results" array couldn't be read. 
    /// Returns an empty array if no results were found. 
    /// Otherwise returns an array of RecipeListing.
    private func parseRecipeListingFromJSONObject(jsonObject: AnyObject?) -> [RecipeListing]?
    {
        if let object = jsonObject {
            let root = JSON(object).dictionaryValue
            if let results = root["Results"]?.arrayValue {
                
                var recipeListings = [RecipeListing]()
                
                for result in results {
                    let recipeData = result.dictionaryValue
                    if
                        let rawRecipeID = recipeData["RecipeID"]?.int,
                        let recipeName = recipeData["Title"]?.string,
                        let ratingFloat = recipeData["StarRating"]?.float,
                        let servingSize = recipeData["YieldNumber"]?.int,
                        let thumbnailURLString = recipeData["ImageURL120"]?.string,
                        let thumbnailURL = NSURL(string: thumbnailURLString)
                    {
                        let rating = Int(round(ratingFloat))    // TODO: Revisit rounding? Maybe we want to round to nearest half?
                        
                        let listing = RecipeListing(recipeId: String(rawRecipeID), name: recipeName, rating: rating, servingSize: servingSize, thumbnailImageURL: thumbnailURL)
                        recipeListings.append(listing)
                    }
                }
                
                return recipeListings
            }
        }
        
        return nil
    }
    
    /// Returns a Recipe if all went well. Otherwise returns nil.
    private func parseRecipeFromJSONObject(jsonObject: AnyObject?) -> Recipe?
    {
        if let object = jsonObject {
            let root = JSON(object).dictionaryValue
            if
                let rawRecipeId             = root["RecipeID"]?.int,
                let recipeName              = root["Title"]?.string,
                let description             = root["Description"]?.string,
                let ratingFloat             = root["StarRating"]?.float,
                let heroImageURLString      = root["HeroPhotoUrl"]?.string,
                let heroImageURL            = NSURL(string: heroImageURLString),
                let ingredientsData         = root["Ingredients"]?.arrayValue,
                let ingredients             = parseIngredients(ingredientsData),
                let rawInstructions         = root["Instructions"]?.string,
                let servingSize             = root["YieldNumber"]?.int
            {
                let totalPreparationTime    = root["TotalMinutes"]?.int     // May be nil
                let activePreparationTime   = root["ActiveMinutes"]?.int    // May be nil
                
                let rating = Int(round(ratingFloat))    // TODO: Revisit rounding? Maybe we want to round to nearest half?
                let preparationSteps = parsePreparationSteps(rawInstructions)
                
                let recipe = Recipe(recipeId: String(rawRecipeId),
                                    name: recipeName,
                                    rating:rating,
                                    description: description,
                                    ingredients: ingredients,
                                    preparationSteps: preparationSteps,
                                    totalPreparationTime: totalPreparationTime,
                                    activePreparationTime: activePreparationTime,
                                    servingSize: servingSize,
                                    calories: 0,  // TODO: Handle NutrifionInfo
                                    heroImageURL: heroImageURL)
                return recipe
            }
        }

        return nil
    }
    
    /// Returns an array of ingredients parsed from the "Ingredients" JSON array.
    /// If there was an issue parsing any ingredient, returns nil.
    /// If there are no ingredients, returns an empty array.
    private func parseIngredients(ingredientsData: [JSON]) -> [Ingredient]?
    {
        var ingredients = [Ingredient]()
        for ingredientData in ingredientsData {
            let ingredientJSON = ingredientData.dictionaryValue
            if
                let rawIngredientId     = ingredientJSON["IngredientID"]?.int,
                let name                = ingredientJSON["Name"]?.string,
                let quantity            = ingredientJSON["DisplayQuantity"]?.string
            {
                let rawUnits            = ingredientJSON["Unit"]?.string                // Could be nil, an empty string (""), or a proper string.
                let units               = rawUnits == "" ? nil : rawUnits               // If BigOven's units are empty, just set ours to nil.
                
                let preparationNotes    = ingredientJSON["PreparationNotes"]?.string    // Could be nil, an empty string (""), or a proper string.
                let notes: String?      = preparationNotes == "" ? nil : preparationNotes    // If BigOven's notes are empty, just set ours to nil.
                
                let ingredient = Ingredient(ingredientId: String(rawIngredientId), name: name, quantityString: quantity, units: units, preparationNotes: notes)
                ingredients.append(ingredient)
            }
            else {
                return nil
            }
        }
        
        return ingredients
    }
    
    private func parsePreparationSteps(rawInstructions: String) -> [String]
    {
        // TODO: Revisit preparation parsing to account for the various ways contributors might write steps. (Sentence-separated, paragraph-separated, numbered paragraph-separated, external link)
        var cleanedInstructions = rawInstructions
        cleanedInstructions = cleanedInstructions.stringByReplacingOccurrencesOfString("\r", withString: "")
        cleanedInstructions = cleanedInstructions.stringByReplacingOccurrencesOfString("\n", withString: "")
        cleanedInstructions = cleanedInstructions.stringByReplacingOccurrencesOfString("\\d+.", withString: "", options: .RegularExpressionSearch, range: nil)
        
        let steps = cleanedInstructions.componentsSeparatedByString(".")
        
        return steps
    }
    
    private let sessionManager: Alamofire.Manager = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.HTTPAdditionalHeaders = ["Content-Type": "application/json", "Accept": "application/json"]
        
        return Alamofire.Manager(configuration: config)
    }()
    
    private static let kAPIKey: String? = nil // NOTE: Replace this with your own BigOven API key, or leave as is to receive stubbed responses.
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
