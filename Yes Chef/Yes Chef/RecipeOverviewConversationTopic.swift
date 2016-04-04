//
//  RecipeOverviewConversationTopic.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class RecipeOverviewConversationTopic: SAYConversationTopic
{
    init(eventHandler: RecipeOverviewConversationTopicEventHandler)
    {
        self.eventHandler = eventHandler
        
        super.init()
        
        let overviewRecognizer = SAYCustomCommandRecognizer(customType: "Overview", responseTarget: eventHandler, action: "handleOverviewCommand")
        overviewRecognizer.addTextMatcher(SAYBlockCommandMatcher(block: { text -> SAYCommandSuggestion? in
            if text.containsAny(["overview", "over view"]) {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceVeryLikely)
            }
            else {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceNone)
            }
        }))
        overviewRecognizer.addMenuItemWithLabel("Recipe Overview")
        addCommandRecognizer(overviewRecognizer)
        
        let ratingRecognizer = SAYCustomCommandRecognizer(customType: "Rating", responseTarget: eventHandler, action: "handleRatingCommand")
        ratingRecognizer.addTextMatcher(SAYBlockCommandMatcher(block: { text -> SAYCommandSuggestion? in
            if text.containsAny(["rating", "ratings", "rated", "rate", "stars"]) {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceVeryLikely)
            }
            else {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceNone)
            }
        }))
        ratingRecognizer.addMenuItemWithLabel("Recipe Rating")
        addCommandRecognizer(ratingRecognizer)
        
        let recipeNameRecognizer = SAYCustomCommandRecognizer(customType: "RecipeName", responseTarget: eventHandler, action: "handleRecipeNameCommand")
        recipeNameRecognizer.addTextMatcher(SAYBlockCommandMatcher(block: { text -> SAYCommandSuggestion? in
            // Respond to speech like "What's the name of this recipe?", "What's this called?"
            if text.containsAny(["named", "called", "name", "call"]) {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceVeryLikely)
            }
            else {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceNone)
            }
        }))
        recipeNameRecognizer.addMenuItemWithLabel("Recipe Name")
        addCommandRecognizer(recipeNameRecognizer)
        
        let caloriesRecognizer = SAYCustomCommandRecognizer(customType: "Calories", responseTarget: eventHandler, action: "handleCaloriesCommand")
        caloriesRecognizer.addTextMatcher(SAYBlockCommandMatcher(block: { text -> SAYCommandSuggestion? in
            // Respond to speech like "How many calories is this?", "Is this healthy?"
            if text.containsAny(["calorie", "calories", "healthy"]) {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceVeryLikely)
            }
            else {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceNone)
            }
        }))
        caloriesRecognizer.addMenuItemWithLabel("Recipe Calories")
        addCommandRecognizer(caloriesRecognizer)
        
        let cuisineCategoryRecognizer = SAYCustomCommandRecognizer(customType: "CuisineCategory", responseTarget: eventHandler, action: "handleCuisineCategoryCommand")
        cuisineCategoryRecognizer.addTextMatcher(SAYBlockCommandMatcher(block: { text -> SAYCommandSuggestion? in
            if text.containsAny(["cuisine", "cuisines", "category", "categories", "what kind", "what type"]) {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceVeryLikely)
            }
            else {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceNone)
            }
        }))
        cuisineCategoryRecognizer.addMenuItemWithLabel("Cuisine and Category")
        addCommandRecognizer(cuisineCategoryRecognizer)
        
        let nutritionInfoRecognizer = SAYCustomCommandRecognizer(customType: "NutritionInfo", responseTarget: eventHandler, action: "handleNutritionInfoCommand")
        nutritionInfoRecognizer.addTextMatcher(SAYBlockCommandMatcher(block: { text -> SAYCommandSuggestion? in
            if text.containsAny(["nutrition", "nutritional", "fat", "diet", "dietary", "calories"]) {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceVeryLikely)
            }
            else {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceNone)
            }
        }))
        nutritionInfoRecognizer.addMenuItemWithLabel("Nutritional Information")
        addCommandRecognizer(nutritionInfoRecognizer)
        
        let descriptionRecognizer = SAYCustomCommandRecognizer(customType: "Description", responseTarget: eventHandler, action: "handleDescriptionCommand")
        descriptionRecognizer.addTextMatcher(SAYBlockCommandMatcher(block: { text -> SAYCommandSuggestion? in
            if text.containsAny(["description", "describe", "about the recipe"]) {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceCertain)
            }
            else {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceNone)
            }
        }))
        descriptionRecognizer.addMenuItemWithLabel("Description")
        addCommandRecognizer(descriptionRecognizer)
    }
    
    // This must be called before attempting to speak.    
    func updateRecipe(recipe: Recipe)
    {
        self.recipe = recipe
    }
    
    // MARK: Lifecycle
    
    func topicDidGainFocus()
    {

    }
    
    func topicDidLoseFocus()
    {
        stopSpeaking()
    }
    
    // MARK: Speech
    
    func speakOverview()
    {
        let sequence = SAYAudioEventSequence()
        sequence.addEvent(SAYSpeechEvent(utteranceString: recipe.speakableString))
        if recipe.truncatedDescriptionAvailable {
            sequence.addEvent(SAYSpeechEvent(utteranceString: _prompt("recipe_details:overview_call_to_action", comment: "Call to action after speaking a recipe's overview")))
        }
        postEvents(sequence)
    }
    
    func speakRating()
    {
        let format = _prompt("recipe_details:rating_is_X", comment: "Spoken in response to \"What's the rating?\"")
        let sequence = SAYAudioEventSequence()
        sequence.addEvent(SAYSpeechEvent(utteranceString: String(format: format, recipe.rating)))
        postEvents(sequence)
    }
    
    func speakRecipeName()
    {
        let format = _prompt("recipe_details:name_is_X", comment: "Spoken in response to \"What's this recipe's name?\"")
        let sequence = SAYAudioEventSequence()
        sequence.addEvent(SAYSpeechEvent(utteranceString: String(format: format, recipe.name)))
        postEvents(sequence)
    }
    
    func speakCalories()
    {
        let format = _prompt("recipe_details:calories", comment: "Spoken in response to \"How many calories?\"")
        let sequence = SAYAudioEventSequence()
        sequence.addEvent(SAYSpeechEvent(utteranceString: String(format: format, recipe.calories.withSuffix("calorie"))))
        postEvents(sequence)
    }
    
    func speakCuisineCategory()
    {
        let sequence = SAYAudioEventSequence()
        
        let utteranceString: String
        if recipe.cuisine != .All && recipe.category != .All {
            let format = _prompt("recipe_details:cuisine_is_X_course_is_Y", comment: "Spoken in response to \"What course/cuisine is this?\"")
            utteranceString = String(format: format, recipe.cuisine.rawValue, recipe.category.rawValue)
        }
        else if recipe.cuisine != .All {
            let format = _prompt("recipe_details:cuisine_is_X", comment: "Spoken in response to \"What course/cuisine is this?\" when only cuisine is known")
            utteranceString = String(format: format, recipe.cuisine.rawValue)
        }
        else if recipe.category != .All {
            let format = _prompt("recipe_details_course_is_X", comment: "Spoken in response to \"What course/cuisine is this?\" when only course is known")
            utteranceString = String(format: format, recipe.category.rawValue)
        }
        else {
            utteranceString = _prompt("recipe_details_unknown_cuisine_course", comment: "Spoken in response to \"What course/cuisine is this?\" when both course and cuisine are unknown")
        }
        
        sequence.addEvent(SAYSpeechEvent(utteranceString: utteranceString))
        postEvents(sequence)
    }
    
    func speakNutritionInfo()
    {
        // TODO: Pending API upgrade
        let sequence = SAYAudioEventSequence()
        sequence.addEvent(SAYSpeechEvent(utteranceString: _prompt("recipe_details:nutrition_unknown", comment: "Spoken in response to \"What's the nutritional info?\"")))
        postEvents(sequence)
    }
    
    func speakDescription()
    {
        let sequence = SAYAudioEventSequence()
        sequence.addEvent(SAYSpeechEvent(utteranceString: recipe.presentableDescription))
        postEvents(sequence)
    }
    
    func stopSpeaking()
    {
        // TODO: Better way to interrupt speech on transitioning?
        postEvents(SAYAudioEventSequence(events: [SAYSilenceEvent(interval: 0.0)]))
    }
    
    private var recipe: Recipe!
    private let eventHandler: RecipeOverviewConversationTopicEventHandler
}

protocol RecipeOverviewConversationTopicEventHandler: class
{
    func handleOverviewCommand()
    func handleRatingCommand()
    func handleRecipeNameCommand()
    func handleCaloriesCommand()
    func handleCuisineCategoryCommand()
    func handleNutritionInfoCommand()
    func handleDescriptionCommand()
}
