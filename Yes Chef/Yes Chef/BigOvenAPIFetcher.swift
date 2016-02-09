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
    // From http://api.bigoven.com/documentation/response-codes
//    Response Code 	Description
//    200 OK 	Request was fulfilled.
//    201 CREATED 	POST request successfully created entity.
//    400 BAD REQUEST 	Invalid request or rate limit exceeded.
//    403 FORBIDDEN 	Failed authentication request.
//    404 NOT FOUND 	Request URI invalid.
//    500 INTERNAL ERROR 	Server error has occurred.
    
    class func searchForRecipeByName(query: String, completion: (BigOvenAPIResponse -> ()))
    {
        let parameters = ["api_key": kAPIKey, "title_kw": query]

        BigOvenAPIFetcher.sessionManager.GET("recipes", parameters: parameters, progress: nil,
            success: { (task, responseObject) -> Void in
                // TODO
            }, failure: { (task, error) -> Void in
                // TODO
        })
    }
    
    private class func parseRecipeFromResponseObject(responseObject: AnyObject?)
    {
        if let responseJSON = responseObject as? JSON {
            // TODO
        }
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

struct BigOvenAPIResponse
{
    let recipe: Recipe?
    
    let bodyData: NSDictionary?
    let responseError: NSError?
    
    var didSucceed: Bool {
        return recipe != nil && responseError == nil
    }
}
