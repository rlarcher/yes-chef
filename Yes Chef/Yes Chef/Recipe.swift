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
    let recipeId: String
    let name: String
    let rating: Int
    let description: String
    let ingredients: [Ingredient]
    let preparationSteps: [String]
    let totalPreparationTime: Int // in minutes
    let activePreparationTime: Int // in minutes
    let servingSize: Int
    let calories: Int
    let thumbnailImageURL: NSURL
    let heroImageURL: NSURL
    
    var speakableString: String
    {
        return "\(name). \(rating) stars. \(description). Requires \(totalPreparationTime) minutes of preparation (\(activePreparationTime) minutes active)."
    }
}

struct Ingredient
{
    let ingredientId: String
    let name: String
    let quantityString: String
    let units: String
    let preparationNotes: String?
    
    var speakableString: String
    {
        if let notes = preparationNotes {
            return "\(quantityString) \(units) \(name) (\(notes))"
        }
        else {
            return "\(quantityString) \(units) \(name)"
        }
    }
}
