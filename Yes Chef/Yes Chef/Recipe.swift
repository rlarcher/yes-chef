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
    let rating: Float
    let reviewCount: Int
    let description: String
    let cuisine: Cuisine
    let category: Category
    let subcategory: String
    let ingredients: [Ingredient]
    let preparationSteps: [String]
    let rawPreparationSteps: String
    let totalPreparationTime: Int?  // in minutes. If nil, then the poster didn't define a time.
    let activePreparationTime: Int? // in minutes. If nil, then the poster didn't define a time.
    let servingsQuantity: Int
    let servingsUnit: String
    let calories: Int
    let heroImageURL: NSURL
    
    var speakableString: String
    {
        // Construct speakable string piece by piece, depending on what we have available.
        var string = "\(name)."
        
        // Append rating, if there have been any reviews (suppress 0-star rating due to 0 reviews).
        if let presentableRating = self.presentableRating {
            string = "\(string) \(presentableRating) out of 5 stars."
        }
        
        if servingsQuantity > 0 {
            string = "\(string) \(presentableServingsText)."
        }
        
        // Append truncated description.
        string = "\(string) \(truncatedDescription)."
        
        // Append total prep time, if we have it.
        if let totalTime = totalPreparationTime where totalTime > 0 {
            string = "\(string) Requires \(totalTime) minutes of preparation."
            
            // Append active prep time, if we have it.
            if let activeTime = activePreparationTime where activeTime > 0 {
                string = "\(string) (\(activeTime) minutes active)"
            }
        }
        
        return string
    }
    
    var truncatedDescriptionAvailable: Bool {
        return description != truncatedDescription
    }
    
    var truncatedDescription: String
    {
        let descriptionSentences = description.componentsSeparatedByString(". ")
        if descriptionSentences.count > 0 {
            return descriptionSentences[0]
        }
        else {
            return description
        }
    }
    
    var presentableDescription: String
    {
        if description.isBlank {
            return _prompt("recipe_details:blank_description", comment: "Presented instead of a blank description")
        }
        else {
            return description
        }
    }
    
    var presentableServingsText: String
    {
        if servingsQuantity > 0 {
            if servingsUnit.lowercaseString == "serving" || servingsUnit.lowercaseString == "servings" {
                return "Serves: \(servingsQuantity)"
            }
            else {
                return "Makes: \(servingsQuantity) \(servingsUnit)"
            }
        }
        else {
            return ""
        }
    }
    
    var speakableServingsText: String
    {
        if servingsQuantity > 0 {
            if servingsUnit.lowercaseString == "serving" || servingsUnit.lowercaseString == "servings" {
                let format = _prompt("recipe_details:serves_X", comment: "Spoken when the recipe has unitless serving information")
                return String(format: format, servingsQuantity)
            }
            else {
                let format = _prompt("recipe_details:makes_X_units_Y", comment: "Spoken when the recipe has clearly defined quantity and unit")
                return String(format: format, servingsQuantity, servingsUnit)
            }
        }
        else {
            return _prompt("recipe_details:unknown_servings", comment: "Spoken in response to a servings query, but serving size is unknown")
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
    
    var listing: RecipeListing {
        return RecipeListing(recipeId: recipeId,
                             name: name,
                             rating: rating,
                             reviewCount: reviewCount,
                             cuisine: cuisine,
                             category: category,
                             servingsQuantity: servingsQuantity,
                             imageURL: heroImageURL)
    }
    
    var isUsable: Bool {
        // If the preparation steps are just a link to an external site, count this recipe as unusable.
        return !Utils.stringIsMostlyURL(self.rawPreparationSteps)
    }
}

struct Ingredient
{
    let ingredientId: String
    let name: String
    let quantityString: String?
    let units: String?
    let preparationNotes: String?
    
    var speakableString: String
    {
        // Construct speakable string piece by piece, depending on what we have available.
        var string = ""
        
        if let usableQuantity = quantityString {
            string = usableQuantity
        }
        
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
    
    var presentableQuantity: String
    {
        if
            let ingredientQuantity = quantityString,
            let ingredientUnits = units
        {
            return "\(ingredientQuantity) \(ingredientUnits)"
        }
        else if let ingredientQuantity = quantityString {
            return "\(ingredientQuantity)"
        }
        else {
            return ""
        }
    }
}
