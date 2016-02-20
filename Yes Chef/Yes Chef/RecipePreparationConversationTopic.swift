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
            if text.containsAny(["oven", "temperature", "how hot"]) {
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
            if text.containsAny(["what do I do", "what do", "what steps", "what are the steps", "steps"]) {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceVeryLikely)
            }
            else {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceNone)
            }
        }))
        whatDoIDoRecognizer.addMenuItemWithLabel("Preparation Steps")
        addCommandRecognizer(whatDoIDoRecognizer)
        
        let preparationTimeRecognizer = SAYCustomCommandRecognizer(customType: "PreparationTime", responseTarget: eventHandler, action: "handlePreparationTimeCommand")
        preparationTimeRecognizer.addTextMatcher(SAYBlockCommandMatcher(block: { text -> SAYCommandSuggestion? in
            if text.containsAny(["time", "how long", "preparation", "prep", "long"]) {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceVeryLikely)
            }
            else {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceNone)
            }
        }))
        preparationTimeRecognizer.addMenuItemWithLabel("Preparation Time")
        addCommandRecognizer(preparationTimeRecognizer)
    }
    
    // This must be called before attempting to speak.
    func updateRecipe(recipe: Recipe)
    {
        self.recipe = recipe
        listSubtopic?.items = recipe.preparationSteps
    }
    
    func topicDidGainFocus()
    {
        listSubtopic = buildPreparationListSubtopic()
        addSubtopic(listSubtopic!)
    }
    
    func topicDidLoseFocus()
    {
        stopSpeaking()        
        removeAllSubtopics()
    }
    
    override func subtopic(subtopic: SAYConversationTopic, didPostEventSequence sequence: SAYAudioEventSequence)
    {
        // TODO: Should be unnecessary to override this functions just to pass the sequence through to `postEvents:`. Investigate.
        self.postEvents(sequence)
    }
    
    // MARK: ListConversationTopicEventHandler Protocol Methods
    // TODO: Using these as pass-through only. Better way?
    
    func selectedItemWithName(name: String?, index: Int?)
    {
        eventHandler.selectedItemWithName(name, index: index)
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
    
    // MARK: Speech
    
    func speakPreparationSteps()
    {
        listSubtopic?.speakItems()
    }
    
    func speakOvenTemperature()
    {
        postEvents(SAYAudioEventSequence(events:[SAYSpeechEvent(utteranceString: "Sorry, I don't know what temperature the oven should be.")]))
    }
    
    func speakPreparationTime()
    {
        let sequence = SAYAudioEventSequence()
        
        let utteranceString: String
        if let totalPrepTime = recipe.totalPreparationTime {
            if let activePrepTime = recipe.activePreparationTime {
                utteranceString = "This recipe will take \(totalPrepTime.withSuffix("minute")) to complete (\(activePrepTime.withSuffix("minute")) active)."
            }
            else {
                utteranceString = "This recipe will take \(totalPrepTime.withSuffix("minute")) to complete."
            }
        }
        else {
            utteranceString = "I don't know how long this recipe will take."
        }
        
        sequence.addEvent(SAYSpeechEvent(utteranceString: utteranceString))
        postEvents(sequence)
    }
    
    // MARK: Helpers
    
    func stopSpeaking()
    {
        // TODO: Better way to interrupt speech on transitioning?
        postEvents(SAYAudioEventSequence(events: [SAYSilenceEvent(interval: 0.0)]))
    }
    
    private func buildPreparationListSubtopic() -> ListConversationTopic
    {
        let listTopic = ListConversationTopic(items: recipe.preparationSteps, eventHandler: self)
        let count = recipe.preparationSteps.count
        listTopic.introString = count > 0 ?
                                    "There \("is".plural(count, pluralForm: "are")) \(count.withSuffix("step")) to this recipe:" :
                                    "There are no preparation steps for this recipe."
        listTopic.intermediateHelpString = "You can say \"Pause\" at any time if you need a minute."
        listTopic.outroString = "You can say \"Repeat\" to listen to the instructions again, or skip around by saying \"What's the third step?\""
        
        return listTopic
    }
    
    private var listSubtopic: ListConversationTopic?
    private var recipe: Recipe!
}

protocol RecipePreparationConversationTopicEventHandler: class
{
    func selectedItemWithName(name: String?, index: Int?)

    func handlePlayCommand()
    func handlePauseCommand()
    
    func beganSpeakingItemAtIndex(index: Int)
    func finishedSpeakingItemAtIndex(index: Int)
    
    func handleWhatDoIDoCommand()
    func handleOvenTemperatureCommand()
    func handlePreparationTimeCommand()
}
