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
    
    convenience init(items: [String], eventHandler: ListConversationTopicEventHandler)
    {
        self.init(items: items, listIsMutable: false, eventHandler: eventHandler)
    }
    
    init(items: [String], listIsMutable: Bool, eventHandler: ListConversationTopicEventHandler)
    {
        self.eventHandler = eventHandler
        self.items = items
        
        super.init()
        
        let selectRecognizer = SAYSelectCommandRecognizer(responseTarget: self, action: "handleSelectCommand:")
        selectRecognizer.addMenuItemWithLabel("Select...")
        addCommandRecognizer(selectRecognizer)

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

        if listIsMutable {
            let removeItemRecognizer = SAYCustomCommandRecognizer(customType: "RemoveItem", responseTarget: self, action: "handleRemoveItemCommand:")
            removeItemRecognizer.addTextMatcher(SAYPatternCommandMatcher(forPatterns: [
                "remove @item",
                "forget @item",
                "erase @item",
                "delete @item",
                "remove @itemNumber:Number",
                "forget @itemNumber:Number",
                "erase @itemNumber:Number",
                "delete @itemNumber:Number",
                "remove number @itemNumber:Number",
                "forget number @itemNumber:Number",
                "erase number @itemNumber:Number",
                "delete number @itemNumber:Number",
                "remove",
                "delete"
                ]))
            removeItemRecognizer.addMenuItemWithLabel("Remove Item")    // TODO: How can we customize this label based on context? (e.g. "Remove Recipe")
            addCommandRecognizer(removeItemRecognizer)
        }
        
        // TODO: Add recognizer for "Repeat"
        // TODO: Add recognizer for "Read all"
        // TODO: Add recognizer for "What's the __N'th__ step?"
    }
    
    var items: [String] {
        didSet {
            stopSpeaking()  // Don't continue with any existing speakItems sequence, else we might go out of bounds.
            headIndex = 0   // Reset head
        }
    }
    
    func speakItems()
    {
        if headIndex > 0 {
            isFlushingOldAudioSequence = true
        }
        speakItems(startingAtIndex: 0)
    }
    
    func speakNextItem()
    {
        if headIndex < items.count - 1 {
            headIndex++
        }
        isFlushingOldAudioSequence = true
        speakItems(startingAtIndex: headIndex)
    }
    
    func speakPreviousItem()
    {
        if headIndex > 0 {
            headIndex--
        }
        isFlushingOldAudioSequence = true
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
    
    // MARK: Handle Commands
    
    func handleSelectCommand(command: SAYCommand)
    {
        let selectedName = command.parameters[SAYSelectCommandRecognizerParameterItemName] as? String
        
        let selectedIndex: Int?
        if let index = command.parameters[SAYSelectCommandRecognizerParameterItemNumber] as? NSNumber {
            selectedIndex = index.integerValue
        }
        else if selectedName == nil {
            // User said "Select" without any parameters, so assume they meant to select the current item.
            selectedIndex = headIndex
        }
        else {
            selectedIndex = nil
        }
        
        eventHandler.selectedItemWithName(selectedName, index: selectedIndex)
    }
    
    func handleRemoveItemCommand(command: SAYCommand)
    {
        // TODO: Leverage the logic used in interpreting a SAYSelectRequest
        eventHandler.requestedRemoveItemWithName(nil, index: headIndex) // Temp.
    }
    
    // MARK: Speech
    
    private func stopSpeaking()
    {
        isFlushingOldAudioSequence = true
        
        // TODO: Better way to interrupt speech on transitioning?
        postEvents(SAYAudioEventSequence(events: [SAYSilenceEvent(interval: 0.0)]))
    }
    
    private func speakItems(startingAtIndex startIndex: Int)
    {
        if items.count > 0 && startIndex < items.count {
            let sequence = SAYAudioEventSequence()
            headIndex = startIndex
            var spokenIndex = startIndex
            
            let remainingItems = items.suffixFrom(headIndex)
            
            for item in remainingItems {
                // TODO: This is a workaround for a "prefix" block. Proper way?
                // TODO: Disabled for now. Seems to worsen Main Track leakage during VerbalCommandRequests.
//                sequence.addEvent(SAYSilenceEvent(interval: 0.0)) {
//                    self.eventHandler.beganSpeakingItemAtIndex(self.headIndex)
//                }
                sequence.addEvent(SAYSpeechEvent(utteranceString: "\(spokenIndex + 1): \(item)")) {   // Speak the 1-based version of the index.
                    if !self.isFlushingOldAudioSequence {
                        self.eventHandler.finishedSpeakingItemAtIndex(self.headIndex)
                        self.headIndex++
                    }
                }
                spokenIndex++
            }
            
            // Terminal event to release the flushing lock
            sequence.addEvent(SAYSilenceEvent(interval: 0.0)) {
                self.isFlushingOldAudioSequence = false
            }
            
            self.postEvents(sequence)
        }
        else {
            // TODO: Do nothing?
        }
    }
    
    private var headIndex = 0   // The index currently being read
    private var isFlushingOldAudioSequence: Bool = false    // Hack to suppress speech event completion blocks when we don't care about them (ie, when interrupting the sequence with a new one).
}

protocol ListConversationTopicEventHandler: class
{
    func beganSpeakingItemAtIndex(index: Int) // TODO: So any parent VC will know to highlight that cell, etc.
    func finishedSpeakingItemAtIndex(index: Int)
    
    func selectedItemWithName(name: String?, index: Int?)
    /*optional*/ func requestedRemoveItemWithName(name: String?, index: Int?)
    
    func handlePlayCommand()
    func handlePauseCommand()
    func handleNextCommand()
    func handlePreviousCommand()
}

extension ListConversationTopicEventHandler
{
    func requestedRemoveItemWithName(name: String?, index: Int?)
    {
        // Default implementation does nothing. Effectively makes this function optional, since anyone implementing `ListConversationTopicEventHandler` will use this implementation by default.
        // This is an alternative to adding the @objc decorator to the protocol and using the `optional` keyword, which requires all types to be applicable in Objective C (which `Int` is not).
    }
}
