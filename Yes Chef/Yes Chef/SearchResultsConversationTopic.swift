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
        
        self.addSubtopic(ListConversationTopic(eventHandler: self))
    }
    
    func speakResults(recipes: [Recipe], forQuery query: String)
    {
        self.searchQuery = query    // Hold on to these for upcoming `subtopic:didPostEventSequence:`
        self.recipes = recipes
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
        if let query = self.searchQuery where subtopic is ListConversationTopic {
            let prefixEvent: SAYSpeechEvent
            if let itemCount = recipes?.count {
                prefixEvent = SAYSpeechEvent(utteranceString: "I found \(itemCount) results for \"\(query)\":")
            }
            else {
                prefixEvent = SAYSpeechEvent(utteranceString: "Here are the results for \"\(query)\":")
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
    
    private var recipes: [Recipe]?
    private var searchQuery: String?
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
