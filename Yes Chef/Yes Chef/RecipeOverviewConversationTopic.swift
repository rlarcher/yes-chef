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
        
        // TODO: Add command recognizer for "Give me an overview"
        // TODO: Add command recognizer for "What are the ratings?"
        // TODO: Add command recognizer for "What's the name of the recipe?"
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
    
    private func speakOverview()
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
    
}
