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
    
    func isEmpty() -> Bool
    {
        if self.characters.count == 0 {
            return true
        }
        
        let trimmedSelf = self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
//        if trimmedSelf.characters.count
//        + (BOOL)isStringEmptyOrWhitespace:(NSString *)string {
//            if ([string length] == 0) { // string is empty or nil
//                return YES;
//            }
//            
//            if (![[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
//                // string is all whitespace
//                return YES;
//            }
//            
//            return NO;
//        }
        
        return false
    }
}
