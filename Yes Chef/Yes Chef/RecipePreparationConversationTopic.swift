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
        
        let ovenTemperatureRecognizer = SAYCustomCommandRecognizer(customType: "OvenTemperature", responseTarget: eventHandler, action: "handleOvenTemperatureCommand")
        ovenTemperatureRecognizer.addTextMatcher(SAYBlockCommandMatcher(block: { text -> SAYCommandSuggestion? in
            // Recognize phrases like "What temperature do I set the oven?", "How hot should the oven be?"
            if text.containsString("oven") || text.containsString("temperature") || text.containsString("how hot") {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceVeryLikely)
            }
            else {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceNone)
            }
        }))
        ovenTemperatureRecognizer.addMenuItemWithLabel("Oven Temperature")
        addCommandRecognizer(ovenTemperatureRecognizer)
        
        let whatDoIDoRecognizer = SAYCustomCommandRecognizer(customType: "WhatDoIDo", responseTarget: eventHandler, action: "handleWhatDoIDoCommand")
        whatDoIDoRecognizer.addTextMatcher(SAYBlockCommandMatcher(block: { text -> SAYCommandSuggestion? in
            // Recognize phrases like "What do I do?", "What are the steps?"
            if text.containsString("what do I do") || text.containsString("what do") || text.containsString("what steps") || text.containsString("what are the steps") || text.containsString("steps") {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceVeryLikely)
            }
            else {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceNone)
            }
        }))
        whatDoIDoRecognizer.addMenuItemWithLabel("Preparation Steps")
        addCommandRecognizer(whatDoIDoRecognizer)
        
        // TODO: Add command recognizer for preparation time
    }
    
    // This must be called before attempting to speak.
    func updateRecipe(recipe: Recipe)
    {
        self.recipe = recipe
        listSubtopic?.items = recipe.preparationSteps
    }
    
    func topicDidGainFocus()
    {
        listSubtopic = ListConversationTopic(items: recipe.preparationSteps, eventHandler: self)
        addSubtopic(listSubtopic!)
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
    
    func stopSpeaking()
    {
        // TODO: Better way to interrupt speech on transitioning?
        postEvents(SAYAudioEventSequence(events: [SAYSilenceEvent(interval: 0.0)]))
    }
    
    func speakPreparationSteps()
    {
        listSubtopic?.speakItems()
    }
    
    func speakOvenTemperature()
    {
        // TODO
        print("RecipePreparationCT speakOvenTemperature")
    }
    
    private var listSubtopic: ListConversationTopic?
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
    
    func beganSpeakingItemAtIndex(index: Int)
    func finishedSpeakingItemAtIndex(index: Int)
    
    func handleWhatDoIDoCommand()
    func handleOvenTemperatureCommand()
}
