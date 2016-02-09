//
//  Recipe.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

struct Recipe
{
    let recipeID: String
    let name: String
    let rating: Float
    let ingredients: [Ingredient]
    let preparationSteps: [String]
    let preparationTime: NSTimeInterval
    let servingSize: Int
    let calories: Int
    let thumbnailURL: NSURL
    
    var preparationTimeMinutes: Int
    {
        return Int(ceil(preparationTime / 60.0))
    }
    
    var speakableString: String
    {
        return "\(name). \(rating) stars. Requires \(preparationTimeMinutes) minutes of preparation and \(ingredients.count) different ingredients."
    }
}

struct Ingredient
{
    let name: String
    let quantityString: String
    let units: String
    
    var speakableString: String
    {
        return "\(quantityString) \(units) \(name)"
    }
}
