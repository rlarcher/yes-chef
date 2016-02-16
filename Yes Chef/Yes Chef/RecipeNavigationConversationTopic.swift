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
        
        let switchTabRecognizer = SAYSwitchTabCommandRecognizer(responseTarget: eventHandler, action: "handleTabNavigationCommand:")
        switchTabRecognizer.addMenuItemWithLabel("Switch Tab...")        
        addCommandRecognizer(switchTabRecognizer)

        let saveRecipeRecognizer = SAYCustomCommandRecognizer(customType: "SaveRecipe", responseTarget: self, action: "handleSaveRecipeCommand")
        saveRecipeRecognizer.addTextMatcher(SAYBlockCommandMatcher(block: { text -> SAYCommandSuggestion? in
            if text.containsString("save") || text.containsString("keep") || text.containsString("favorite") || text.containsString("saved") {
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
    
    func handleSaveRecipeCommand()
    {
        print("RecipeNavigationCT handleSaveRecipeCommand")
        // TODO: Interact with the SavedRecipes manager.
    }
    
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
    func handleTabNavigationCommand(command: SAYCommand)
}
