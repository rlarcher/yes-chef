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
}
