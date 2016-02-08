//
//  ListConversationTopic.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class ListConversationTopic: SAYConversationTopic
{
    let eventHandler: ListConversationTopicEventHandler
    
    init(eventHandler: ListConversationTopicEventHandler)
    {
        self.eventHandler = eventHandler
        
        super.init()
        
        self.addCommandRecognizer(SAYSelectCommandRecognizer(responseTarget: eventHandler, action: "handleSelectCommand:"))
        self.addCommandRecognizer(SAYSearchCommandRecognizer(responseTarget: eventHandler, action: "handleSearchCommand:"))
        // TODO: Add "filter" keyword to Search command.
        self.addCommandRecognizer(SAYPlayCommandRecognizer(responseTarget: eventHandler, action: "handlePlayCommand"))
        self.addCommandRecognizer(SAYPauseCommandRecognizer(responseTarget: eventHandler, action: "handlePauseCommand"))
        self.addCommandRecognizer(SAYNextCommandRecognizer(responseTarget: eventHandler, action: "handleNextCommand"))
        self.addCommandRecognizer(SAYPreviousCommandRecognizer(responseTarget: eventHandler, action: "handlePreviousCommand"))
        // TODO: Add recognizer for "Repeat"
        // TODO: Add recognizer for "Read all"
    }
    
    func speakItems(items: [String])
    {
        if items.count > 0 {
            let sequence = SAYAudioEventSequence()
            var index = 1
            
            for item in items {
                sequence.addEvent(SAYSpeechEvent(utteranceString: "\(index): \(item)"))
                index++
            }
            
            self.postEvents(sequence)
        }
        else {
            // TODO: Do nothing?
        }
    }
}

protocol ListConversationTopicEventHandler: class
{
    func handleSelectCommand(command: SAYCommand)
    func handleSearchCommand(command: SAYCommand)
    func handlePlayCommand()
    func handlePauseCommand()
    func handleNextCommand()
    func handlePreviousCommand()
}
