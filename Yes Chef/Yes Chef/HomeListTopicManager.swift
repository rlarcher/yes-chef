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
        
        listSubtopic?.introString = recommendedListings.count > 0 ?
            "I have \(recommendedListings.count.withSuffix("recommendations")) for you." :
        "Sorry, I don't have any recommendations right now."
        listSubtopic?.intermediateHelpString = "To inspect a recipe, say \"Select\" followed by the recipe's name or number."
        listSubtopic?.outroString = "Say \"More\" for more recommendations (coming soon)."
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
