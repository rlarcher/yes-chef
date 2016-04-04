//
//  Utils.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/08.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class Utils: NSObject
{
    static func getLabelsForRating(rating: String?) -> (textLabel: String, accessibilityLabel: String)
    {
        if let presentedRating = rating {
            return ("\(presentedRating) ☆", "\(presentedRating) out of 5 stars")
        }
        else {
            return ("", "")
        }
    }
    
    static var kFuzzyScoreThreshold = 0.45  // Arbitrary!
    
    static func fuzzyIndexOfItemWithName(name: String, inList itemList: [String], fuzziness: Double = 0.7, minThreshold: Double = kFuzzyScoreThreshold) -> Int?
    {
        var bestScore = 0.0
        var bestIndex: Int? = nil
        
        let lowerName = name.lowercaseString
        
        for (index, item) in itemList.enumerate() {
            let lowerItem = item.lowercaseString
            
            let forwardScore = lowerItem.scoreByTokens(lowerName, fuzziness: fuzziness)
            let backwardScore = lowerName.scoreByTokens(lowerItem, fuzziness: fuzziness)
            let score = max(forwardScore, backwardScore)
            
            if score > bestScore {
                bestScore = score
                bestIndex = index
            }
        }
        
        return bestScore > minThreshold ? bestIndex : nil
    }
    
    static func placeholderImage() -> UIImage
    {
        return UIImage(color: UIColor.lightGrayColor())     // TODO: Add a real placeholder image
    }
    
    // If more than half of a string consists of a URL, returns true. Otherwise false.
    // This is a pretty naive way to check if a URL makes up most of a string. But so far so good.
    // Ex: "[Instructions are at http://www.marthastewart.com/891898/creamy-shells-tuna-and-spinach]"
    static func stringIsMostlyURL(string: String) -> Bool
    {
        let rawLength = string.characters.count as Int
        
        let urlRegex = try! NSRegularExpression(pattern: "[-a-zA-Z0-9@:%_\\+.~#?&//=]{2,256}\\.[a-z]{2,4}\\b(\\/[-a-zA-Z0-9@:%_\\+.~#?&//=]*)?", options: .CaseInsensitive) // Adapated from www.regexr.com's "URL Similar" regex. Matches URLs and strings similar to a url.
        
        let matches = urlRegex.matchesInString(string, options: .ReportCompletion, range: NSMakeRange(0, rawLength))
        for match in matches {
            let matchLength = match.range.length
            if matchLength > rawLength / 2 {
                return true
            }
        }
        
        return false
    }
}

func _prompt(key: String, comment: String) -> String
{
    return NSLocalizedString(key, tableName: "Prompts", comment: comment)
}

// Parsing
extension Utils
{
    /**
     *  Crawls through and finds all possible prefix-suffix number pairs in a text and replaces the space between them with a hyphen. For example, the text "ten seven twenty two thirty forty" becomes "ten seven twenty-two thirty forty".
     */
    static func insertHyphensBetweenNumbersInText(text: String) -> String
    {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .SpellOutStyle
        
        let tokens = text.componentsSeparatedByCharactersInSet(NSCharacterSet.letterCharacterSet().invertedSet)
        
        var hyphenatedText = text
        var prefixExists = false
        
        for token in tokens {
            if let number = formatter.numberFromString(token) {
                if Utils.numberIsPrefix(number) {
                    prefixExists = true
                }
                else if Utils.numberIsSuffix(number) {
                    if prefixExists {
                        // Determine the range to override with a hyphen (e.g. the whitespace just before "eight" in "thirty eight")
                        if let tokenRange = hyphenatedText.rangeOfString(token) {
                            let hyphenRange = Range.init(start: tokenRange.startIndex.advancedBy(-1), end: tokenRange.startIndex)
                            
                            // Do the substition (e.g. "thirty eight" -> "thirty-eight"), if there's a space between them.
                            if hyphenatedText.substringWithRange(hyphenRange) == " " {
                                hyphenatedText.replaceRange(hyphenRange, with: "-")
                            }
                        }
                        
                        // Reset the flag
                        prefixExists = false
                    }
                }
                else {
                    // Didn't find a prefix nor a suffix. Reset the flag.
                    prefixExists = false
                }
            }
        }
        
        return hyphenatedText
    }
    
    /**
    *  Determines if the given number could be the prefix of a multi-word number, such as "thirty" in "thirty-eight" or "eighty" in "eighty-one". This is true for [20, 30, 40, ..., 90].
    */
    static func numberIsPrefix(number: NSNumber) -> Bool
    {
        let numberVal = number.intValue
        if numberVal > 10 && numberVal < 100 {
            if numberVal % 10 == 0 {
                return true
            }
        }
        
        return false
    }
    
    /**
    *  Determines if the given number could be the suffix of a multi-word number, such as "eight" in "thirty-eight" or "one" in "eighty-one". This is true for [1, 2, 3, ..., 9].
    */
    static func numberIsSuffix(number: NSNumber) -> Bool
    {
        let numberVal = number.intValue
        return numberVal > 0 && numberVal < 10
    }
}

// Stubs
extension Utils
{
    static func stubRecipeListings() -> [RecipeListing]
    {
        let stubRecipeListings = [
            RecipeListing(recipeId: "171326",
                          name: "Skewered Honey-Balsamic Chicken",
                          rating: 4.3,
                          reviewCount: 184,
                          cuisine: .Asian,
                          category: .Appetizers,
                          servingsQuantity: 6,
                          imageURL: NSURL(string: "http://photos.bigoven.com/recipe/hero/skewered-honey-balsamic-chicken-6.jpg")!),
            RecipeListing(recipeId: "12345678",
                          name: "Blueberry Muffins",
                          rating: 4,
                          reviewCount: 20,
                          cuisine: .All,
                          category: .Desserts,
                          servingsQuantity: 12,
                          imageURL: NSURL(string: "http://images.bigoven.com/image/upload/blueberry-muffins-low-carb-easy-2.jpg")!),
            RecipeListing(recipeId: "87654321",
                          name: "Raspberry Muffins",
                          rating: 1,
                          reviewCount: 0,
                          cuisine: .All,
                          category: .Desserts,
                          servingsQuantity: 8,
                          imageURL: NSURL(string: "http://images.bigoven.com/image/upload/lemon-raspberry-muffins-2.jpg")!)]
        
        return stubRecipeListings
    }
    
    static func stubRecipes() -> [Recipe]
    {
        let stubIngredients = [
            Ingredient(ingredientId: "12345",
                       name: "Flour",
                       quantityString: "2",
                       units: "Cups",
                       preparationNotes: nil),
            Ingredient(ingredientId: "678910",
                       name: "Blueberries",
                       quantityString: "one dozen",
                       units: "",
                       preparationNotes: "freshly picked")]
        
        let stubPrepSteps = ["Turn on oven", "Mix batter", "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."]
        let stubRawPrepSteps = "Turn on oven. Mix batter. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        
        let stubRecipes = [
            Recipe(recipeId: "12345678",
                   name: "Blueberry Muffins",
                   rating: 4,
                   reviewCount: 20,
                   description: "The most delicious blueberry muffins ever.",
                   cuisine: Cuisine.American,
                   category: Category.Desserts,
                   subcategory: "Muffins",
                   ingredients: stubIngredients,
                   preparationSteps: stubPrepSteps,
                   rawPreparationSteps: stubRawPrepSteps,
                   totalPreparationTime: 25,
                   activePreparationTime:  10,
                   servingsQuantity: 12,
                   servingsUnit: "Servings",
                   calories: 265,
                   heroImageURL: NSURL(string: "http://images.bigoven.com/image/upload/blueberry-muffins-low-carb-easy-2.jpg")!),
            Recipe(recipeId: "87654321",
                   name: "Raspberry Muffins",
                   rating: 1,
                   reviewCount: 0,
                   description: "This recipe is known around the world.",
                   cuisine: Cuisine.American,
                   category: Category.Desserts,
                   subcategory: "Muffins",
                   ingredients: stubIngredients,
                   preparationSteps: stubPrepSteps,
                   rawPreparationSteps: stubRawPrepSteps,
                   totalPreparationTime: 45,
                   activePreparationTime:  5,
                   servingsQuantity: 8,
                   servingsUnit: "Servings",
                   calories: 310,
                   heroImageURL: NSURL(string: "http://images.bigoven.com/image/upload/lemon-raspberry-muffins-2.jpg")!)]
        
        return stubRecipes
    }
}
