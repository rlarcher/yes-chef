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
        
        // TODO: Add command recognizer for "What are the ratings?"
        // TODO: Add command recognizer for "What's the name of the recipe?"
        // TODO: Add command recognizer for "Calories" etc.
        // TODO: Add command recognizer for this recipe's "Category"
        // TODO: Add command recognizer for dietary restrictions
    }
    
    // This must be called before attempting to speak.    
    func updateRecipe(recipe: Recipe)
    {
        self.recipe = recipe
    }
    
    // MARK: Lifecycle
    
    func topicDidGainFocus()
    {
        speakOverview()
    }
    
    func topicDidLoseFocus()
    {
        stopSpeaking()
    }
    
    // MARK: Helpers
    
    func speakOverview()
    {
        let sequence = SAYAudioEventSequence()
        sequence.addEvent(SAYSpeechEvent(utteranceString: recipe.speakableString))
        postEvents(sequence)
    }
    
    private func stopSpeaking()
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
}
