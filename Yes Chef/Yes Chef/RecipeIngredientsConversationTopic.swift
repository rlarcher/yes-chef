//
//  RecipeIngredientsConversationTopic.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class RecipeIngredientsConversationTopic: SAYConversationTopic, ListConversationTopicEventHandler
{
    let eventHandler: RecipeIngredientsConversationTopicEventHandler
    
    // MARK: Lifecycle
    
    init(eventHandler: RecipeIngredientsConversationTopicEventHandler)
    {
        self.eventHandler = eventHandler
        
        super.init()
        
        let servingsRecognizer = SAYCustomCommandRecognizer(customType: "Servings", responseTarget: eventHandler, action: "handleServingsCommand")
        servingsRecognizer.addTextMatcher(SAYBlockCommandMatcher(block: { text -> SAYCommandSuggestion? in
            // Recognize phrases like "How many servings?", "How many people can this feed?"
            if text.containsString("servings") || text.containsString("serving") || text.containsString("how many people does this feed") {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceVeryLikely)
            }
            else {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceNone)
            }
        }))
        self.addCommandRecognizer(servingsRecognizer)
        
        let ingredientQueryRecognizer = SAYCustomCommandRecognizer(customType: "IngredientQuery", responseTarget: eventHandler, action: "handleIngredientQueryCommand:")
        ingredientQueryRecognizer.addTextMatcher(SAYPatternCommandMatcher(forPatterns: [
            "how much @ingredient do I need",
            "how much @ingredient",
            "how many @ingredient do I need",
            "how many @ingredient",
            "do I need @ingredient",
            "do I need any @ingredient",
            "does this contain @ingredient",
            "does it contain @ingredient"
            ]))
        self.addCommandRecognizer(ingredientQueryRecognizer)
        
        let ingredientsRecognizer = SAYCustomCommandRecognizer(customType: "Ingredients", responseTarget: eventHandler, action: "handleIngredientsCommand")
        ingredientsRecognizer.addTextMatcher(SAYBlockCommandMatcher(block: { text -> SAYCommandSuggestion? in
            // Recognize phrases like "What are the ingredients?", "What do I need?"
            if text.containsString("ingredients") || text.containsString("what do I need") {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceVeryLikely)
            }
            else {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceNone)
            }
        }))
        self.addCommandRecognizer(ingredientsRecognizer)
        
        // TODO: Add command recognizer for "Can I substitute __ingredientX__ for __ingredientY__?"
        // TODO: Add command recognizer for unit conversion.
    }
    
    // This must be called before attempting to speak.    
    func updateRecipe(recipe: Recipe)
    {
        self.recipe = recipe
    }
    
    func topicDidGainFocus()
    {
        addSubtopic(ListConversationTopic(eventHandler: self))
    }
    
    func topicDidLoseFocus()
    {
        removeAllSubtopics()
    }
    
    override func subtopic(subtopic: SAYConversationTopic, didPostEventSequence sequence: SAYAudioEventSequence)
    {
        if subtopic is ListConversationTopic {
            let prefixEvent: SAYSpeechEvent
            if recipe.ingredients.count > 0 {
                prefixEvent = SAYSpeechEvent(utteranceString: "You need \(recipe.ingredients.count) ingredients for this recipe:")
            }
            else {
                prefixEvent = SAYSpeechEvent(utteranceString: "There are no ingredients for this recipe.") // ...delicious
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
    
    // MARK: Helpers
    
    func stopSpeaking()
    {
        // TODO: Better way to interrupt speech on transitioning?
        postEvents(SAYAudioEventSequence(events: [SAYSilenceEvent(interval: 0.0)]))
    }
    
    func speakIngredients()
    {
        if let listSubtopic = self.subtopics.first as? ListConversationTopic {
            listSubtopic.speakItems(recipe.ingredients.map { $0.speakableString })
        }
    }
    
    func speakServings()
    {
        let sequence = SAYAudioEventSequence()
        sequence.addEvent(SAYSpeechEvent(utteranceString: "This recipe feeds \(recipe.servingSize) people."))
        postEvents(sequence)
    }
    
    func speakIngredient(ingredient: String)
    {
        let sequence = SAYAudioEventSequence()
        
        let matchingIngredients = recipe.ingredients.filter({ $0.name.lowercaseString.containsString(ingredient.lowercaseString) })
        if let knownIngredient = matchingIngredients.first {
            sequence.addEvent(SAYSpeechEvent(utteranceString: "The recipe calls for \(knownIngredient.speakableString)."))
        }
        else {
            sequence.addEvent(SAYSpeechEvent(utteranceString: "The recipe doesn't call for any \(ingredient)."))
        }
        
        postEvents(sequence)
    }
    
    private var recipe: Recipe!
}

protocol RecipeIngredientsConversationTopicEventHandler: class
{
    func handleSelectCommand(command: SAYCommand)
    func handleSearchCommand(command: SAYCommand)
    func handlePlayCommand()
    func handlePauseCommand()
    func handleNextCommand()
    func handlePreviousCommand()
    
    func handleServingsCommand()
    func handleIngredientQueryCommand(command: SAYCommand)
    func handleIngredientsCommand()
}
