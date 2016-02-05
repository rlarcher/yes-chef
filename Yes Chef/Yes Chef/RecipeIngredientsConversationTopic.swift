//
//  RecipeIngredientsConversationTopic.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class RecipeIngredientsConversationTopic: SAYConversationTopic
{
    let eventHandler: RecipeIngredientsConversationTopicEventHandler
    
    init(eventHandler: RecipeIngredientsConversationTopicEventHandler)
    {
        self.eventHandler = eventHandler
        
        super.init()
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
    
    private func stopSpeaking()
    {
        // TODO: Better way to interrupt speech on transitioning?
        postEvents(SAYAudioEventSequence(events: [SAYSilenceEvent(interval: 0.0)]))
    }
    
    private var recipe: Recipe!
}

protocol RecipeIngredientsConversationTopicEventHandler: class
{
    
}
