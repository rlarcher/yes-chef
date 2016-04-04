//
//  HomeConversationTopic.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/02.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class HomeConversationTopic: SAYConversationTopic, PlaybackControlsDelegate
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
        
        // TODO: Reenable when we restore full command handling
//        let searchRecognizer = YesChefSearchCuisineCourseCommandRecognizer(responseTarget: self, action: "handleSearchCommand:")
        let searchRecognizer = SAYCustomCommandRecognizer(customType: "basicSearch", responseTarget: self, action: #selector(handleSearchCommand))
        searchRecognizer.addTextMatcher(SAYPatternCommandMatcher(forPattern: "search for @basicSearchQuery"))
        searchRecognizer.addMenuItemWithLabel("Search...")
        addCommandRecognizer(searchRecognizer)
        self.searchRecognizer = searchRecognizer
        
        let homeRecognizer = SAYHomeCommandRecognizer(responseTarget: eventHandler, action: "handleHomeCommand")
        homeRecognizer.addMenuItemWithLabel("Home")
        addCommandRecognizer(homeRecognizer)
        
        let backRecognizer = SAYBackCommandRecognizer(responseTarget: eventHandler, action: "handleBackCommand")
        backRecognizer.addMenuItemWithLabel("Back")
        addCommandRecognizer(backRecognizer)
        
        // TODO: Reenable when we restore full command handling
//        let howToDoActionRecognizer = SAYCustomCommandRecognizer(customType: "HowToDoAction", responseTarget: self, action: "handleHowToDoActionCommand:")
//        howToDoActionRecognizer.addTextMatcher(SAYPatternCommandMatcher(patterns: [
//            "how do I @action",
//            "how can I @action",
//            "how would I @action",
//            "I don't know how to @action",
//            "tell me how to @action",
//            "tell me how @action"
//            ]))
//        howToDoActionRecognizer.addMenuItemWithLabel("How do I...")
//        addCommandRecognizer(howToDoActionRecognizer)
        
        // TODO: Reenable when we restore full command handling
//        let featureQueryRecognizer = SAYCustomCommandRecognizer(customType: "FeatureQuery", responseTarget: self, action: "handleFeatureQueryCommand:")
//        featureQueryRecognizer.addTextMatcher(SAYPatternCommandMatcher(patterns: [
//            "what is @feature",
//            "what's the deal with @feature",
//            "what about @feature",
//            "tell me about @feature"
//            ]))
//        featureQueryRecognizer.addMenuItemWithLabel("What is...")
//        addCommandRecognizer(featureQueryRecognizer)
        
        let recommendationsRecognizer = SAYCustomCommandRecognizer(customType: "Recommendations", responseTarget: self, action: #selector(handleRecommendationsCommand))
        recommendationsRecognizer.addTextMatcher(SAYBlockCommandMatcher(block: { text -> SAYCommandSuggestion? in
            if text.containsAny(["what do you recommend", "recommendation", "recommendations", "recommend"]) {
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
        }
        
        CommandBarController.setPlaybackControlsDelegate(self)
        CommandBarController.updatePlaybackState(shouldDisplayPlayIcon: false, previousEnabled: false, forwardEnabled: false)
        
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
            CommandBarController.setPlaybackControlsDelegate(nil)
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
        isSpeaking = true
        
        let sequence = SAYAudioEventSequence()
        
        if shouldIncludeWelcomeMessage {
            sequence.addEvent(SAYSpeechEvent(utteranceString: _prompt("home:welcome_message", comment: "Welcome message on reaching the home screen for the first time")))
        }
        
        sequence.addEvent(SAYSpeechEvent(utteranceString: _prompt("home:instructions", comment: "Call to action on reaching the home screen for the first time"))) {
            self.isSpeaking = false
        }
        postEvents(sequence)
    }
    
    func speakHelpMessage()
    {
        let sequence = SAYAudioEventSequence()
        
        sequence.addEvent(SAYSpeechEvent(utteranceString: _prompt("home:help", comment: "Help message on the home screen")))
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
            let format = _prompt("home:X_available_commands", comment: "Message spoken just before listing out all available commands")
            let sequence = SAYAudioEventSequence()
            sequence.addEvent(SAYSpeechEvent(utteranceString: String(format: format, availableCommands.count)))
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
            let format = _prompt("search:no_recipes_for_parameters_X", comment: "Spoken when no recipes were found for a given set of search parameters")
            utterance = String(format: format, presentableString)
        }
        else {
            utterance = _prompt("search:no_recipes:found", comment: "Spoken when no recipes were found, for an unspecified set of search parameters")
        }
        
        postEvents(SAYAudioEventSequence(events: [SAYSpeechEvent(utteranceString: utterance)]))
    }
    
    // MARK: PlaybackControlsDelegate Protocol Methods
    
    func commandBarRequestedPreviousPlaybackControl()
    {
        // Do nothing (button disabled)
    }
    
    func commandBarRequestedForwardPlaybackControl()
    {
        // Do nothing (button disabled)
    }
    
    func commandBarRequestedPlayPausePlaybackControl()
    {
        if isSpeaking {
            postEvents(SAYAudioEventSequence(events: [SAYSilenceEvent(interval: 0.0)]))
            isSpeaking = false
        }
        else {
            speakIntroduction(false)
        }
    }
    
    // MARK: Handle Commands
    
    func handleSearchCommand(command: SAYCommand)
    {
        // TODO: Restore this when we reenable full command recognition
//        let searchQuery = command.parameters[YesChefSearchCuisineCourseCommandRecognizerParameterQuery] as? String ?? nil
        let searchQuery = command.parameters["basicSearchQuery"] as? String ?? nil
        let cuisine = parseCuisineFromCommand(command)
        let course = parseCourseFromCommand(command)
        
        if searchQuery != nil || cuisine != nil || course != nil {
            // If at least one parameter is non-nil, we can perform a search.
            eventHandler.requestedSearchUsingParameters(SearchParameters(query: searchQuery, cuisine: cuisine, course: course))
        }
        else {
            // We didn't understand a search query. Present a clarifying request.
            let request = SAYStringRequest(promptText: _prompt("search:clarifying_prompt", comment: "Spoken in a followup request, after we couldn't understand what the user wanted to search for"), action: { spokenText -> Void in
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
        sequence.addEvent(SAYSpeechEvent(utteranceString: _prompt("search:available_courses", comment: "Response to what courses are available")))
        for category in Category.orderedValues {
            sequence.addEvent(SAYSpeechEvent(utteranceString: "\"\(category.rawValue)\""))
        }
        postEvents(sequence)
    }

    private func handleCuisinesCommand()
    {
        // TODO: Do this inside a ListCT? For better control of long lists
        let sequence = SAYAudioEventSequence()
        sequence.addEvent(SAYSpeechEvent(utteranceString: _prompt("search:available_cuisines", comment: "Response to what cuisines are available")))
        for cuisine in Cuisine.orderedValues {
            sequence.addEvent(SAYSpeechEvent(utteranceString: "\"\(cuisine.rawValue)\""))
        }
        postEvents(sequence)
    }
    
    func handleHowToDoActionCommand(command: SAYCommand)
    {
        if let queriedAction = command.parameters["action"] as? String {
            // TODO: Define a proper response for various actions
            let format = _prompt("home:how_to_X_unknown", comment: "Response for an unhandled \"How do I X?\"")
            let sequence = SAYAudioEventSequence()
            sequence.addEvent(SAYSpeechEvent(utteranceString: String(format: format, queriedAction)))
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
            let format = _prompt("home:feature_query_X_unknown", comment: "Response for an unhandled \"Tell me about X\"")
            let sequence = SAYAudioEventSequence()
            sequence.addEvent(SAYSpeechEvent(utteranceString: String(format: format, queriedFeature)))
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
        let helpMessageEvent = SAYSpeechEvent(utteranceString: _prompt("home:periodic_help", comment: "Help message after a period of inactivity"))
    
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
    
    private func updatePlaybackButtons()
    {
        CommandBarController.updatePlaybackState(shouldDisplayPlayIcon: !isSpeaking, previousEnabled: false, forwardEnabled: false)
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
    
    private var isSpeaking: Bool = true {
        didSet {
            updatePlaybackButtons()
        }
    }
    
    private let listManager: HomeListTopicManager
    private var searchRecognizer: SAYVerbalCommandRecognizer?
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
    
    func requestedAddListSubtopic(subtopic: SAYConversationTopic)
}
