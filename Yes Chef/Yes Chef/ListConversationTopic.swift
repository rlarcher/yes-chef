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
    
    init(items: [String], eventHandler: ListConversationTopicEventHandler)
    {
        self.eventHandler = eventHandler
        self.items = items
        
        super.init()
        
        let selectRecognizer = SAYSelectCommandRecognizer(responseTarget: eventHandler, action: "handleSelectCommand:")
        selectRecognizer.addMenuItemWithLabel("Select...")
        addCommandRecognizer(selectRecognizer)
        
        let searchRecognizer = SAYSearchCommandRecognizer(responseTarget: eventHandler, action: "handleSearchCommand:")
        searchRecognizer.addMenuItemWithLabel("Search...")
        addCommandRecognizer(searchRecognizer)

        // TODO: Add "filter" keyword to Search command.
        
        let playRecognizer = SAYPlayCommandRecognizer(responseTarget: eventHandler, action: "handlePlayCommand")
        playRecognizer.addMenuItemWithLabel("Play")
        addCommandRecognizer(playRecognizer)

        let pauseRecognizer = SAYPauseCommandRecognizer(responseTarget: eventHandler, action: "handlePauseCommand")
        pauseRecognizer.addMenuItemWithLabel("Pause")
        addCommandRecognizer(pauseRecognizer)

        let nextRecognizer = SAYNextCommandRecognizer(responseTarget: eventHandler, action: "handleNextCommand")
        nextRecognizer.addMenuItemWithLabel("Next")
        addCommandRecognizer(nextRecognizer)

        let previousRecognizer = SAYPreviousCommandRecognizer(responseTarget: eventHandler, action: "handlePreviousCommand")
        previousRecognizer.addMenuItemWithLabel("Previous")
        addCommandRecognizer(previousRecognizer)

        // TODO: Add recognizer for "Repeat"
        // TODO: Add recognizer for "Read all"
        // TODO: Add recognizer for "What's the __N'th__ step?"
    }
    
    var items: [String] {
        didSet {
            stopSpeaking()  // Don't continue with any existing speakItems sequence, else we might go out of bounds.
        }
    }
    
    func speakItems()
    {
        speakItems(startingAtIndex: 0)
    }
    
    func speakNextItem()
    {
        if headIndex < items.count - 1 {
            headIndex++
        }
        speakItems(startingAtIndex: headIndex)
    }
    
    func speakPreviousItem()
    {
        if headIndex > 0 {
            headIndex--
        }
        speakItems(startingAtIndex: headIndex)
    }
    
    func pauseSpeaking()
    {
        stopSpeaking()
    }
    
    func resumeSpeaking()
    {
        speakItems(startingAtIndex: headIndex)
    }
    
    // MARK: Helpers
    
    private func stopSpeaking()
    {
        // TODO: Better way to interrupt speech on transitioning?
        postEvents(SAYAudioEventSequence(events: [SAYSilenceEvent(interval: 0.0)]))
    }
    
    private func speakItems(startingAtIndex index: Int)
    {
        if items.count > 0 && index < items.count {
            let sequence = SAYAudioEventSequence()
            headIndex = index
            
            let remainingItems = items.suffixFrom(headIndex)
            
            for item in remainingItems {
                // TODO: This is a workaround for a "prefix" block. Proper way?
                sequence.addEvent(SAYSilenceEvent(interval: 0.0)) {
                    self.eventHandler.beganSpeakingItemAtIndex(self.headIndex)
                }
                sequence.addEvent(SAYSpeechEvent(utteranceString: "\(index + 1): \(item)")) {   // Speak the 1-based version of the index.
                    self.eventHandler.finishedSpeakingItemAtIndex(self.headIndex)
                    self.headIndex++
                }
            }
            
            self.postEvents(sequence)
        }
        else {
            // TODO: Do nothing?
        }
    }
    
    private var headIndex = 0   // The index currently being read
}

protocol ListConversationTopicEventHandler: class
{
    func beganSpeakingItemAtIndex(index: Int) // TODO: So any parent VC will know to highlight that cell, etc.
    func finishedSpeakingItemAtIndex(index: Int)
    
    func handleSelectCommand(command: SAYCommand)
    func handleSearchCommand(command: SAYCommand)
    func handlePlayCommand()
    func handlePauseCommand()
    func handleNextCommand()
    func handlePreviousCommand()
}
