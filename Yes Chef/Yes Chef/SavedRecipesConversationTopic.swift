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
        listSubtopic?.items = recipes.map({ $0.listing.speakableString })
    }
    
    func speakSavedRecipes()
    {
        listSubtopic?.speakItems()
    }
    
    // MARK: Lifecycle
    
    func topicDidGainFocus()
    {
        listSubtopic = buildSavedListSubtopic()
        addSubtopic(listSubtopic!)
        CommandBarController.setPlaybackControlsDelegate(listSubtopic)        
        speakSavedRecipes()
    }
    
    func topicDidLoseFocus()
    {
        stopSpeaking()
        removeAllSubtopics()
        CommandBarController.setPlaybackControlsDelegate(nil)        
    }
    
    // MARK: Subtopic Handling
    
    override func subtopic(subtopic: SAYConversationTopic, didPostEventSequence sequence: SAYAudioEventSequence)
    {
        // TODO: Should be unnecessary to override this functions just to pass the sequence through to `postEvents:`. Investigate.
        self.postEvents(sequence)
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
            speakSelectionFailed(name, index: index)
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
    
    private func buildSavedListSubtopic() -> ListConversationTopic
    {
        let listTopic = ListConversationTopic(items: recipes.map({ $0.listing.speakableString }), listIsMutable: true, shouldUseFallthroughForSelection: true, eventHandler: self)
        let savedRecipe = _prompt("saved_recipes:alias", comment: "How we'll refer to a single Saved Recipe in the next prompt, saved_recipes:X_available")
        let introFormat = _prompt("saved_recipes:X_available", comment: "Intro string for the list of saved recipes")
        listTopic.introString = recipes.count > 0 ?
            String(format: introFormat, recipes.count.withSuffix(savedRecipe)) :
            _prompt("saved_recipes:none_available", comment: "Intro string for the (empty) list of saved recipes")
        
        listTopic.intermediateHelpString = _prompt("saved_recipes:intermediate_help", comment: "Spoken after the first few items in the list of saved recipes")
        listTopic.outroString = _prompt("saved_recipes:outro", comment: "Call to action after reading the list of saved recipes")
        
        return listTopic
    }
    
    private func speakSelectionFailed(name: String?, index: Int?)
    {
        let utteranceString: String
        if let listingName = name {
            let format = _prompt("list:unable_to_select_by_name_X", comment: "Spoken when we couldn't select an item by a given name")
            utteranceString = String(format: format, listingName)
        }
        else if let listingIndex = index {
            let format = _prompt("list:unable_to_select_by_number_X", comment: "Spoken when we couldn't select an item by its number in a list")
            utteranceString = String(format: format, listingIndex)
        }
        else {
            utteranceString = _prompt("list:unable_to_select", comment: "Spoken when we couldn't select an item, and name/number are unknown")
        }
        
        postEvents(SAYAudioEventSequence(events: [SAYSpeechEvent(utteranceString: utteranceString)]))
    }
    
    func recipeWithName(name: String) -> Recipe?
    {
        let recipesNames = recipes.map({ $0.name })
        if let matchingIndex = Utils.fuzzyIndexOfItemWithName(name, inList: recipesNames) {
            return recipes[matchingIndex]
        }
        else {
            return nil
        }
    }
    
    func recipeAtIndex(index: Int) -> Recipe?
    {
        if index >= 0 && index < recipes.count {
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
