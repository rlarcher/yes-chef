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
            if text.containsAny(["servings", "serving", "how many people does this feed"]) {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceVeryLikely)
            }
            else {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceNone)
            }
        }))
        servingsRecognizer.addMenuItemWithLabel("Serving Size")
        addCommandRecognizer(servingsRecognizer)
        
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
        ingredientQueryRecognizer.addMenuItemWithLabel("Ingredient Query...")
        addCommandRecognizer(ingredientQueryRecognizer)
        
        let ingredientsRecognizer = SAYCustomCommandRecognizer(customType: "Ingredients", responseTarget: eventHandler, action: "handleIngredientsCommand")
        ingredientsRecognizer.addTextMatcher(SAYBlockCommandMatcher(block: { text -> SAYCommandSuggestion? in
            // Recognize phrases like "What are the ingredients?", "What do I need?"
            if text.containsAny(["ingredients", "what do I need"]) {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceVeryLikely)
            }
            else {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceNone)
            }
        }))
        ingredientsRecognizer.addMenuItemWithLabel("All Ingredients")
        addCommandRecognizer(ingredientsRecognizer)
        
        // TODO: Add command recognizer for "Can I substitute __ingredientX__ for __ingredientY__?"
        // TODO: Add command recognizer for unit conversion.
    }
    
    // This must be called before attempting to speak.    
    func updateRecipe(recipe: Recipe)
    {
        self.recipe = recipe
        listSubtopic?.items = recipe.ingredients.map({ $0.speakableString })
    }
    
    func topicDidGainFocus()
    {
        listSubtopic = buildIngredientsListSubtopic()
        addSubtopic(listSubtopic!)
    }
    
    func topicDidLoseFocus()
    {
        stopSpeaking()        
        removeAllSubtopics()
    }
    
    override func subtopic(subtopic: SAYConversationTopic, didPostEventSequence sequence: SAYAudioEventSequence)
    {
        // TODO: Should be unnecessary to override this functions just to pass the sequence through to `postEvents:`. Investigate.
        self.postEvents(sequence)
    }
    
    // MARK: ListConversationTopicEventHandler Protocol Methods
    // TODO: Using these as pass-through only. Better way?
    
    func selectedItemWithName(name: String?, index: Int?)
    {
        eventHandler.selectedItemWithName(name, index: index)
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
    
    // MARK: Speech
    
    func speakIngredients()
    {
        listSubtopic?.speakItems()
    }
    
    func speakServings()
    {
        let sequence = SAYAudioEventSequence()
        sequence.addEvent(SAYSpeechEvent(utteranceString: "This recipe serves \(recipe.presentableServingsText)."))
        postEvents(sequence)
    }
    
    func speakIngredient(ingredientName: String)
    {
        let utteranceString: String
        
        let ingredientNames = recipe.ingredients.map({ $0.name })
        if let matchingIndex = Utils.fuzzyIndexOfItemWithName(ingredientName, inList: ingredientNames) {
            let ingredient = recipe.ingredients[matchingIndex]
            utteranceString = "The recipe calls for \(ingredient.speakableString)."
        }
        else {
            utteranceString = "The recipe doesn't call for any \(ingredientName)."
        }
        
        postEvents(SAYAudioEventSequence(events: [SAYSpeechEvent(utteranceString: utteranceString)]))
    }
    
    // MARK: Helpers
    
    func stopSpeaking()
    {
        // TODO: Better way to interrupt speech on transitioning?
        postEvents(SAYAudioEventSequence(events: [SAYSilenceEvent(interval: 0.0)]))
    }

    private func buildIngredientsListSubtopic() -> ListConversationTopic
    {
        let listTopic = ListConversationTopic(items: recipe.ingredients.map({ $0.speakableString }), eventHandler: self)
        let count = recipe.ingredients.count
        listTopic.introString = count > 0 ?
                                    "You need \(count.withSuffix("ingredient")):" :
                                    "There are no ingredients for this recipe."
        listTopic.intermediateHelpString = "You can say \"Pause\" at any time if you need a minute."
        listTopic.outroString = "To add an ingredient to your grocery list, say \"Save\" followed by the ingredient's name or number (coming soon)."
        
        return listTopic
    }
    
    private var listSubtopic: ListConversationTopic?
    private var recipe: Recipe!
}

protocol RecipeIngredientsConversationTopicEventHandler: class
{
    func selectedItemWithName(name: String?, index: Int?)

    func handlePlayCommand()
    func handlePauseCommand()
    
    func beganSpeakingItemAtIndex(index: Int)
    func finishedSpeakingItemAtIndex(index: Int)
    
    func handleServingsCommand()
    func handleIngredientQueryCommand(command: SAYCommand)
    func handleIngredientsCommand()
}
