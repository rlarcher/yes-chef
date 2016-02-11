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
        
        let selectRecognizer = SAYSelectCommandRecognizer(responseTarget: eventHandler, action: "handleSelectCommand:")
        addCommandRecognizer(selectRecognizer)
        
        let searchRecognizer = SAYSearchCommandRecognizer(responseTarget: eventHandler, action: "handleSearchCommand:")
        addCommandRecognizer(searchRecognizer)

        // TODO: Add "filter" keyword to Search command.
        
        let playRecognizer = SAYPlayCommandRecognizer(responseTarget: eventHandler, action: "handlePlayCommand")
        addCommandRecognizer(playRecognizer)

        let pauseRecognizer = SAYPauseCommandRecognizer(responseTarget: eventHandler, action: "handlePauseCommand")
        addCommandRecognizer(pauseRecognizer)

        let nextRecognizer = SAYNextCommandRecognizer(responseTarget: eventHandler, action: "handleNextCommand")
        addCommandRecognizer(nextRecognizer)

        let previousRecognizer = SAYPreviousCommandRecognizer(responseTarget: eventHandler, action: "handlePreviousCommand")
        addCommandRecognizer(previousRecognizer)

        // TODO: Add recognizer for "Repeat"
        // TODO: Add recognizer for "Read all"
        // TODO: Add recognizer for "What's the __N'th__ step?"
        
        addMenuItem(selectRecognizer.menuItemWithLabel("Select..."))
        addMenuItem(searchRecognizer.menuItemWithLabel("Search..."))
        addMenuItem(playRecognizer.menuItemWithLabel("Play"))
        addMenuItem(pauseRecognizer.menuItemWithLabel("Pause"))
        addMenuItem(nextRecognizer.menuItemWithLabel("Next"))
        addMenuItem(previousRecognizer.menuItemWithLabel("Previous"))
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
