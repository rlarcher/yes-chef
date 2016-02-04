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
    let name: String
    let rating: Int
    let ingredients: [Ingredient]
    let preparationSteps: [String]
    let preparationTime: NSTimeInterval
    let calories: Int
    let thumbnail: UIImage
    
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
}
