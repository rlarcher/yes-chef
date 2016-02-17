//
//  RecipeNavigationConversationTopic.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class RecipeNavigationConversationTopic: SAYConversationTopic
{
    init(eventHandler: RecipeNavigationConversationTopicEventHandler)
    {
        self.eventHandler = eventHandler
        
        super.init()
        
        let switchTabRecognizer = SAYSwitchTabCommandRecognizer(responseTarget: self, action: "handleTabNavigationCommand:")
        switchTabRecognizer.addMenuItemWithLabel("Switch Tab...")        
        addCommandRecognizer(switchTabRecognizer)

        let saveRecipeRecognizer = SAYCustomCommandRecognizer(customType: "SaveRecipe", responseTarget: self, action: "handleSaveRecipeCommand")
        saveRecipeRecognizer.addTextMatcher(SAYBlockCommandMatcher(block: { text -> SAYCommandSuggestion? in
            if text.containsAny(["save", "keep", "favorite", "saved"]) {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceVeryLikely)
            }
            else {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceNone)
            }
        }))
    }
    
    // This must be called before attempting to speak.
    func updateRecipe(recipe: Recipe)
    {
        self.recipe = recipe
    }
    
    override func subtopic(subtopic: SAYConversationTopic, didPostEventSequence sequence: SAYAudioEventSequence)
    {
        // TODO: Should be unnecessary to override this functions just to pass the sequence through to `postEvents:`. Investigate.
        self.postEvents(sequence)
    }
    
    // MARK: Lifecycle
    
    func topicDidGainFocus()
    {

    }
    
    func topicDidLoseFocus()
    {
        // Note: This won't happen until the TabBarController is popped off the navigation stack.
        stopSpeaking()
        removeAllSubtopics()
    }
    
    // MARK: Handle Commands

    func handleTabNavigationCommand(command: SAYCommand)
    {
        if let tabName = command.parameters[SAYSwitchTabCommandRecognizerParameterTabName] as? String {
            for tab in RecipeTab.orderedCases() {
                if tab.rawValue.lowercaseString.containsString(tabName.lowercaseString) { // TODO: Improve string matching
                    eventHandler.requestedSwitchTab(tab)
                    return
                }
            }
        }
        else if let tabNumber = command.parameters[SAYSwitchTabCommandRecognizerParameterTabNumber] as? NSNumber {
            let index = max(tabNumber.integerValue - 1, 0)    // Assume the user spoke a 1-based tab number. Translate it here to a 0-based index.
            if index >= 0 && index < RecipeTab.orderedCases().count {
                let newTab = RecipeTab.orderedCases()[index]
                eventHandler.requestedSwitchTab(newTab)
                return
            }
        }
        
        // If we reach here, we couldn't understand a valid tab to switch to.
        // TODO: Present a clarifying request, "Which tab would you like to switch to?"
        print("RecipeNavigationCT handleTabNavigationCommand needs clarification.")
    }
    
    func handleSaveRecipeCommand()
    {
        print("RecipeNavigationCT handleSaveRecipeCommand")
        // TODO: Interact with the SavedRecipes manager.
    }
    
    // MARK: Speech
    
    private func stopSpeaking()
    {
        // TODO: Better way to interrupt speech on transitioning?
        postEvents(SAYAudioEventSequence(events: [SAYSilenceEvent(interval: 0.0)]))
    }
    
    private var recipe: Recipe!
    private let eventHandler: RecipeNavigationConversationTopicEventHandler
}

protocol RecipeNavigationConversationTopicEventHandler: class
{
    func requestedSwitchTab(newTab: RecipeTab)
}
