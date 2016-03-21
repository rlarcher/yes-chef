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
        self.listManager = HomeListTopicManager(eventHandler: eventHandler)
        
        super.init()
        
        let helpRecognizer = SAYHelpCommandRecognizer(responseTarget: eventHandler, action: "handleHelpCommand")
        helpRecognizer.addMenuItemWithLabel("Help")
        addCommandRecognizer(helpRecognizer)
        
        let availableCommandsRecognizer = SAYAvailableCommandsCommandRecognizer(responseTarget: eventHandler, action: "handleAvailableCommands")
        availableCommandsRecognizer.addMenuItemWithLabel("Available Commands")
        addCommandRecognizer(availableCommandsRecognizer)
        
        let searchRecognizer = YesChefSearchCuisineCourseCommandRecognizer(responseTarget: self, action: "handleSearchCommand:")
        searchRecognizer.addMenuItemWithLabel("Search...")
        addCommandRecognizer(searchRecognizer)
        self.searchRecognizer = searchRecognizer
        
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
        
        let recommendationsRecognizer = SAYCustomCommandRecognizer(customType: "Recommendations", responseTarget: self, action: "handleRecommendationsCommand")
        recommendationsRecognizer.addTextMatcher(SAYBlockCommandMatcher(block: { text -> SAYCommandSuggestion? in
            if text.containsAny(["recommendation", "recommendations", "recommend"]) {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceVeryLikely)
            }
            else {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceNone)
            }
        }))
        recommendationsRecognizer.addMenuItemWithLabel("Recommendations")
        addCommandRecognizer(recommendationsRecognizer)
    }
    
    func topicDidGainFocus()
    {
        removeAllSubtopics() // TODO: Think of a better way to clean up popped subtopics. Override navigation methods? Independent navigation management?
        
        if let listSubtopic = listManager.listSubtopic {
            addSubtopic(listSubtopic)
            CommandBarController.setPlaybackControlsDelegate(listSubtopic)
        }
        
        let categoriesRecognizer = SAYCustomCommandRecognizer(customType: "Categories") { _ in self.handleCategoriesCommand() }
        categoriesRecognizer.addTextMatcher(SAYBlockCommandMatcher(block: { text -> SAYCommandSuggestion? in
            if text.containsAny(["category", "categories", "course", "courses"]) {
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
        
        searchRecognizer?.addTextMatcher(HomeConversationTopic.fallthroughTextMatcher)
    }
    
    func topicDidLoseFocus()
    {
        if let listSubtopic = listManager.listSubtopic {
            removeSubtopic(listSubtopic)
        }
        
        for recognizer in focusedRecognizers {
            removeCommandRecognizer(recognizer)
        }
        focusedRecognizers.removeAll()
        
        searchRecognizer?.removeTextMatcher(HomeConversationTopic.fallthroughTextMatcher)
    }

    // This must be called before attempting to speak.
    func updateListings(listings: [RecipeListing])
    {
        listManager.updateListings(listings)
    }
    
    // MARK: Speech Methods
    
    func speakIntroduction(shouldIncludeWelcomeMessage: Bool)
    {
        let sequence = SAYAudioEventSequence()
        
        if shouldIncludeWelcomeMessage {
            sequence.addEvent(SAYSpeechEvent(utteranceString: "Welcome to \"Yes Chef\"!"))
        }
        
        sequence.addEvent(SAYSpeechEvent(utteranceString: "You can search for a recipe by saying \"Search\" followed by a keyword. For a list of available commands, say \"What can I say?\" Say \"Help\" for more details. Feeling adventurous? Ask about our \"recommended recipes\""))
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
        var availableCommands = [String]()
        if let recognizers = SAYConversationManager.systemManager().commandRegistry?.commandRecognizers {
            for recognizer in recognizers {
                for menuItem in recognizer.menuItems {
                    availableCommands.append(menuItem.label)
                }
            }
        }
        if availableCommands.count > 0 {
            // TODO: Use a listCT for speaking these?
            let sequence = SAYAudioEventSequence()
            sequence.addEvent(SAYSpeechEvent(utteranceString: "There are \(availableCommands.count) available commands:"))
            for commandName in availableCommands {
                sequence.addEvent(SAYSpeechEvent(utteranceString: commandName))
            }
            postEvents(sequence)
        }
    }
    
    func speakRecommendedRecipes()
    {
        listManager.speakRecommendations()
    }
    
    func speakErrorMessage(message: String)
    {
        postEvents(SAYAudioEventSequence(events: [SAYSpeechEvent(utteranceString: message)]))
    }
    
    func speakNoResultsForSearchParameters(parameters: SearchParameters)
    {
        let utterance: String
        if let presentableString = parameters.presentableString {
            utterance = "Sorry, I couldn't find any recipes for \"\(presentableString)\" Please try another search."
        }
        else {
            utterance = "Sorry, I couldn't find any recipes by that name. Please try another search."
        }
        
        postEvents(SAYAudioEventSequence(events: [SAYSpeechEvent(utteranceString: utterance)]))
    }
    
    // MARK: Handle Commands
    
    func handleSearchCommand(command: SAYCommand)
    {
        let searchQuery = command.parameters[YesChefSearchCuisineCourseCommandRecognizerParameterQuery] as? String ?? nil
        let cuisine = parseCuisineFromCommand(command)
        let course = parseCourseFromCommand(command)
        
        if searchQuery != nil || cuisine != nil || course != nil {
            // If at least one parameter is non-nil, we can perform a search.
            eventHandler.requestedSearchUsingParameters(SearchParameters(query: searchQuery, cuisine: cuisine, course: course))
        }
        else {
            // We didn't understand a search query. Present a clarifying request.
            let request = SAYStringRequest(promptText: "What would you like to search for?", action: { spokenText -> Void in
                if let text = spokenText where !text.isBlank {
                    let cuisine = Cuisine.cuisineFoundInText(text)
                    let course = Category.categoryFoundInText(text)
                    
                    self.eventHandler.requestedSearchUsingParameters(SearchParameters(query: text, cuisine: cuisine, course: course))
                }
                else {
                    self.eventHandler.requestedSearchUsingParameters(SearchParameters.emptyParameters())
                }
            })
            SAYConversationManager.systemManager().presentVoiceRequest(request)
        }
    }
    
    private func handleCategoriesCommand()
    {
        // TODO: Do this inside a ListCT? For better control of long lists
        let sequence = SAYAudioEventSequence()
        sequence.addEvent(SAYSpeechEvent(utteranceString: "You can search for recipes for the following courses:"))
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
    
    func handleRecommendationsCommand()
    {
        speakRecommendedRecipes()
    }
    
    override func subtopic(subtopic: SAYConversationTopic, didPostEventSequence sequence: SAYAudioEventSequence)
    {
        let outgoingSequence = sequence
        
        let silenceEvent = SAYSilenceEvent(interval: 7.0)
        let helpMessageEvent = SAYSpeechEvent(utteranceString: "Let me know if you need help.")
    
        outgoingSequence.appendSequence(SAYAudioEventSequence(events: [silenceEvent, helpMessageEvent]))
        
        self.postEvents(outgoingSequence)
    }
    
    // MARK: Helpers
    
    private func parseCuisineFromCommand(command: SAYCommand) -> Cuisine?
    {
        let cuisine: Cuisine?
        if
            let rawCuisine = command.parameters[YesChefSearchCuisineCourseCommandRecognizerParameterCuisine] as? String,
            let parsedCuisine = Cuisine.cuisineFoundInText(rawCuisine)
        {
            cuisine = parsedCuisine
        }
        else if let searchQuery = command.parameters[YesChefSearchCuisineCourseCommandRecognizerParameterQuery] as? String {
            // Try to find a Cuisine in the entire search query, in case intent recognition didn't find the Cuisine parameter.
            cuisine = Cuisine.cuisineFoundInText(searchQuery)
        }
        else {
            // Couldn't find any Cuisine for the given command.
            cuisine = nil
        }
        
        return cuisine
    }
    
    private func parseCourseFromCommand(command: SAYCommand) -> Category?
    {
        let course: Category?
        if
            let rawCourse = command.parameters[YesChefSearchCuisineCourseCommandRecognizerParameterCourse] as? String,
            let parsedCourse = Category.categoryFoundInText(rawCourse)
        {
            course = parsedCourse
        }
        else if let searchQuery = command.parameters[YesChefSearchCuisineCourseCommandRecognizerParameterQuery] as? String {
            // Try to find a Course in the entire search query, in case intent recognition didn't find the Course parameter.
            course = Category.categoryFoundInText(searchQuery)
        }
        else {
            // Couldn't find any Course for the given command.
            course = nil
        }
        
        return course
    }
    
    private static var fallthroughTextMatcher: SAYBlockCommandMatcher = {
        // This is a "fallthrough" text matcher for extending the standard search recognizer. It will attempt to use the entire spoken text as a parameter for performing a search. It has a very low confidence, since it shouldn't take precedence over well-recognized commands.
        return SAYBlockCommandMatcher(block: { text -> SAYCommandSuggestion? in
            if !text.isBlank {
                let parameters = [SAYSearchCommandRecognizerParameterQuery: text]
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceVeryUnlikely, parameters: parameters)
            }
            else {
                return SAYCommandSuggestion(confidence: kSAYCommandConfidenceNone)
            }
        })
    }()
    
    private let listManager: HomeListTopicManager
    private var searchRecognizer: YesChefSearchCuisineCourseCommandRecognizer?
    private var focusedRecognizers = [SAYVerbalCommandRecognizer]() // Recognizers that we only want active while this CT is focused.
}

protocol HomeConversationTopicEventHandler: class
{
    func handleHelpCommand()
    func handleAvailableCommands()
    func requestedSearchUsingParameters(searchParameters: SearchParameters)
    func handleHomeCommand()
    func handleBackCommand()
    
    func selectedRecommendedRecipeListing(selectedRecommendation: RecipeListing?)
    func itemSelectionFailedWithMessage(selectionFailureMessage: String)
    
    func handlePlayCommand()
    func handlePauseCommand()
    
    func beganSpeakingItemAtIndex(index: Int)
    func finishedSpeakingItemAtIndex(index: Int)
}
