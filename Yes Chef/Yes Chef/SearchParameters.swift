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
    var query: String?
    var cuisine: Cuisine?
    var course: Category?
    
    static func emptyParameters() -> SearchParameters
    {
        return SearchParameters(query: nil, cuisine: nil, course: nil)
    }
    
    /*
    * Build a presentable string piece by piece.
    * Tries to follow a format like "Cuisine Query (Course)". Depending on what parameters are missing, could also result strings like the following:
    *   "Cuban Pastries (Appetizers)"     (all parameters available)
    *   "Cuban Pastries"                  (no course)
    *   "Pastries (Appetizers)"           (no cuisine)
    *   "Pastries"                        (only query)
    *   "Cuban Appetizers"                (no query)
    *   "Cuban food"                      (only cuisine). Note the addition of "food".
    *   "Appetizers                       (only course)
    * We only want to present cuisine and course if they actually filtered the query. In other words, don't bother presenting the default ".All" category.
    */
    var presentableString: String? {
        
        if let presentableQuery = query where !presentableQuery.isBlank {
            if
                let presentableCuisine = cuisine where presentableCuisine != .All,
                let presentableCourse = course where presentableCourse != .All
            {
                // All parameters available. "Cuban Pastries (Appetizers)"
                if !presentableQuery.fuzzyContains(presentableCuisine.rawValue) &&
                   !presentableQuery.fuzzyContains(presentableCourse.rawValue) // Avoid repeating ourselves. e.g. "Cuban Cuban Pastries" or "Shrimp Appetizers (Appetizers)"
                {
                    return "\(presentableCuisine) \(presentableQuery) (\(presentableCourse))"
                }
                else {
                    return presentableQuery
                }
            }
            else if let presentableCuisine = cuisine where presentableCuisine != .All {
                // No course available. "Cuban Pastries"
                if !presentableQuery.fuzzyContains(presentableCuisine.rawValue) {
                    return "\(presentableCuisine) \(presentableQuery)"
                }
                else {
                    return presentableQuery
                }
            }
            else if let presentableCourse = course where presentableCourse != .All {
                // No cuisine available. "Pastries (Appetizers)"
                if !presentableQuery.fuzzyContains(presentableCourse.rawValue) {
                    return "\(presentableQuery) (\(presentableCourse))"
                }
                else {
                    return presentableQuery
                }
            }
            else {
                // Only query available. "Pastries"
                return presentableQuery
            }
        }
        else {
            if
                let presentableCuisine = cuisine where presentableCuisine != .All,
                let presentableCourse = course where presentableCourse != .All
            {
                // No query available. "Cuban Appetizers"
                return "\(presentableCuisine) \(presentableCourse)"
            }
            else if let presentableCuisine = cuisine where presentableCuisine != .All {
                // Only cuisine available. "Cuban food"
                return "\(presentableCuisine) food"
            }
            else if let presentableCourse = course where presentableCourse != .All {
                // Only course available. "Appetizers"
                return "\(presentableCourse)"
            }
            else {
                // Nothing available!
                return nil
            }
        }
    }
    
    /* 
    * Since we can't yet search by Cuisine, prefix the search query with the cuisine, if applicable. Should result in queries like "Japanese shrimp", "Cuban pastries".
    * Tries to follow the format "Cuisine Query", while avoiding repeating ourselves ("Cuban Cuban Pastries"). Some possible outcomes:
    *   "Cuban Pastries"    (cuisine and query)
    *   "Pastries"          (no cuisine)
    *   "Cuban"             (no query)
    *   Returns nil if neither cuisine nor query is available. Presumably we're just doing a Course search then.
    */
    var searchStringWithCuisine: String? {
        if
            let usableQuery = query where !usableQuery.isBlank,
            let usableCuisine = cuisine where usableCuisine != .All &&
                !usableQuery.fuzzyContains(usableCuisine.rawValue)
        {
            return "\(usableCuisine) \(usableQuery)"
        }
        else if let usableQuery = query where !usableQuery.isBlank {
            return usableQuery
        }
        else if let usableCuisine = cuisine where usableCuisine != .All {
            return "\(usableCuisine)"
        }
        else {
            return nil
        }
    }
}
