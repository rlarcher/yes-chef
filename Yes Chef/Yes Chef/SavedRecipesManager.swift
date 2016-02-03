//
//  SavedRecipesManager.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class SavedRecipesManager
{
    static var sharedManager: SavedRecipesManager {
        get {
            if underlyingInstance == nil {
                underlyingInstance = SavedRecipesManager()
            }
            
            return underlyingInstance!
        }
    }
    
    func loadSavedRecipes() -> [Recipe]
    {
        // TODO
        
        let stubIngredients = [Ingredient(name: "Flour", quantityString: "2", units: "Cups"),
                               Ingredient(name: "Blueberries", quantityString: "one dozen", units: "")]
        
        let stubPrepSteps = ["Turn on oven", "Mix batter", "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."]
        
        let stubRecipes = [Recipe(name: "Blueberry Muffins",
                                  rating: 4,
                                  ingredients: stubIngredients,
                                  preparationSteps: stubPrepSteps,
                                  preparationTime:  25 * 60,
                                  calories: 265,
                                  thumbnail: UIImage()),
                           Recipe(name: "Raspberry Muffins",
                                  rating: 1,
                                  ingredients: stubIngredients,
                                  preparationSteps: stubPrepSteps,
                                  preparationTime:  25 * 45,
                                  calories: 310,
                                  thumbnail: UIImage())]
        
        return stubRecipes
    }
    
    static private var underlyingInstance: SavedRecipesManager?
}
