//
//  Cuisine.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/7/3.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

enum Cuisine: String
{
    case All =              "All Cuisines"
    case Afghan =           "Afghan"
    case African =          "African"
    case American =         "American"
    case AmericanSouth =    "American-South"
    case Asian =            "Asian"
    case Australian =       "Australian"
    case Brazilian =        "Brazilian"
    case Cajun =            "Cajun"
    case Canadian =         "Canadian"
    case Caribbean =        "Caribbean"
    case Chinese =          "Chinese"
    case Croatian =         "Croatian"
    case Cuban =            "Cuban"
    case Dessert =          "Dessert"
    case EasternEuropean =  "Eastern European"
    case English =          "English"
    case French =           "French"
    case German =           "German"
    case Greek =            "Greek"
    case Hawaiian =         "Hawaiian"
    case Hungarian =        "Hungarian"
    case India =            "India"
    case Indian =           "Indian"
    case Irish =            "Irish"
    case Italian =          "Italian"
    case Japanese =         "Japanese"
    case Jewish =           "Jewish"
    case Korean =           "Korean"
    case Latin =            "Latin"
    case Mediterranean =    "Mediterranean"
    case Mexican =          "Mexican"
    case MiddleEastern =    "Middle Eastern"
    case Moroccan =         "Moroccan"
    case Polish =           "Polish"
    case Russian =          "Russian"
    case Scandanavian =     "Scandanavian"  // [sic], from docs
    case Seafood =          "Seafood"
    case Southern =         "Southern"
    case Southwestern =     "Southwestern"
    case Spanish =          "Spanish"
    case TexMex =           "Tex-Mex"
    case Thai =             "Thai"
    case Vegan =            "Vegan"
    case Vegetarian =       "Vegetarian"
    case Vietnamese =       "Vietnamese"
    
    static let orderedValues: [Cuisine] = [
        All,
        Afghan,
        African,
        American,
        AmericanSouth,
        Asian,
        Australian,
        Brazilian,
        Cajun,
        Canadian,
        Caribbean,
        Chinese,
        Croatian,
        Cuban,
        Dessert,
        EasternEuropean,
        English,
        French,
        German,
        Greek,
        Hawaiian,
        Hungarian,
        India,
        Indian,
        Irish,
        Italian,
        Japanese,
        Jewish,
        Korean,
        Latin,
        Mediterranean,
        Mexican,
        MiddleEastern,
        Moroccan,
        Polish,
        Russian,
        Scandanavian,
        Seafood,
        Southern,
        Southwestern,
        Spanish,
        TexMex,
        Thai,
        Vegan,
        Vegetarian,
        Vietnamese
    ]
    
    static func cuisineFoundInText(text: String) -> Cuisine?
    {
        let cuisineNames = Cuisine.orderedValues.map({ $0.rawValue })
        if let index = Utils.fuzzyIndexOfItemWithName(text, inList: cuisineNames) {
            return Cuisine.orderedValues[index]
        }
        
        return nil
    }
}
