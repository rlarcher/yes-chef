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
    func updateListings(results: [RecipeListing], forSearchParameters parameters: SearchParameters)
    {
        updateResults(results)
        updateSearchParameters(parameters)
        syncListSubtopic()
    }
    
    func updateResults(results: [RecipeListing])
    {
        self.recipeListings = results
    }

    func updateSearchParameters(parameters: SearchParameters)
    {
        self.searchParameters = parameters
    }
    
    func speakResults()
    {
        syncListSubtopic()
        listSubtopic?.speakItems()
    }
    
    func speakErrorMessage(message: String)
    {
        postEvents(SAYAudioEventSequence(events: [SAYSpeechEvent(utteranceString: message)]))
    }
    
    func speakNoResultsForSearchParameters(parameters: SearchParameters)
    {
        let utterance: String
        if let presentableString = parameters.presentableString {
            let format = _prompt("search:no_recipes_for_parameters_X", comment: "Spoken when no recipes were found for a given set of search parameters")
            utterance = String(format: format, presentableString)
        }
        else {
            utterance = _prompt("search:no_recipes:found", comment: "Spoken when no recipes were found, for an unspecified set of search parameters")
        }
        
        postEvents(SAYAudioEventSequence(events: [SAYSpeechEvent(utteranceString: utterance)]))
    }
    
    // MARK: Lifecycle
    
    func topicDidGainFocus()
    {
        addSubtopic(listSubtopic!)
        CommandBarController.setPlaybackControlsDelegate(listSubtopic!)
        speakResults()
    }
    
    func topicDidLoseFocus()
    {
        stopSpeaking()
        if let subtopic = listSubtopic {
            removeSubtopic(subtopic)
            CommandBarController.setPlaybackControlsDelegate(nil)
        }
    }

    // MARK: Subtopic Handling
    
    override func subtopic(subtopic: SAYConversationTopic, didPostEventSequence sequence: SAYAudioEventSequence)
    {
        // TODO: Should be unnecessary to override this functions just to pass the sequence through to `postEvents:`. Investigate.
        self.postEvents(sequence)
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
    
    private func syncListSubtopic()
    {
        if listSubtopic == nil {
            listSubtopic = ListConversationTopic(items: recipeListings.map({ $0.speakableString }), eventHandler: self)
            addSubtopic(listSubtopic!)
        }
        else {
            listSubtopic?.items = recipeListings.map({ $0.speakableString })
        }
        
        CommandBarController.setPlaybackControlsDelegate(listSubtopic!)
        
        let introString: String
        let result = _prompt("search:results_alias", comment: "How we'll refer to a single search result in the next prompts")
        if let parameterString = searchParameters.presentableString {
            if recipeListings.count > 0 {
                let introFormat = _prompt("search:found_X_results_for_parameters_Y", comment: "Intro string for the list of search results found using the given search parameters")
                introString = String(format: introFormat, recipeListings.count.withSuffix(result), parameterString)
            }
            else {
                let introFormat = _prompt("search:no_recipes_for_parameters_X", comment: "Spoken when no recipes were found for a given set of search parameters")
                introString = String(format: introFormat, parameterString)
            }
        }
        else {
            if recipeListings.count > 0 {
                let introFormat = _prompt("search:found_X_results", comment: "Intro string for the list of search results, where the search parameters are uncertain")
                introString = String(format: introFormat, recipeListings.count.withSuffix(result))
            }
            else {
                introString = _prompt("search:no_recipes_found", comment: "Spoken when no recipes were found, for an unspecified set of search parameters")
            }
        }
        listSubtopic?.introString = introString
        listSubtopic?.intermediateHelpString = _prompt("search:intermediate_help", comment: "Spoken after the first few items in the list of results")
        listSubtopic?.outroString = _prompt("search:outro", comment: "Call to action after reading the list of search results")
    }
    
    private func speakSelectionFailed(name: String?, index: Int?)
    {
        let utteranceString: String
        if let listingName = name {
            let format = _prompt("list:unable_to_select_by_name_X", comment: "Spoken when we couldn't select an item by a given name")
            utteranceString = String(format: format, listingName)
        }
        else if let listingIndex = index {
            let format = _prompt("list:unable_to_select_by_number_X", comment: "Spoken when we couldn't select an item by its number in a list")
            utteranceString = String(format: format, listingIndex)
        }
        else {
            utteranceString = _prompt("list:unable_to_select", comment: "Spoken when we couldn't select an item, and name/number are unknown")
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
    private var searchParameters: SearchParameters!
}

protocol SearchResultsConversationTopicEventHandler: class
{
    func selectedRecipeListing(recipeListing: RecipeListing?)

    func handlePlayCommand()
    func handlePauseCommand()
    
    func beganSpeakingItemAtIndex(index: Int)
    func finishedSpeakingItemAtIndex(index: Int)
}
