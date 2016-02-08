//
//  RecipeIngredientsConversationTopic.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class RecipeIngredientsConversationTopic: SAYConversationTopic, ListConversationTopicEventHandler
{
    let eventHandler: RecipeIngredientsConversationTopicEventHandler
    
    // MARK: Lifecycle
    
    init(eventHandler: RecipeIngredientsConversationTopicEventHandler)
    {
        self.eventHandler = eventHandler
        
        super.init()
        
        // TODO: Add command recognizer for "How many servings?"
        // TODO: Add command recognizer for "Does it contain __ingredient__?" "Do I need __ingredient__?" "How much __ingredient__ do I need?"
        // TODO: Add command recognizer for "What are the ingredients?"
        // TODO: Add command recognizer for "Can I substitute __ingredientX__ for __ingredientY__?"
        // TODO: Add command recognizer for unit conversion.
    }
    
    // This must be called before attempting to speak.    
    func updateRecipe(recipe: Recipe)
    {
        self.recipe = recipe
    }
    
    func topicDidGainFocus()
    {
        addSubtopic(ListConversationTopic(eventHandler: self))
        speakIngredients()
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
            if recipe.ingredients.count > 0 {
                prefixEvent = SAYSpeechEvent(utteranceString: "You need \(recipe.ingredients.count) ingredients for this recipe:")
            }
            else {
                prefixEvent = SAYSpeechEvent(utteranceString: "There are no ingredients for this recipe.") // ...delicious
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
    
    private func speakIngredients()
    {
        if let listSubtopic = self.subtopics.first as? ListConversationTopic {
            listSubtopic.speakItems(recipe.ingredients.map { $0.speakableString })
        }
    }
    
    private var recipe: Recipe!
}

protocol RecipeIngredientsConversationTopicEventHandler: class
{
    func handleSelectCommand(command: SAYCommand)
    func handleSearchCommand(command: SAYCommand)
    func handlePlayCommand()
    func handlePauseCommand()
    func handleNextCommand()
    func handlePreviousCommand()
}
