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
    static func getLabelsForRating(rating: Int?) -> (textLabel: String, accessibilityLabel: String) {
        if rating == nil {
            return ("", "")
        }
        else {
            switch rating! {
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
    }
    
    static func stubRecipeListings() -> [RecipeListing]
    {
        let stubRecipeListings = [RecipeListing(recipeId: "12345678",
                                                name: "Blueberry Muffins",
                                                rating: 4,
                                                reviewCount: 20,
                                                servingsQuantity: 12,
                                                thumbnailImageURL: NSURL(string: "http://www.google.com")!),
                                  RecipeListing(recipeId: "87654321",
                                                name: "Raspberry Muffins",
                                                rating: 1,
                                                reviewCount: 0,
                                                servingsQuantity: 8,
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
                                  reviewCount: 20,
                                  description: "The most delicious blueberry muffins ever.",
                                  cuisine: Cuisine.American,
                                  category: Category.Desserts,
                                  subcategory: "Muffins",
                                  ingredients: stubIngredients,
                                  preparationSteps: stubPrepSteps,
                                  totalPreparationTime: 25,
                                  activePreparationTime:  10,
                                  servingsQuantity: 12,
                                  servingsUnit: "Servings",
                                  calories: 265,
                                  heroImageURL: NSURL(string: "http://www.google.com")!),
                           Recipe(recipeId: "87654321",
                                  name: "Raspberry Muffins",
                                  rating: 1,
                                  reviewCount: 0,
                                  description: "This recipe is known around the world.",
                                  cuisine: Cuisine.American,
                                  category: Category.Desserts,
                                  subcategory: "Muffins",
                                  ingredients: stubIngredients,
                                  preparationSteps: stubPrepSteps,
                                  totalPreparationTime: 45,
                                  activePreparationTime:  5,
                                  servingsQuantity: 8,
                                  servingsUnit: "Servings",
                                  calories: 310,
                                  heroImageURL: NSURL(string: "http://www.google.com")!)]
        
        return stubRecipes
    }
}
