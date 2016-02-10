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
        let stubRecipes = Utils.stubRecipes()
        
        return stubRecipes
    }
    
    static private var underlyingInstance: SavedRecipesManager?
}
