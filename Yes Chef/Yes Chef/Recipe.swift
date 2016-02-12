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
    let totalPreparationTime: Int?  // in minutes. If nil, then the poster didn't define a time.
    let activePreparationTime: Int? // in minutes. If nil, then the poster didn't define a time.
    let servingSize: Int
    let calories: Int
    let heroImageURL: NSURL
    
    var speakableString: String
    {
        // Construct speakable string piece by piece, depending on what we have available.
        var string = "\(name). \(rating) stars. \(description)."
        
        // Append total prep time, if we have it.
        if let totalTime = totalPreparationTime {
            string = "\(string) Requires \(totalTime) minutes of preparation."
        }
        
        // Append active prep time, if we have it.
        if let activeTime = activePreparationTime {
            string = "\(string) (\(activeTime) minutes active)"
        }
        
        return string
    }
}

struct Ingredient
{
    let ingredientId: String
    let name: String
    let quantityString: String
    let units: String?
    let preparationNotes: String?
    
    var speakableString: String
    {
        // Construct speakable string piece by piece, depending on what we have available.
        var string = quantityString
        
        // Append units, if we have them.
        if let usableUnits = units {
            string = "\(string) \(usableUnits)"
        }
        
        // Append name of ingredient.
        string = "\(string) \(name)"
        
        // Append preparation notes, if we have them.
        if let notes = preparationNotes {
            string = "\(string) (\(notes))"
        }
        
        // Return completed string. Some examples could be "3 dozen eggs (scrambled)", "one chicken", "1/3 cup butter", etc.
        return string
    }
}
