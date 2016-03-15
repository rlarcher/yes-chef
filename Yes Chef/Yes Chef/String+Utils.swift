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
    
    func fuzzyContains(other: String, useLowercase shouldUseLowercase: Bool = true) -> Bool
    {
        if shouldUseLowercase {
            return self.lowercaseString.scoreByTokens(other.lowercaseString) > Utils.kFuzzyScoreThreshold
        }
        else {
            return self.scoreByTokens(other) > Utils.kFuzzyScoreThreshold
        }
    }
    
    // Also does token-wise checking when calculating score, instead of just checking against the entire string.
    func scoreByTokens(other: String) -> Double
    {
        var highestScore = 0.0
        var currentScore = 0.0
        
        // Start by scoring the entire string
        currentScore = self.score(other, fuzziness: 0.7)
        if currentScore > highestScore {
            highestScore = currentScore
        }
        
        let selfTokens = self.componentsSeparatedByCharactersInSet(NSCharacterSet.letterCharacterSet().invertedSet)
        let otherTokens = other.componentsSeparatedByCharactersInSet(NSCharacterSet.letterCharacterSet().invertedSet)
        
        for selfToken in selfTokens {
            for otherToken in otherTokens {
                currentScore = selfToken.score(otherToken, fuzziness: 0.7)
                if currentScore > highestScore {
                    highestScore = currentScore
                }
            }
        }
        
        return highestScore
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
    
    func toOrdinalNumber() -> NSNumber?
    {
        let formatter = NSNumberFormatter()
        
        // Handle a numerical ordinal (e.g. "4th").
        formatter.numberStyle = .OrdinalStyle
        if let number = formatter.numberFromString(self) {
            return number
        }
        
        // Handle a spelled-out ordinal (e.g. "fourth").
        formatter.numberStyle = .SpellOutStyle
        if let number = formatter.numberFromString(self) {
            return number
        }
        
        return nil
    }
 
    func toNumber() -> NSNumber?
    {
        if let number = self.decimalOrSpellOutToNumber() {
            return number
        }
        else if let number = self.ordinalToNumber() {
            return number
        }
        else {
            return nil
        }
    }
    
    private func decimalOrSpellOutToNumber() -> NSNumber?
    {
        let formatter = NSNumberFormatter()
        
        // Remove any extraneous spaces around punctuation
        // (e.g. "3 . 5" -> "3.5")
        // (e.g. "10 , 000" -> "10,000").
        // These white spaces may be inserted by the speech recognition service to separate out tokens. Luis definitely does this.
        let despacedText = self.stringByReplacingOccurrencesOfString("((?<=\\d) (?=.|,))|((?<=.|,) (?=\\d))", withString: "", options: .RegularExpressionSearch, range: nil)
        
        // Handle a numerical string (e.g. "4").
        formatter.numberStyle = .DecimalStyle
        if let number = formatter.numberFromString(despacedText) {
            return number
        }
        
        // Pre-process the raw number text so multi-word numbers are in a format expected by NSNumberFormatterSpellOutStyle (e.g. we want "thirty-eight", not "thirty eight").
        let hyphenatedText = Utils.insertHyphensBetweenNumbersInText(self)
        
        // Handle a spelled-out number (e.g. "four").
        formatter.numberStyle = .SpellOutStyle
        if let number = formatter.numberFromString(hyphenatedText) {
            return number
        }
        
        return nil
    }
    
    private func ordinalToNumber() -> NSNumber?
    {
        let formatter = NSNumberFormatter()
        
        // Handle a numerical ordinal (e.g. "4th").
        formatter.numberStyle = .OrdinalStyle
        if let number = formatter.numberFromString(self) {
            return number
        }
        
        // Handle a spelled-out ordinal (e.g. "fourth").
        formatter.numberStyle = .SpellOutStyle
        if let number = formatter.numberFromString(self) {
            return number
        }
        
        return nil
    }
}
