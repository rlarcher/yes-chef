//
//  SearchResultsConversationTopic.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class SearchResultsConversationTopic: SAYConversationTopic, ListConversationTopicEventHandler
{
    let eventHandler: SearchResultsConversationTopicEventHandler
    
    init(eventHandler: SearchResultsConversationTopicEventHandler)
    {
        self.eventHandler = eventHandler
        
        super.init()
    }
    
    // This must be called before attempting to speak.
    func updateResults(results: [RecipeListing])
    {
        self.recipeListings = results
        listSubtopic?.items = recipeListings.map({ $0.speakableString })
    }

    // This must be called before attempting to speak.
    func updateSearchQuery(query: String)
    {
        self.searchQuery = query
    }
    
    func speakResults()
    {
        listSubtopic?.speakItems()
    }
    
    // MARK: Lifecycle
    
    func topicDidGainFocus()
    {
        listSubtopic = ListConversationTopic(items: recipeListings.map({ $0.speakableString }), eventHandler: self)
        addSubtopic(listSubtopic!)
        speakResults()
    }
    
    func topicDidLoseFocus()
    {
        stopSpeaking()
        if let subtopic = listSubtopic {
            removeSubtopic(subtopic)
        }
    }

    // MARK: Subtopic Handling
    
    override func subtopic(subtopic: SAYConversationTopic, didPostEventSequence sequence: SAYAudioEventSequence)
    {
        if subtopic is ListConversationTopic {
            let prefixEvent: SAYSpeechEvent
            if recipeListings.count > 0 {
                prefixEvent = SAYSpeechEvent(utteranceString: "I found \(recipeListings.count) results for \"\(searchQuery)\":")
            }
            else {
                prefixEvent = SAYSpeechEvent(utteranceString: "There were no results for \"\(searchQuery)\".")
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
    
    func selectedItemWithName(name: String?, index: Int?)
    {
        eventHandler.selectedItemWithName(name, index: index)
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
    
    private func stopSpeaking()
    {
        // TODO: Better way to interrupt speech on transitioning?
        postEvents(SAYAudioEventSequence(events: [SAYSilenceEvent(interval: 0.0)]))
    }
    
    private var listSubtopic: ListConversationTopic?
    private var recipeListings: [RecipeListing]!
    private var searchQuery: String!
}

protocol SearchResultsConversationTopicEventHandler: class
{
    func selectedItemWithName(name: String?, index: Int?)
    func handleSearchCommand(command: SAYCommand)
    func handlePlayCommand()
    func handlePauseCommand()
    func handleNextCommand()
    func handlePreviousCommand()
    
    func beganSpeakingItemAtIndex(index: Int)
    func finishedSpeakingItemAtIndex(index: Int)
}
