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
            if text.containsString("over view") || text.containsString("overview") {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceVeryLikely)
            }
            else {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceNone)
            }
        }))
        self.addCommandRecognizer(overviewRecognizer)
        
        let ratingRecognizer = SAYCustomCommandRecognizer(customType: "Rating", responseTarget: eventHandler, action: "handleRatingCommand")
        ratingRecognizer.addTextMatcher(SAYBlockCommandMatcher(block: { text -> SAYCommandSuggestion? in
            if text.containsString("rating") || text.containsString("ratings") || text.containsString("rated") || text.containsString("rate") || text.containsString("stars") {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceVeryLikely)
            }
            else {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceNone)
            }
        }))
        self.addCommandRecognizer(ratingRecognizer)
        
        let recipeNameRecognizer = SAYCustomCommandRecognizer(customType: "RecipeName", responseTarget: eventHandler, action: "handleRecipeNameCommand")
        recipeNameRecognizer.addTextMatcher(SAYBlockCommandMatcher(block: { text -> SAYCommandSuggestion? in
            // Respond to speech like "What's the name of this recipe?", "What's this called?"
            if text.containsString("named") || text.containsString("called") || text.containsString("name") || text.containsString("call") {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceVeryLikely)
            }
            else {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceNone)
            }
        }))
        self.addCommandRecognizer(recipeNameRecognizer)
        
        let caloriesRecognizer = SAYCustomCommandRecognizer(customType: "Calories", responseTarget: eventHandler, action: "handleCaloriesCommand")
        caloriesRecognizer.addTextMatcher(SAYBlockCommandMatcher(block: { text -> SAYCommandSuggestion? in
            // Respond to speech like "How many calories is this?", "Is this healthy?"
            if text.containsString("calorie") || text.containsString("calories") || text.containsString("healthy") {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceVeryLikely)
            }
            else {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceNone)
            }
        }))
        self.addCommandRecognizer(caloriesRecognizer)
        
        // TODO: Add command recognizer for this recipe's "Category"
        // TODO: Add command recognizer for dietary restrictions
        // TODO: Add command recognizer for recipe description
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
}
