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
    let rating: Float
    let reviewCount: Int
    let cuisine: Cuisine
    let category: Category
    let servingsQuantity: Int
    let imageURL: NSURL
    
    var speakableString: String {
        var string = "\(name)"
        
        if let presentableRating = self.presentableRating {
            string = "\(string): \(presentableRating) out of 5 stars."
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
    
    var presentableRating: String?
    {
        if reviewCount > 0 {
            if rating % 1 > 0 {
                return String(format: "%.1f", rating)
            }
            else {
                return String(format: "%.0f", rating)
            }
        }
        else {
            return nil
        }
    }
}
