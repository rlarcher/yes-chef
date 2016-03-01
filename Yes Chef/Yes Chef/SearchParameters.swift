//
//  SearchParameters.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/03/01.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

struct SearchParameters
{
    var query: String
    var cuisine: Cuisine
    var course: Category
    
    static func emptyParameters() -> SearchParameters
    {
        return SearchParameters(query: "", cuisine: .All, course: .All)
    }
    
    var presentableString: String {
        if cuisine != .All && course != .All {  // Don't bother saying "All Cuisines" etc.
            let cuisineName = cuisine.rawValue
            let courseName = course.rawValue
            
            var string = query
            if !query.fuzzyContains(cuisineName) {     // Always check to make sure we're not repeating ourselves (avoid "Cuban Cuban pastries")
                string = "\(cuisineName) \(string)"
            }
            if !query.fuzzyContains(courseName) {
                string = "\(string) (\(courseName))"
            }
            
            return string   // "Cuban Pastries (Appetizers)"
        }
        else if cuisine != .All {
            let cuisineName = cuisine.rawValue
            if !query.fuzzyContains(cuisineName) {
                return "\(cuisineName) \(query)"    // "Cuban Pastries"
            }
        }
        else if course != .All {
            let courseName = course.rawValue
            if !query.fuzzyContains(courseName) {
                return "\(query) (\(courseName))"   // "Pastries (Appetizers)"
            }
        }
        
        return query
    }
}
