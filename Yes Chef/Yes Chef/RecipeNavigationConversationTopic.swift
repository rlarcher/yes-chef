//
//  RecipeNavigationConversationTopic.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class RecipeNavigationConversationTopic: SAYConversationTopic
{
    let eventHandler: RecipeNavigationConversationTopicEventHandler
    
    init(eventHandler: RecipeNavigationConversationTopicEventHandler)
    {
        self.eventHandler = eventHandler
        
        super.init()
    }
    
    // This must be called before attempting to speak.
    func updateRecipe(recipe: Recipe)
    {
        self.recipe = recipe
    }
    
    func speakOverview()
    {
        // TODO
    }
    
    // MARK: Lifecycle
    
    func topicDidGainFocus()
    {
        addSubtopic(RecipeOverviewConversationTopic())
        addSubtopic(RecipeIngredientsConversationTopic())
        addSubtopic(RecipePreparationConversationTopic())
        
        speakOverview()
    }
    
    func topicDidLoseFocus()
    {
        stopSpeaking()
        removeAllSubtopics()
    }
    
    private func stopSpeaking()
    {
        // TODO: Better way to interrupt speech on transitioning?
        postEvents(SAYAudioEventSequence(events: [SAYSilenceEvent(interval: 0.0)]))
    }
    
    private var recipe: Recipe!
}

protocol RecipeNavigationConversationTopicEventHandler: class
{
    // TODO
}
