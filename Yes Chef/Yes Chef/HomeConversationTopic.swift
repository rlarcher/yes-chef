//
//  HomeConversationTopic.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class HomeConversationTopic: SAYConversationTopic
{
    let eventHandler: HomeConversationTopicEventHandler
    
    init(eventHandler: HomeConversationTopicEventHandler)
    {
        self.eventHandler = eventHandler
        
        super.init()
        
        let helpRecognizer = SAYHelpCommandRecognizer(responseTarget: eventHandler, action: "handleHelpCommand")
        helpRecognizer.addMenuItemWithLabel("Help")
        addCommandRecognizer(helpRecognizer)
        
        let availableCommandsRecognizer = SAYAvailableCommandsCommandRecognizer(responseTarget: eventHandler, action: "handleAvailableCommands")
        availableCommandsRecognizer.addMenuItemWithLabel("Available Commands")
        addCommandRecognizer(availableCommandsRecognizer)
        
        let searchRecognizer = SAYSearchCommandRecognizer(responseTarget: self, action: "handleSearchCommand:")
        searchRecognizer.addMenuItemWithLabel("Search...")
        searchRecognizer.addTextMatcher(SAYPatternCommandMatcher(forPatterns: [
            "I want to bake @\(SAYSearchCommandRecognizerParameterQuery)",
            "I want to cook @\(SAYSearchCommandRecognizerParameterQuery)",
            "I want to grill @\(SAYSearchCommandRecognizerParameterQuery)",
            "I want to make @\(SAYSearchCommandRecognizerParameterQuery)",
            "let's bake @\(SAYSearchCommandRecognizerParameterQuery)",
            "let's cook @\(SAYSearchCommandRecognizerParameterQuery)",
            "let's grill @\(SAYSearchCommandRecognizerParameterQuery)",
            "let's make @\(SAYSearchCommandRecognizerParameterQuery)"
            ]))
        addCommandRecognizer(searchRecognizer)
        
        let homeRecognizer = SAYHomeCommandRecognizer(responseTarget: eventHandler, action: "handleHomeCommand")
        homeRecognizer.addMenuItemWithLabel("Home")
        addCommandRecognizer(homeRecognizer)
        
        let backRecognizer = SAYBackCommandRecognizer(responseTarget: eventHandler, action: "handleBackCommand")
        backRecognizer.addMenuItemWithLabel("Back")
        addCommandRecognizer(backRecognizer)
        
        let howToDoActionRecognizer = SAYCustomCommandRecognizer(customType: "HowToDoAction", responseTarget: self, action: "handleHowToDoActionCommand:")
        howToDoActionRecognizer.addTextMatcher(SAYPatternCommandMatcher(patterns: [
            "how do I @action",
            "how can I @action",
            "how would I @action",
            "I don't know how to @action",
            "tell me how to @action",
            "tell me how @action"
            ]))
        howToDoActionRecognizer.addMenuItemWithLabel("How do I...")
        addCommandRecognizer(howToDoActionRecognizer)
        
        let featureQueryRecognizer = SAYCustomCommandRecognizer(customType: "FeatureQuery", responseTarget: self, action: "handleFeatureQueryCommand:")
        featureQueryRecognizer.addTextMatcher(SAYPatternCommandMatcher(patterns: [
            "what is @feature",
            "what's the deal with @feature",
            "what about @feature",
            "tell me about @feature"
            ]))
        featureQueryRecognizer.addMenuItemWithLabel("What is...")
        addCommandRecognizer(featureQueryRecognizer)
    }
    
    func topicDidGainFocus()
    {
        removeAllSubtopics() // TODO: Think of a better way to clean up popped subtopics. Override navigation methods? Independent navigation management?
        
        let categoriesRecognizer = SAYCustomCommandRecognizer(customType: "Categories") { _ in self.handleCategoriesCommand() }
        categoriesRecognizer.addTextMatcher(SAYBlockCommandMatcher(block: { text -> SAYCommandSuggestion? in
            if text.containsAny(["category", "categories"]) {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceVeryLikely)
            }
            else {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceNone)
            }
        }))
        addCommandRecognizer(categoriesRecognizer)
        focusedRecognizers.append(categoriesRecognizer)
        
        let cuisinesRecognizer = SAYCustomCommandRecognizer(customType: "Cuisines") { _ in self.handleCuisinesCommand() }
        cuisinesRecognizer.addTextMatcher(SAYBlockCommandMatcher(block: { text -> SAYCommandSuggestion? in
            if text.containsAny(["cuisine", "cuisines"]) {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceVeryLikely)
            }
            else {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceNone)
            }
        }))
        addCommandRecognizer(cuisinesRecognizer)
        focusedRecognizers.append(cuisinesRecognizer)
    }
    
    func topicDidLoseFocus()
    {
        for recognizer in focusedRecognizers {
            removeCommandRecognizer(recognizer)
        }
        focusedRecognizers.removeAll()
    }
    
    // MARK: Speech Methods
    
    func speakIntroduction(shouldIncludeWelcomeMessage: Bool)
    {
        let sequence = SAYAudioEventSequence()
        
        if shouldIncludeWelcomeMessage {
            sequence.addEvent(SAYSpeechEvent(utteranceString: "Welcome to \"Yes Chef\"!"))
        }
        
        sequence.addEvent(SAYSpeechEvent(utteranceString: "You can search for a recipe by saying \"Search\" followed by a keyword. For a list of available commands, say \"What can I say?\" Say \"Help\" for more details."))
        postEvents(sequence)
    }
    
    func speakHelpMessage()
    {
        let sequence = SAYAudioEventSequence()
        
        sequence.addEvent(SAYSpeechEvent(utteranceString: "You can say \"Categories\" or \"Cuisines\" to hear available filters for your search. Say \"Saved Recipes\" to explore your saved recipes list. Say \"Home\" at any time to return here."))
        postEvents(sequence)
    }

    func speakAvailableCommands()
    {
        // TODO: Fetch available commands (e.g., from CT hierarchy) and speak those.
        let sequence = SAYAudioEventSequence()
        sequence.addEvent(SAYSpeechEvent(utteranceString: "There are lots of available commands, but I misplaced the list."))
        postEvents(sequence)
    }
    
    func speakErrorMessage(message: String)
    {
        postEvents(SAYAudioEventSequence(events: [SAYSpeechEvent(utteranceString: message)]))
    }
    
    // MARK: Handle Commands
    
    func handleSearchCommand(command: SAYCommand)
    {
        if let searchQuery = command.parameters[SAYSearchCommandRecognizerParameterQuery] as? String {
            let category = Category.categoryFoundInText(searchQuery)
            let cuisine = Cuisine.cuisineFoundInText(searchQuery)
            self.eventHandler.requestedSearchUsingQuery(searchQuery, category: category, cuisine: cuisine)
        }
        else {
            self.eventHandler.requestedSearchUsingQuery(nil, category: nil, cuisine: nil)
        }
    }
    
    private func handleCategoriesCommand()
    {
        // TODO: Do this inside a ListCT? For better control of long lists
        let sequence = SAYAudioEventSequence()
        sequence.addEvent(SAYSpeechEvent(utteranceString: "You can search for recipes in the following categories:"))
        for category in Category.orderedValues {
            sequence.addEvent(SAYSpeechEvent(utteranceString: "\"\(category.rawValue)\""))
        }
        postEvents(sequence)
    }

    private func handleCuisinesCommand()
    {
        // TODO: Do this inside a ListCT? For better control of long lists
        let sequence = SAYAudioEventSequence()
        sequence.addEvent(SAYSpeechEvent(utteranceString: "You can search for recipes according to the following cuisines:"))
        for cuisine in Cuisine.orderedValues {
            sequence.addEvent(SAYSpeechEvent(utteranceString: "\"\(cuisine.rawValue)\""))
        }
        postEvents(sequence)
    }
    
    func handleHowToDoActionCommand(command: SAYCommand)
    {
        if let queriedAction = command.parameters["action"] as? String {
            // TODO: Define a proper response for various actions
            let sequence = SAYAudioEventSequence()
            sequence.addEvent(SAYSpeechEvent(utteranceString: "I don't know how to \"\(queriedAction)\", either."))
            postEvents(sequence)
        }
        else {
            // TODO: Present a clarification request, "What would you like to learn how to do?"
            print("HomeCT handleHowToDoActionCommand requires clarification.")
        }
    }
    
    func handleFeatureQueryCommand(command: SAYCommand)
    {
        if let queriedFeature = command.parameters["feature"] as? String {
            // TODO: Define a proper response for various features
            let sequence = SAYAudioEventSequence()
            sequence.addEvent(SAYSpeechEvent(utteranceString: "\"\(queriedFeature)\" is a nice feature, but I don't know much beyond that."))
            postEvents(sequence)
        }
        else {
            // TODO: Present a clarification request, "What would you like to learn about?"
            print("HomeCT handleFeatureQueryCommand requires clarification.")
        }
    }
    
    override func subtopic(subtopic: SAYConversationTopic, didPostEventSequence sequence: SAYAudioEventSequence)
    {
        let outgoingSequence = sequence
        
        let silenceEvent = SAYSilenceEvent(interval: 10.0)
        let helpMessageEvent = SAYSpeechEvent(utteranceString: "Say \"Search\" followed by the name of a recipe to perform a search. If you need help, say \"Help\".")
    
        outgoingSequence.appendSequence(SAYAudioEventSequence(events: [silenceEvent, helpMessageEvent]))
        
        self.postEvents(outgoingSequence)
    }
    
    private var focusedRecognizers = [SAYVerbalCommandRecognizer]() // Recognizers that we only want active while this CT is focused.
}

protocol HomeConversationTopicEventHandler: class
{
    func handleHelpCommand()
    func handleAvailableCommands()
    func requestedSearchUsingQuery(searchQuery: String?, category: Category?, cuisine: Cuisine?)
    func handleHomeCommand()
    func handleBackCommand()
}
