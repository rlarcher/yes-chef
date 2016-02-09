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
