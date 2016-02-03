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
        
        self.addCommandRecognizer(SAYAvailableCommandsCommandRecognizer(responseTarget: eventHandler, action: "handleAvailableCommands"))
        self.addCommandRecognizer(SAYSearchCommandRecognizer(responseTarget: eventHandler, action: "handleSearchCommand:"))
        // TODO: Add recognizer for search with categories
        self.addCommandRecognizer(SAYHomeCommandRecognizer(responseTarget: eventHandler, action: "handleHomeCommand"))
        self.addCommandRecognizer(SAYBackCommandRecognizer(responseTarget: eventHandler, action: "handleBackCommand"))
        // TODO: Add recognizer for "How do I __do action__?"
        // TODO: Add recognizer for "What is __feature__?"
        // TODO: Add recognizer for "What are the categories?"
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
    func handleSearchCommand(command: SAYCommand)
    func handleHomeCommand()
    func handleBackCommand()
}
