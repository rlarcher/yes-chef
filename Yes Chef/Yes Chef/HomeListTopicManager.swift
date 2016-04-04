//
//  HomeListTopicManager.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/14/3.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class HomeListTopicManager: NSObject, ListConversationTopicEventHandler
{
    var listSubtopic: ListConversationTopic?
    
    init(eventHandler: HomeConversationTopicEventHandler)
    {
        self.eventHandler = eventHandler
        
        super.init()
    }
    
    // This must be called before attempting to speak.
    func updateListings(listings: [RecipeListing])
    {
        self.recommendedListings = listings
        syncListSubtopic()
    }
    
    func speakRecommendations()
    {
        syncListSubtopic()
        CommandBarController.setPlaybackControlsDelegate(listSubtopic!)
        listSubtopic?.speakItems()
    }
    
    // MARK: ListConversationTopicEventHandler Protocol Methods
    // TODO: Using these as pass-through only. Better way?
    
    func selectedItemWithName(name: String?, index: Int?)
    {
        if
            let listingName = name,
            let selectedListing = recipeListingWithName(listingName)
        {
            eventHandler.selectedRecommendedRecipeListing(selectedListing)
        }
        else if
            let listingIndex = index,
            let selectedListing = recipeListingAtIndex(listingIndex)
        {
            eventHandler.selectedRecommendedRecipeListing(selectedListing)
        }
        else {
            speakSelectionFailed(name, index: index)
            eventHandler.selectedRecommendedRecipeListing(nil)
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
    
    private func syncListSubtopic()
    {
        if listSubtopic == nil {
            listSubtopic = ListConversationTopic(items: recommendedListings.map({ $0.speakableString }), listIsMutable: false, shouldUseFallthroughForSelection: false, eventHandler: self)
            eventHandler.requestedAddListSubtopic(listSubtopic!)
        }
        else {
            listSubtopic?.items = recommendedListings.map({ $0.speakableString })
        }
        
        let recommendation = _prompt("recommendations:alias", comment: "How we'll refer to a single recommendation in the next prompt, recommendations:X_available")
        let introFormat = _prompt("recommendations:X_available", comment: "Intro string for the list of recommendations")
        listSubtopic?.introString = recommendedListings.count > 0 ?
            String(format: introFormat, recommendedListings.count.withSuffix(recommendation)) :
            _prompt("recommendations:none_available", comment: "Intro string for the (empty) list of recommendations")
        listSubtopic?.intermediateHelpString = _prompt("recommendations:intermediate_help", comment: "Spoken after the first few items in the list of recommendations")
        listSubtopic?.outroString = _prompt("recommendations:outro", comment: "Call to action after reading the list of recommendations")
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
        
        eventHandler.itemSelectionFailedWithMessage(utteranceString)
    }
    
    func recipeListingWithName(name: String) -> RecipeListing?
    {
        let listingsNames = recommendedListings.map({ $0.name })
        if let matchingIndex = Utils.fuzzyIndexOfItemWithName(name, inList: listingsNames) {
            return recommendedListings[matchingIndex]
        }
        else {
            return nil
        }
    }
    
    func recipeListingAtIndex(index: Int) -> RecipeListing?
    {
        if index >= 0 && index < recommendedListings.count {
            return recommendedListings[index]
        }
        else {
            return nil
        }
    }
    
    private var recommendedListings = [RecipeListing]()
    private let eventHandler: HomeConversationTopicEventHandler
}
