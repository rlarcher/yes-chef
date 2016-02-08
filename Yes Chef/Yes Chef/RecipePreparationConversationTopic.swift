//
//  RecipePreparationConversationTopic.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class RecipePreparationConversationTopic: SAYConversationTopic, ListConversationTopicEventHandler
{
    let eventHandler: RecipePreparationConversationTopicEventHandler
    
    // MARK: Lifecycle
    
    init(eventHandler: RecipePreparationConversationTopicEventHandler)
    {
        self.eventHandler = eventHandler
        
        super.init()
        
        // TODO: Add command recognizer for "What temperature do I set the oven?"
        // TODO: Add command recognizer for "What do I do?"
    }
    
    // This must be called before attempting to speak.
    func updateRecipe(recipe: Recipe)
    {
        self.recipe = recipe
    }
    
    func topicDidGainFocus()
    {
        addSubtopic(ListConversationTopic(eventHandler: self))        
        speakPreparationSteps()
    }
    
    func topicDidLoseFocus()
    {
        stopSpeaking()
        removeAllSubtopics()        
    }
    
    override func subtopic(subtopic: SAYConversationTopic, didPostEventSequence sequence: SAYAudioEventSequence)
    {
        if subtopic is ListConversationTopic {
            let prefixEvent: SAYSpeechEvent
            if recipe.preparationSteps.count > 0 {
                prefixEvent = SAYSpeechEvent(utteranceString: "There are \(recipe.preparationSteps.count) steps to this recipe:")
            }
            else {
                prefixEvent = SAYSpeechEvent(utteranceString: "There are no preparation steps for this recipe.")
            }
            
            let outgoingSequence = SAYAudioEventSequence(events: [prefixEvent])
            outgoingSequence.appendSequence(sequence)
            
            self.postEvents(outgoingSequence)
        }
        else {
            self.postEvents(sequence)
        }
    }
    
    // MARK: ListConversationTopicEventHandler Protocol Methods
    // TODO: Using these as pass-through only. Better way?
    
    func handleSelectCommand(command: SAYCommand)
    {
        eventHandler.handleSelectCommand(command)
    }
    
    func handleSearchCommand(command: SAYCommand)
    {
        eventHandler.handleSearchCommand(command)
    }
    
    func handlePlayCommand()
    {
        eventHandler.handlePlayCommand()
    }
    
    func handlePauseCommand()
    {
        eventHandler.handlePauseCommand()
    }
    
    func handleNextCommand()
    {
        eventHandler.handleNextCommand()
    }
    
    func handlePreviousCommand()
    {
        eventHandler.handlePreviousCommand()
    }
    
    // MARK: Helpers
    
    private func stopSpeaking()
    {
        // TODO: Better way to interrupt speech on transitioning?
        postEvents(SAYAudioEventSequence(events: [SAYSilenceEvent(interval: 0.0)]))
    }
    
    private func speakPreparationSteps()
    {
        if let listSubtopic = self.subtopics.first as? ListConversationTopic {
            listSubtopic.speakItems(recipe.preparationSteps)
        }
    }
    
    private var recipe: Recipe!
}

protocol RecipePreparationConversationTopicEventHandler: class
{
    func handleSelectCommand(command: SAYCommand)
    func handleSearchCommand(command: SAYCommand)
    func handlePlayCommand()
    func handlePauseCommand()
    func handleNextCommand()
    func handlePreviousCommand()
}
