//
//  SavedRecipesConversationTopic.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class SavedRecipesConversationTopic: SAYConversationTopic
{
    let eventHandler: SavedRecipesConversationTopicEventHandler
    
    init(eventHandler: SavedRecipesConversationTopicEventHandler)
    {
        self.eventHandler = eventHandler
        
        super.init()
        
        // TODO: Add command recognizer for "Remove __recipe__".
    }
    
    func speakSavedRecipes(recipes: [Recipe])
    {
        if let listSubtopic = self.subtopics.first as? ListConversationTopic {
            // TODO: Parse out each Recipe into a single speakable string.
            listSubtopic.speakItems(recipes.map { "\($0.name). \($0.rating) stars. Requires \(String($0.preparationTime)) minutes of preparation and \($0.ingredients.count) different ingredients." }) // TODO: Format prepTime.
        }
    }
    
    override func subtopic(subtopic: SAYConversationTopic, didPostEventSequence sequence: SAYAudioEventSequence)
    {
        if let listSubtopic = subtopic as? ListConversationTopic {
            let prefixEvent: SAYSpeechEvent
            if let itemCount = listSubtopic.itemCount {
                prefixEvent = SAYSpeechEvent(utteranceString: "You have \(itemCount) saved items:") // TODO: Better way to get the itemCount here?
            }
            else {
                prefixEvent = SAYSpeechEvent(utteranceString: "Here are your saved items:")
            }
            
            let outgoingSequence = SAYAudioEventSequence(events: [prefixEvent])
            outgoingSequence.appendSequence(sequence)
            
            self.postEvents(outgoingSequence)
        }
        else {
            self.postEvents(sequence)
        }
    }
}

protocol SavedRecipesConversationTopicEventHandler: class
{
    func handleRemoveRecipeCommand(command: SAYCommand)
}
