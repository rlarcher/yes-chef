//
//  RecipeListing.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2/9/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

struct RecipeListing
{
    let recipeId: String
    let name: String
    let rating: Int
    let reviewCount: Int
    let servingsQuantity: Int
    let thumbnailImageURL: NSURL
    
    var speakableString: String {
        var string = "\(name)."
        
        if reviewCount > 0 {
            string = "\(string) \(rating) out of 5 stars."
        }
        
        if servingsQuantity > 0 {
            string = "\(string) \(presentableServingsText)"
        }
        
        return string
    }
    
    var presentableServingsText: String
    {
        if servingsQuantity > 0 {
            return "Serves: \(servingsQuantity)"    // Note: Serving units aren't specified in search results API. Assume they're "servings", not some other unit (like cups, or count).
        }
        else {
            return ""
        }
    }
    
    var presentableRating: Int? {
        return reviewCount > 0 ? rating : nil
    }
}
