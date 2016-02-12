//
//  Utils.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/08.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class Utils: NSObject
{
    static func getLabelsForRating(rating: Int) -> (textLabel: String, accessibilityLabel: String) {
        switch rating {
        case 0:
            return ("☆☆☆☆☆", "0 out of 5 stars")
        case 1:
            return ("★☆☆☆☆", "1 out of 5 stars")
        case 2:
            return ("★★☆☆☆", "2 out of 5 stars")
        case 3:
            return ("★★★☆☆", "3 out of 5 stars")
        case 4:
            return ("★★★★☆", "4 out of 5 stars")
        case 5:
            return ("★★★★★", "5 out of 5 stars")
        default:
            return ("", "")
        }
    }
    
    static func stubRecipeListings() -> [RecipeListing]
    {
        let stubRecipeListings = [RecipeListing(recipeId: "12345678",
                                                name: "Blueberry Muffins",
                                                rating: 4,
                                                servingSize: 12,
                                                thumbnailImageURL: NSURL(string: "http://www.google.com")!),
                                  RecipeListing(recipeId: "87654321",
                                                name: "Raspberry Muffins",
                                                rating: 1,
                                                servingSize: 8,
                                                thumbnailImageURL: NSURL(string: "http://www.google.com")!)]
        
        return stubRecipeListings
    }
    
    static func stubRecipes() -> [Recipe]
    {
        let stubIngredients = [Ingredient(ingredientId: "12345",
                                          name: "Flour",
                                          quantityString: "2",
                                          units: "Cups",
                                          preparationNotes: nil),
                               Ingredient(ingredientId: "678910",
                                          name: "Blueberries",
                                          quantityString: "one dozen",
                                          units: "",
                                          preparationNotes: "freshly picked")]
        
        let stubPrepSteps = ["Turn on oven", "Mix batter", "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."]
        
        let stubRecipes = [Recipe(recipeId: "12345678",
                                  name: "Blueberry Muffins",
                                  rating: 4,
                                  description: "The most delicious blueberry muffins ever.",
                                  ingredients: stubIngredients,
                                  preparationSteps: stubPrepSteps,
                                  totalPreparationTime: 25,
                                  activePreparationTime:  10,
                                  servingSize: 12,
                                  calories: 265,
                                  heroImageURL: NSURL(string: "http://www.google.com")!),
                           Recipe(recipeId: "87654321",
                                  name: "Raspberry Muffins",
                                  rating: 1,
                                  description: "This recipe is known around the world.",
                                  ingredients: stubIngredients,
                                  preparationSteps: stubPrepSteps,
                                  totalPreparationTime: 45,
                                  activePreparationTime:  5,
                                  servingSize: 8,
                                  calories: 310,
                                  heroImageURL: NSURL(string: "http://www.google.com")!)]
        
        return stubRecipes
    }
}
