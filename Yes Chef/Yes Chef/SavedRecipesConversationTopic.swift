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
        
        self.addSubtopic(ListConversationTopic(eventHandler: self))
        
        // TODO: Add command recognizer for "Remove __recipe__".
    }
    
    func speakSavedRecipes(recipes: [Recipe])
    {
        if let listSubtopic = self.subtopics.first as? ListConversationTopic {
            // TODO: Parse out each Recipe into a single speakable string.
            listSubtopic.speakItems(recipes.map { "\($0.name). \($0.rating) stars. Requires \(String($0.preparationTime)) minutes of preparation and \($0.ingredients.count) different ingredients." }) // TODO: Format prepTime.
        }
    }
    
    override func subtopic(subtopic: SAYConversationTopic, didPostEventSequence sequence: SAYAudioEventSequence)
    {
        if let listSubtopic = subtopic as? ListConversationTopic {
            let prefixEvent: SAYSpeechEvent
            if let itemCount = listSubtopic.itemCount {
                prefixEvent = SAYSpeechEvent(utteranceString: "You have \(itemCount) saved items:") // TODO: Better way to get the itemCount here?
            }
            else {
                prefixEvent = SAYSpeechEvent(utteranceString: "Here are your saved items:")
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
}
