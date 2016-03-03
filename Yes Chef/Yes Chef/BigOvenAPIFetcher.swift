//
//  BigOvenAPIFetcher.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class BigOvenAPIFetcher: NSObject
{
    func searchForRecipeWithParameters(parameters: SearchParameters, completion: (BigOvenAPISearchResponse -> ()))
    {
        if let apiKey = BigOvenAPIFetcher.kAPIKey {
            
            var searchQuery = parameters.query
            let cuisine = parameters.cuisine
            let course = parameters.course
            
            // Since we can't yet search by Cuisine, prefix the search query with the cuisine. Should result in queries like "Japanese shrimp", "Cuban pastries".
            if cuisine != .All && !searchQuery.fuzzyContains(cuisine.rawValue) { // If the search query already contains the cuisine's name, we don't need to do add it.
                searchQuery = "\(cuisine) \(searchQuery)"
            }
            // TODO: Add cuisine parameter for reals
            
            var parameters = ["api_key": apiKey, "any_kw": searchQuery, "pg": 1, "rpp": 10] as [String: AnyObject]
            
            if course != .All {
                parameters["include_primarycat"] = course.rawValue
            }
            
            sessionManager.request(.GET, "http://api.bigoven.com/recipes", parameters: parameters)
                          .responseJSON { response in
                            switch response.result {
                            case .Success(let jsonObject):
                                completion(self.validateSearchSuccess(jsonObject))
                            case .Failure(let error):
                                completion(self.validateSearchFailure(error))
                            }
            }
        }
        else {
            completion(.Success(recipeListings: Utils.stubRecipeListings()))
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
                                completion(self.validateRecipeSuccess(jsonObject))
                            case .Failure(let error):
                                completion(self.validateRecipeFailure(error))
                            }
            }
        }
        else {
            completion(.Success(recipe: Utils.stubRecipes()[0]))
        }
    }
    
    // MARK: API Response Validation Helpers
    
    private func validateSearchSuccess(jsonObject: AnyObject) -> BigOvenAPISearchResponse
    {
        if let listings = self.parseRecipeListingFromJSONObject(jsonObject) {
            return .Success(recipeListings: listings)
        }
        else {
            return .UnexpectedBodyFormat(error: buildParsingError(jsonObject))
        }
    }
    
    private func validateSearchFailure(error: NSError) -> BigOvenAPISearchResponse
    {
        return .ConnectionError(error: buildConnectionError(error))
    }
    
    private func validateRecipeSuccess(jsonObject: AnyObject) -> BigOvenAPIRecipeResponse
    {
        if let recipe = self.parseRecipeFromJSONObject(jsonObject) {
            return .Success(recipe: recipe)
        }
        else {
            return .UnexpectedBodyFormat(error: buildParsingError(jsonObject))
        }
    }
    
    private func validateRecipeFailure(error: NSError) -> BigOvenAPIRecipeResponse
    {
        return .ConnectionError(error: buildConnectionError(error))
    }
    
    // MARK: Parsing Helpers
    
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
                        let rawRecipeID         = recipeData["RecipeID"]?.int,
                        let recipeName          = recipeData["Title"]?.string,
                        let rating              = recipeData["StarRating"]?.float,
                        let reviewCount         = recipeData["ReviewCount"]?.int,
                        let yieldNumber         = recipeData["YieldNumber"]?.int,
                        let imageURLString      = recipeData["ImageURL"]?.string,
                        let imageURL            = NSURL(string: imageURLString)
                    {
                        let cuisine = parseCuisineFromData(recipeData)
                        let course = parseCourseFromData(recipeData)
                        
                        let listing = RecipeListing(recipeId: String(rawRecipeID), name: recipeName, rating: rating, reviewCount: reviewCount, cuisine: cuisine, category: course, servingsQuantity: yieldNumber, imageURL: imageURL)
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
                let rating                  = root["StarRating"]?.float,
                let heroImageURLString      = root["HeroPhotoUrl"]?.string,
                let heroImageURL            = NSURL(string: heroImageURLString),
                let ingredientsData         = root["Ingredients"]?.arrayValue,
                let ingredients             = parseIngredients(ingredientsData),
                let rawInstructions         = root["Instructions"]?.string,
                let yieldNumber             = root["YieldNumber"]?.int,
                let yieldUnit               = root["YieldUnit"]?.string,
                let reviewCount             = root["ReviewCount"]?.int
            {
                let rawTotalPrepTime = root["TotalMinutes"]?.int                              // Could be nil, 0, or a proper number.
                let totalPreparationTime = rawTotalPrepTime == 0 ? nil : rawTotalPrepTime     // If BigOven's time is 0, just set ours to nil.
                
                let rawActivePrepTime = root["ActiveMinutes"]?.int                            // Could be nil, 0, or a proper number.
                let activePreparationTime = rawActivePrepTime == 0 ? nil : rawActivePrepTime  // If BigOven's time is 0, just set ours to nil.
                
                let preparationSteps = parsePreparationSteps(rawInstructions)
                
                let cuisine = parseCuisineFromData(root)
                let course = parseCourseFromData(root)
                
                let subcategory             = root["Subcategory"]?.string ?? ""
                
                let recipe = Recipe(recipeId: String(rawRecipeId),
                                    name: recipeName,
                                    rating:rating,
                                    reviewCount: reviewCount,
                                    description: description,
                                    cuisine: cuisine,
                                    category: course,
                                    subcategory: subcategory,
                                    ingredients: ingredients,
                                    preparationSteps: preparationSteps,
                                    totalPreparationTime: totalPreparationTime,
                                    activePreparationTime: activePreparationTime,
                                    servingsQuantity: yieldNumber,
                                    servingsUnit: yieldUnit,
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
            if let rawIngredientId      = ingredientJSON["IngredientID"]?.int {
                let name                = ingredientJSON["Name"]?.string ?? "Unnamed Ingredient"    // Could be nil :(
                
                let rawUnits            = ingredientJSON["Unit"]?.string                // Could be nil, an empty string (""), or a proper string.
                let units               = rawUnits == "" ? nil : rawUnits               // If BigOven's units are empty, just set ours to nil.
                
                let rawQuantity         = ingredientJSON["DisplayQuantity"]?.string     // Could be nil, an empty string (""), or a proper string.
                let quantity            = rawQuantity == "" ? nil : rawQuantity         // If BigOven's quantity is empty, just set ours to nil.
                
                let preparationNotes    = ingredientJSON["PreparationNotes"]?.string    // Could be nil, an empty string (""), or a proper string.
                let notes               = preparationNotes == "" ? nil : preparationNotes    // If BigOven's notes are empty, just set ours to nil.
                
                let ingredient = Ingredient(ingredientId: String(rawIngredientId), name: name, quantityString: quantity, units: units, preparationNotes: notes)
                ingredients.append(ingredient)
            }
            else {
                print("Couldn't parse ingredient. Data: \(ingredientData)")
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
    
    private func parseCuisineFromData(root: [String: JSON]) -> Cuisine
    {
        var cuisine = Cuisine.All
        if
            let cuisineString = root["Cuisine"]?.string,                      // Could be nil, empty (""), or a proper string.
            let parsedCuisine = Cuisine(rawValue: cuisineString)              // If `cuisineString` is a proper string, we should be able to create a Cuisine out of it.
        {
            cuisine = parsedCuisine
        }
        
        return cuisine
    }
    
    private func parseCourseFromData(root: [String: JSON]) -> Category
    {
        var category = Category.All
        if
            let categoryString = root["Category"]?.string,                    // Could be nil, empty (""), or a proper string.
            let parsedCategory = Category(rawValue: categoryString)           // If `categoryString` is a proper string, we should be able to create a Category out of it.
        {
            category = parsedCategory
        }
        
        return category
    }
    
    // MARK: Error Handling
    
    private func buildParsingError(underlyingJSONObject: AnyObject) -> NSError
    {
        let parsingError = NSError(
            domain: kBigOvenAPIFetcherErrorDomain,
            code: BigOvenAPIFetcherErrorCode.UnexpectedResponseFormat.rawValue,
            userInfo: [kUnderlyingJSONObjectKey: underlyingJSONObject])
        
        return parsingError
    }
    
    //    From http://api.bigoven.com/documentation/response-codes
    //    Response Code 	Description
    //    200 OK 	Request was fulfilled.
    //    201 CREATED 	POST request successfully created entity.
    //    400 BAD REQUEST 	Invalid request or rate limit exceeded.
    //    403 FORBIDDEN 	Failed authentication request.
    //    404 NOT FOUND 	Request URI invalid.
    //    500 INTERNAL ERROR 	Server error has occurred.
    
    private func buildConnectionError(underlyingError: NSError) -> NSError
    {
        let connectionError: NSError
        
        if underlyingError.domain == NSURLErrorDomain && underlyingError.code == NSURLErrorNotConnectedToInternet {
            connectionError = NSError(
                domain: kBigOvenAPIFetcherErrorDomain,
                code: BigOvenAPIFetcherErrorCode.ConnectionOffline.rawValue,
                userInfo: [kUserFriendlyErrorMessageKey: "The internet connection appears to be offline. Please check your connection and try again.",
                    NSUnderlyingErrorKey: underlyingError])
        }
        else if underlyingError.domain == NSURLErrorDomain && underlyingError.code == NSURLErrorTimedOut {
            connectionError = NSError(
                domain: kBigOvenAPIFetcherErrorDomain,
                code: BigOvenAPIFetcherErrorCode.ConnectionTimedOut.rawValue,
                userInfo: [kUserFriendlyErrorMessageKey: "The internet connection has timed out. Please check your connection and try again.",
                    NSUnderlyingErrorKey: underlyingError])
        }
        else {
            connectionError = NSError(
                domain: kBigOvenAPIFetcherErrorDomain,
                code: BigOvenAPIFetcherErrorCode.ServerConnectionError.rawValue,
                userInfo: [kUserFriendlyErrorMessageKey: "There was a problem connecting to the server. Please try again later.",
                    NSUnderlyingErrorKey: underlyingError])
        }
        
        return connectionError
    }
    
    private let sessionManager: Alamofire.Manager = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.HTTPAdditionalHeaders = ["Content-Type": "application/json", "Accept": "application/json"]
        
        return Alamofire.Manager(configuration: config)
    }()
    
    private static let kAPIKey: String? = nil // NOTE: Replace this with your own BigOven API key, or leave as is to receive stubbed responses.
}

enum BigOvenAPISearchResponse
{
    case Success(recipeListings: [RecipeListing])
    case ConnectionError(error: NSError)
    case UnexpectedBodyFormat(error: NSError)
}

enum BigOvenAPIRecipeResponse
{
    case Success(recipe: Recipe)
    case ConnectionError(error: NSError)
    case UnexpectedBodyFormat(error: NSError)
}

let kBigOvenAPIFetcherErrorDomain = "BigOvenAPIFetcherErrorDomain"
enum BigOvenAPIFetcherErrorCode: Int
{
    case ConnectionOffline = 1
    case ConnectionTimedOut = 2
    case ServerConnectionError = 3
    case UnexpectedResponseFormat = 4
}

let kUnderlyingJSONObjectKey = "UnderlyingJSONObjectKey"
let kUserFriendlyErrorMessageKey = "UserFriendlyErrorMessageKey"
