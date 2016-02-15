//
//  HomeConversationTopic.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class HomeConversationTopic: SAYConversationTopic
{
    let eventHandler: HomeConversationTopicEventHandler
    
    init(eventHandler: HomeConversationTopicEventHandler)
    {
        self.eventHandler = eventHandler
        
        super.init()
        
        let availableCommandsRecognizer = SAYAvailableCommandsCommandRecognizer(responseTarget: eventHandler, action: "handleAvailableCommands")
        availableCommandsRecognizer.addMenuItemWithLabel("Available Commands")
        addCommandRecognizer(availableCommandsRecognizer)
        
        let searchRecognizer = SAYSearchCommandRecognizer(responseTarget: self, action: "handleSearchCommand:")
        searchRecognizer.addMenuItemWithLabel("Search...")
        addCommandRecognizer(searchRecognizer)
        
        let homeRecognizer = SAYHomeCommandRecognizer(responseTarget: eventHandler, action: "handleHomeCommand")
        homeRecognizer.addMenuItemWithLabel("Home")
        addCommandRecognizer(homeRecognizer)
        
        let backRecognizer = SAYBackCommandRecognizer(responseTarget: eventHandler, action: "handleBackCommand")
        backRecognizer.addMenuItemWithLabel("Back")
        addCommandRecognizer(backRecognizer)

        // TODO: Add recognizer for "How do I __do action__?"
        // TODO: Add recognizer for "What is __feature__?"
        // TODO: Add recognizer for "What are the categories?"
    }
    
    func topicDidGainFocus()
    {
        removeAllSubtopics() // TODO: Think of a better way to clean up popped subtopics. Override navigation methods? Independent navigation management?
    }
    
    func topicDidLoseFocus()
    {
        // Do nothing
    }
    
    func handleSearchCommand(command: SAYCommand)
    {
        if let searchQuery = command.parameters[SAYSearchCommandRecognizerParameterQuery] as? String {
            let category = Category.categoryFoundInText(searchQuery)
            let cuisine = Cuisine.cuisineFoundInText(searchQuery)
            self.eventHandler.requestedSearchUsingQuery(searchQuery, category: category, cuisine: cuisine)
        }
        else {
            self.eventHandler.requestedSearchUsingQuery(nil, category: nil, cuisine: nil)
        }
    }
    
    override func subtopic(subtopic: SAYConversationTopic, didPostEventSequence sequence: SAYAudioEventSequence)
    {
        let outgoingSequence = sequence
        
        let silenceEvent = SAYSilenceEvent(interval: 10.0)
        let helpMessageEvent = SAYSpeechEvent(utteranceString: "Say \"Search\" followed by the name of a recipe to perform a search. If you need help, say \"Help\".")
    
        outgoingSequence.appendSequence(SAYAudioEventSequence(events: [silenceEvent, helpMessageEvent]))
        
        self.postEvents(outgoingSequence)
    }
}

protocol HomeConversationTopicEventHandler: class
{
    func handleAvailableCommands()
    func requestedSearchUsingQuery(searchQuery: String?, category: Category?, cuisine: Cuisine?)
    func handleHomeCommand()
    func handleBackCommand()
}
