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
        postEvents(sequence)
    }
    
    func speakRating()
    {
        let sequence = SAYAudioEventSequence()
        sequence.addEvent(SAYSpeechEvent(utteranceString: "This recipe has \(recipe.rating) out of 5 stars."))
        postEvents(sequence)
    }
    
    func speakRecipeName()
    {
        let sequence = SAYAudioEventSequence()
        sequence.addEvent(SAYSpeechEvent(utteranceString: "This recipe is called \"\(recipe.name)\"."))
        postEvents(sequence)
    }
    
    func speakCalories()
    {
        let sequence = SAYAudioEventSequence()
        sequence.addEvent(SAYSpeechEvent(utteranceString: "This recipe has \(recipe.calories) calories."))
        postEvents(sequence)
    }
    
    func speakCuisineCategory()
    {
        let sequence = SAYAudioEventSequence()
        
        let utteranceString: String
        if recipe.cuisine != .All && recipe.category != .All {
            utteranceString = "This is a \"\(recipe.cuisine)\" dish, in the \"\(recipe.category): \(recipe.subcategory)\" category."
        }
        else if recipe.cuisine != .All {
            utteranceString = "This is a \"\(recipe.cuisine)\" dish."
        }
        else if recipe.category != .All {
            utteranceString = "This dish is in the \"\(recipe.category): \(recipe.subcategory)\" category."
        }
        else {
            utteranceString = "I don't know what kind of dish this is."
        }
        
        sequence.addEvent(SAYSpeechEvent(utteranceString: utteranceString))
        postEvents(sequence)
    }
    
    func speakNutritionInfo()
    {
        // TODO: Pending API upgrade
        let sequence = SAYAudioEventSequence()
        sequence.addEvent(SAYSpeechEvent(utteranceString: "Sorry, I don't know this recipe's nutritional information."))
        postEvents(sequence)
    }
    
    func speakDescription()
    {
        let sequence = SAYAudioEventSequence()
        sequence.addEvent(SAYSpeechEvent(utteranceString: recipe.description))
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
