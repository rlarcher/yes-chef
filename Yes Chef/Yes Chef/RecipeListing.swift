//
//  RecipeListing.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2/9/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

struct RecipeListing
{
    let recipeID: String
    let name: String
    let rating: Int
    let thumbnailImageURL: NSURL
    
    var speakableString: String {
        return "\(name). \(rating) out of 5 stars."
    }
}
