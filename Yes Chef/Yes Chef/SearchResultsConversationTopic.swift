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
    
    func speakErrorMessage(message: String)
    {
        postEvents(SAYAudioEventSequence(events: [SAYSpeechEvent(utteranceString: message)]))
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
            var outgoingEvents = sequence.items().map({ $0.event })
            
            // Speak a help message after the 3rd item.
            if recipeListings.count > 3 {
                let helpString = "To inspect a recipe, say \"Select\" followed by the recipe's name or number."
                outgoingEvents.insert(SAYSpeechEvent(utteranceString: helpString), atIndex: 3)
            }
            
            // Speak an introduction before the first item.
            let prefixString = recipeListings.count > 0 ?
                "I found \(recipeListings.count) results for \"\(searchQuery)\":" :
                "There were no results for \"\(searchQuery)\"."
            outgoingEvents.insert(SAYSpeechEvent(utteranceString: prefixString), atIndex: 0)
            
            // Speak an outro after the last item.
            let suffixString = "Say \"More\" for more recipes (coming soon)."
            outgoingEvents.append(SAYSpeechEvent(utteranceString: suffixString))
            
            postEvents(SAYAudioEventSequence(events: outgoingEvents))
        }
        else {
            postEvents(sequence)
        }
    }
    
    // MARK: ListConversationTopicEventHandler Protocol Methods
    // TODO: Using these as pass-through only. Better way?
    
    func selectedItemWithName(name: String?, index: Int?)
    {
        if
            let listingName = name,
            let selectedListing = recipeListingWithName(listingName)
        {
            eventHandler.selectedRecipeListing(selectedListing)
        }
        else if
            let listingIndex = index,
            let selectedListing = recipeListingAtIndex(listingIndex)
        {
            eventHandler.selectedRecipeListing(selectedListing)
        }
        else {
            speakSelectionFailed(name, index: index)
            eventHandler.selectedRecipeListing(nil)
        }
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
    }
    
    func handlePreviousCommand()
    {
        listSubtopic?.speakPreviousItem()
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
    
    private func speakSelectionFailed(name: String?, index: Int?)
    {
        let utteranceString: String
        if let listingName = name {
            utteranceString = "I couldn't select an item called \"\(listingName)\". Please try again."
        }
        else if let listingIndex = index {
            utteranceString = "I couldn't select item number \"\(listingIndex)\". Please try again."
        }
        else {
            utteranceString = "I couldn't select an item by that name or number. Please try again."
        }
        
        postEvents(SAYAudioEventSequence(events: [SAYSpeechEvent(utteranceString: utteranceString)]))
    }
    
    func recipeListingWithName(name: String) -> RecipeListing?
    {
        let listingsNames = recipeListings.map({ $0.name })
        if let matchingIndex = Utils.fuzzyIndexOfItemWithName(name, inList: listingsNames) {
            return recipeListings[matchingIndex]
        }
        else {
            return nil
        }
    }
    
    func recipeListingAtIndex(index: Int) -> RecipeListing?
    {
        if index >= 0 && index < recipeListings.count {
            return recipeListings[index]
        }
        else {
            return nil
        }
    }
    
    private var listSubtopic: ListConversationTopic?
    private var recipeListings: [RecipeListing]!
    private var searchQuery: String!
}

protocol SearchResultsConversationTopicEventHandler: class
{
    func selectedRecipeListing(recipeListing: RecipeListing?)

    func handlePlayCommand()
    func handlePauseCommand()
    
    func beganSpeakingItemAtIndex(index: Int)
    func finishedSpeakingItemAtIndex(index: Int)
}
