//
//  Category.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/7/3.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

enum Category: String
{
    case All =        "All Categories"
    case Desserts =   "Desserts"    // NOTE: Differs from docs, which says "dessert" without the "s".
    case Appetizers = "Appetizers"  // NOTE: Differs from docs, which says "appetizer" without the "s".
    case Bread =      "Bread"
    case Breakfast =  "Breakfast"
    case Drinks =     "Drinks"
    case MainDish =   "Main Dish"
    case Salad =      "Salad"
    case SideDish =   "Side Dish"
    case Soup =       "Soup"        // TODO: May actually be "Soups Stews and Chili", according to a regular BigOven search
    case Marinade =   "Marinade"    // TODO: May actually be "Marinades and Sauces", according to a regular BigOven search
    case Other =      "Other"
    
    static let orderedValues: [Category] = [
        All,
        Desserts,
        Appetizers,
        Bread,
        Breakfast,
        Drinks,
        MainDish,
        Salad,
        SideDish,
        Soup,
        Marinade,
        Other
    ]
    
    static func categoryFoundInText(text: String) -> Category?
    {
        let categoryNames = Category.orderedValues.map({ $0.rawValue })
        if let index = Utils.fuzzyIndexOfItemWithName(text, inList: categoryNames, fuzziness: 0.5, minThreshold: 0.8) {
            return Category.orderedValues[index]
        }
        
        // Also check the text against any known synonyms.
        // TODO: Combine this with `fuzzyIndexOfItemWithName` to make a more focused one-off method that also checks synonyms.
        for category in Category.orderedValues {
            for synonym in category.synonyms() {
                if text.fuzzyContains(synonym) || synonym.fuzzyContains(text) {
                    return category
                }
            }
        }
        
        return nil
    }
    
    private func synonyms() -> [String]
    {
        switch self {
        case .MainDish:
            return ["dinner", "lunch", "supper", "meal", "main course", "main"]
        case .Soup:
            return ["stew", "chili"]
        case .Marinade:
            return ["sauce"]
        default:
            return []
        }
    }
}
