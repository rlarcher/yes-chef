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
}

struct Ingredient
{
    let name: String
    let quantityString: String
    let units: String
}
