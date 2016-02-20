//
//  String+Utils.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/17.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

extension String
{
    func containsAny(strings: [String]) -> Bool
    {
        for string in strings {
            if self.containsString(string) {
                return true
            }
        }
        
        return false
    }
    
    func fuzzyMatches(other: String) -> Bool
    {
        return self.score(other, fuzziness: 0.7) > Utils.kFuzzyScoreThreshold
    }
    
    // Returns true if this string is empty or contains only whitespace.
    var isBlank: Bool
    {
        if self.isEmpty {
            return true
        }
        
        let trimmedSelf = self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if trimmedSelf.isEmpty {
            return true
        }
        
        return false
    }
    
    func plural(count: Int) -> String
    {
        return plural(count, pluralForm: self + "s")
    }
    
    func plural(count: Int, pluralForm: String) -> String
    {
        if count == 1 {
            return self
        }
        else {
            return pluralForm
        }
    }
}
