//
//  SavedRecipesConversationTopic.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class SavedRecipesConversationTopic: SAYConversationTopic, ListConversationTopicEventHandler
{
    let eventHandler: SavedRecipesConversationTopicEventHandler
    
    init(eventHandler: SavedRecipesConversationTopicEventHandler)
    {
        self.eventHandler = eventHandler
        
        super.init()
        
        // TODO: Add command recognizer for "Remove __recipe__".
    }
    
    // This must be called before attempting to speak.
    func updateSavedRecipes(recipes: [Recipe])
    {
        self.recipes = recipes
        listSubtopic?.items = recipes.map({ $0.speakableString })
    }
    
    func speakSavedRecipes()
    {
        listSubtopic?.speakItems()
    }
    
    // MARK: Lifecycle
    
    func topicDidGainFocus()
    {
        listSubtopic = ListConversationTopic(items: recipes.map({ $0.speakableString }), eventHandler: self)
        addSubtopic(listSubtopic!)
        speakSavedRecipes()
    }
    
    func topicDidLoseFocus()
    {
        stopSpeaking()
        removeAllSubtopics()
    }
    
    // MARK: Subtopic Handling
    
    override func subtopic(subtopic: SAYConversationTopic, didPostEventSequence sequence: SAYAudioEventSequence)
    {
        if subtopic is ListConversationTopic {
            let prefixEvent: SAYSpeechEvent
            if recipes.count > 0 {
                prefixEvent = SAYSpeechEvent(utteranceString: "You have \(recipes.count) saved items:")
            }
            else {
                prefixEvent = SAYSpeechEvent(utteranceString: "You have no saved items.")
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
        listSubtopic?.resumeSpeaking()
        eventHandler.handlePlayCommand()
    }
    
    func handlePauseCommand()
    {
        listSubtopic?.pauseSpeaking()
        eventHandler.handlePauseCommand()
    }
    
    func handleNextCommand()
    {
        listSubtopic?.speakNextItem()
        eventHandler.handleNextCommand()
    }
    
    func handlePreviousCommand()
    {
        listSubtopic?.speakPreviousItem()
        eventHandler.handlePreviousCommand()
    }
    
    func beganSpeakingItemAtIndex(index: Int)
    {
        eventHandler.beganSpeakingItemAtIndex(index)
    }
    
    func finishedSpeakingItemAtIndex(index: Int)
    {
        eventHandler.finishedSpeakingItemAtIndex(index)
    }
    
    // MARK: Helpers
    
    private func stopSpeaking()
    {
        // TODO: Better way to interrupt speech on transitioning?
        postEvents(SAYAudioEventSequence(events: [SAYSilenceEvent(interval: 0.0)]))
    }
    
    private var listSubtopic: ListConversationTopic?
    private var recipes: [Recipe]!
}

protocol SavedRecipesConversationTopicEventHandler: class
{
    func handleRemoveRecipeCommand(command: SAYCommand)
    
    func handleSelectCommand(command: SAYCommand)
    func handleSearchCommand(command: SAYCommand)
    func handlePlayCommand()
    func handlePauseCommand()
    func handleNextCommand()
    func handlePreviousCommand()
    
    func beganSpeakingItemAtIndex(index: Int)
    func finishedSpeakingItemAtIndex(index: Int)
}
