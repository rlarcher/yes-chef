//
//  ListConversationTopic.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

/// `ListConversationTopic` is a conversation topic that handles many common list-based commands and behaviors, such as playback controls, selection, item reading, and help messaging.
/// This is a working prototype. Stay tuned for a pre-packaged SAYListConversationTopic!
class ListConversationTopic: SAYConversationTopic
{
    let eventHandler: ListConversationTopicEventHandler
    
    var introString: String?
    var intermediateHelpString: String?
    var outroString: String?
    
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

        let repeatRecognizer = SAYCustomCommandRecognizer(customType: "Repeat", responseTarget: self, action: "handleRepeatCommand")
        repeatRecognizer.addTextMatcher(SAYBlockCommandMatcher(block: { text -> SAYCommandSuggestion? in
            if text.containsAny(["repeat", "again", "what did you say", "what was that"]) {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceVeryLikely)
            }
            else {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceNone)
            }
        }))
        repeatRecognizer.addMenuItemWithLabel("Repeat")
        addCommandRecognizer(repeatRecognizer)
        
        let readAllRecognizer = SAYCustomCommandRecognizer(customType: "ReadAll", responseTarget: self, action: "handleReadAllCommand")
        readAllRecognizer.addTextMatcher(SAYBlockCommandMatcher(block: { text -> SAYCommandSuggestion? in
            if text.containsAny(["read all", "read everything", "repeat everything"]) {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceVeryLikely)
            }
            else {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceNone)
            }
        }))
        readAllRecognizer.addMenuItemWithLabel("Read All")
        addCommandRecognizer(readAllRecognizer)
        
        let readItemRecognizer = SAYCustomCommandRecognizer(customType: "ReadItem", responseTarget: self, action: "handleReadItemCommand:")
        readItemRecognizer.addTextMatcher(SAYPatternCommandMatcher(patterns: [
            "read step @itemNumber:Number",
            "read step number @itemNumber:Number",
            "read the @itemNumber:Number step",
            "read @itemNumber:Number",
            "read item @itemNumber:Number",
            "read the @itemNumber:Number item",
            "read number @itemNumber:Number",
            "what is the @itemNumber:Number step",
            "what is the @itemNumber:Number item",
            "what is step number @itemNumber:Number",
            "what is item number @itemNumber:Number",
            "what is step @itemNumber:Number",
            "what is item @itemNumber:Number",
            "what's the @itemNumber:Number step",
            "what's the @itemNumber:Number item",
            "what's step number @itemNumber:Number",
            "what's item number @itemNumber:Number",
            "what's step @itemNumber:Number",
            "what's item @itemNumber:Number"
            ]))
        readItemRecognizer.addMenuItemWithLabel("Read Item Number...")
        addCommandRecognizer(readItemRecognizer)
        
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
            
            // TODO: Add "filter" keyword to Search command.
        }
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
        incrementHeadIndex()
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
    
    func handleRepeatCommand()
    {
        if headIndex > items.count {
            speakPreviousItem()
        }
        else {
            isFlushingOldAudioSequence = true
            speakItems(startingAtIndex: headIndex)
        }
    }
    
    func handleReadAllCommand()
    {
        speakItems()
    }
    
    func handleReadItemCommand(command: SAYCommand)
    {
        if let itemNumber = command.parameters["itemNumber"] as? NSNumber {
            let index = max(itemNumber.integerValue - 1, 0)     // Interpret spoken number as 1-based index. Convert to 0-based index.
            if index < items.count {
                isFlushingOldAudioSequence = true
                speakItems(startingAtIndex: index)
                return
            }
        }
        
        // TODO: Handle error - followup clarification?
        print("ListCT failed to interpret read step number")
    }
    
    func handleSelectCommand(command: SAYCommand)
    {
        let selectedName = command.parameters[SAYSelectCommandRecognizerParameterItemName] as? String
        
        let selectedIndex: Int?
        if let index = command.parameters[SAYSelectCommandRecognizerParameterItemNumber] as? NSNumber {
            selectedIndex = max(index.integerValue - 1, 0)  // Convert from spoken 1-based number to 0-based index
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
            var sequence = SAYAudioEventSequence()
            headIndex = startIndex
            
            let remainingItems = items.suffixFrom(headIndex) // TODO: Find an alternative where we can preserve the item's true index, but don't speak anything prior to startIndex
            
            for (index, item) in remainingItems.enumerate() {
                // TODO: This is a workaround for a "prefix" block. Proper way?
                // TODO: Disabled for now. Seems to worsen Main Track leakage during VerbalCommandRequests.
//                sequence.addEvent(SAYSilenceEvent(interval: 0.0)) {
//                    self.eventHandler.beganSpeakingItemAtIndex(index)
//                }
                sequence.addEvent(SAYSpeechEvent(utteranceString: "\(index + 1): \(item)")) {   // Speak the 1-based version of the index.
                    if !self.isFlushingOldAudioSequence {
                        self.eventHandler.finishedSpeakingItemAtIndex(self.headIndex)
                        self.incrementHeadIndex()
                    }
                }
            }
            
            sequence = insertHelpMessagesIntoSequence(sequence)
            
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
    
    private func incrementHeadIndex()
    {
        if headIndex < items.count - 1 {
            headIndex++
        }
    }
    
    private func insertHelpMessagesIntoSequence(sequence: SAYAudioEventSequence) -> SAYAudioEventSequence
    {
        let helpIndex = 2
        
        if introString == nil && intermediateHelpString == nil && outroString == nil {
            // If no help messages have been defined, do nothing.
            return sequence
        }
        
        var outgoingEvents = sequence.items().map({ $0.event })
        
        // Insert help and outro message events.
        if items.count > 5 {    // Arbitrary! If there's more than this many items, we don't need to worry about the Help and Outro messages being spoken too close together.
            // Long List. If defined, speak a help message after the third item, and an outro message at the end of the list.
            if let help = intermediateHelpString {
                outgoingEvents.insert(SAYSpeechEvent(utteranceString: help), atIndex: helpIndex)
            }
            if let outro = outroString {
                outgoingEvents.append(SAYSpeechEvent(utteranceString: outro))
            }
        }
        else if items.count > helpIndex {
            // Medium-length List. If defined, speak a help message after the third item. If the outro message is unique, speak it at the end of the list (ie, if the outro is the same as the help message, we'd be repeating our message from just a few items ago).
            if let help = intermediateHelpString {
                outgoingEvents.insert(SAYSpeechEvent(utteranceString: help), atIndex: helpIndex)
            }
            if let outro = outroString where outro != intermediateHelpString {
                outgoingEvents.append(SAYSpeechEvent(utteranceString: outro))
            }
        }
        else {
            // Short List. If defined, speak a help message at the end of the list. If the outro message is unique, speak it also (ie, if the outro is the same as the help message, we'd be saying the same thing twice).
            if let help = intermediateHelpString {
                outgoingEvents.append(SAYSpeechEvent(utteranceString: help))
            }
            if let outro = outroString where outro != intermediateHelpString {
                outgoingEvents.append(SAYSpeechEvent(utteranceString: outro))
            }
        }
        
        // Insert introduction message event.
        if let intro = introString {
            outgoingEvents.insert(SAYSpeechEvent(utteranceString: intro), atIndex: 0)
        }
        
        return SAYAudioEventSequence(events: outgoingEvents)
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
