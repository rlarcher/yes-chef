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
        listSubtopic = ListConversationTopic(items: recipes.map({ $0.speakableString }), listIsMutable: true, eventHandler: self)
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
    
    func selectedItemWithName(name: String?, index: Int?)
    {
        if
            let recipeName = name,
            let selectedRecipe = recipeWithName(recipeName)
        {
            eventHandler.selectedRecipe(selectedRecipe)
        }
        else if
            let recipeIndex = index,
            let selectedRecipe = recipeAtIndex(recipeIndex)
        {
            eventHandler.selectedRecipe(selectedRecipe)
        }
        else {
            speakSelectionFailed()
            eventHandler.selectedRecipe(nil)
        }
    }
    
    func requestedRemoveItemWithName(name: String?, index: Int?)
    {
        if let indexToRemove = index {
            eventHandler.requestedRemoveItemWithName(name, index: indexToRemove)
        }
        else {
            // TODO: Present a clarification request, "Remove what?"
        }
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
    }
    
    func handlePreviousCommand()
    {
        listSubtopic?.speakPreviousItem()
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
    
    private func speakSelectionFailed()
    {
        postEvents(SAYAudioEventSequence(events: [SAYSpeechEvent(utteranceString: "I couldn't select an item by that name or number. Please try again.")]))
    }
    
    func recipeWithName(name: String) -> Recipe?
    {
        let matchingRecipe = recipes.filter({ $0.name.lowercaseString.containsString(name.lowercaseString) }).first // TODO: Improve how we check for a match
        return matchingRecipe
    }
    
    func recipeAtIndex(index: Int) -> Recipe?
    {
        if index > 0 && index < recipes.count {
            return recipes[index]
        }
        else {
            return nil
        }
    }
    
    private var listSubtopic: ListConversationTopic?
    private var recipes: [Recipe]!
}

protocol SavedRecipesConversationTopicEventHandler: class
{
    func selectedRecipe(recipe: Recipe?)
    func requestedRemoveItemWithName(name: String?, index: Int)

    func handlePlayCommand()
    func handlePauseCommand()
    
    func beganSpeakingItemAtIndex(index: Int)
    func finishedSpeakingItemAtIndex(index: Int)
}
