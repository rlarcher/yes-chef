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
    var searchQuery: String!
    let eventHandler: SearchResultsConversationTopicEventHandler
    
    init(eventHandler: SearchResultsConversationTopicEventHandler)
    {
        self.eventHandler = eventHandler
        
        super.init()
        
        self.addSubtopic(ListConversationTopic(eventHandler: self))
        
        // TODO: Add command recognizer for "Remove __recipe__".
    }
    
    func speakResults(recipes: [Recipe], forQuery query: String)    // TODO: Better way to persist `query`?
    {
        self.searchQuery = query
        if let listSubtopic = self.subtopics.first as? ListConversationTopic {
            listSubtopic.speakItems(recipes.map { $0.speakableString })
        }
    }
    
    func stopSpeaking()
    {
        // TODO: Better way to interrupt speech on transitioning?
        postEvents(SAYAudioEventSequence(events: [SAYSilenceEvent(interval: 0.0)]))
    }
    
    override func subtopic(subtopic: SAYConversationTopic, didPostEventSequence sequence: SAYAudioEventSequence)
    {
        if let listSubtopic = subtopic as? ListConversationTopic {
            let prefixEvent: SAYSpeechEvent
            if let itemCount = listSubtopic.itemCount {
                prefixEvent = SAYSpeechEvent(utteranceString: "I found \(itemCount) results for \"\(searchQuery)\":") // TODO: Better way to get the itemCount here?
            }
            else {
                prefixEvent = SAYSpeechEvent(utteranceString: "Here are the results for \"\(searchQuery)\":")
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
        eventHandler.handlePlayCommand()
    }
    
    func handlePauseCommand()
    {
        eventHandler.handlePauseCommand()
    }
    
    func handleNextCommand()
    {
        eventHandler.handleNextCommand()
    }
    
    func handlePreviousCommand()
    {
        eventHandler.handlePreviousCommand()
    }
}

protocol SearchResultsConversationTopicEventHandler: class
{
    func handleSelectCommand(command: SAYCommand)
    func handleSearchCommand(command: SAYCommand)
    func handlePlayCommand()
    func handlePauseCommand()
    func handleNextCommand()
    func handlePreviousCommand()
}
