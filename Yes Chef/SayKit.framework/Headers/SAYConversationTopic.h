//
//  SAYConversationTopic.h
//  SayKit
//
//  Created by Greg Nicholas on 1/12/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SAYVerbalCommandRegistry.h"
#import "SAYAudioEventSource.h"

@class SAYVerbalCommandRecognizer;
@class SAYAudioTrack;

NS_ASSUME_NONNULL_BEGIN

/**
 *  The `SAYConversationTopic` is the organizational building block for SayKit audio interfaces. It acts much like a `UIView`, abstracting and composing input and output UI details into a logical container.
 
    In most cases, this class is to be subclassed, adding configuration and methods tailored to context-specific interface concerns.
 
    A conversation topic has three primary responsibilities:
 
    1. Defining audio output
    2. Handling voice input
    3. Managing the interface hierarchy: composing subtopics capable of handling lower-level UI concerns

    ## Defining Audio Output
 
    Topics conform to the `SAYAudioEventSource` protocol, so they can post audio sequences specific to and localized for their interface concerns.
 
    ## Handling Voice Input
 
    Topics also conform to the `SAYVerbalCommandRegistry` protocol, so they are able to collect and provide a set of command recognizers relevant only to their concerns.
 
    ## Managing Interface Hierarchy
 
    Topics have subtopics, allowing them to delegate lower-level UI concerns to collaborators downstream.  When asked for available command recognizers, they will respond both with both their own and their subtopics' recognizers. In addition, they listen to their subtopics' audio events, arranging and passing them on as a single sequence as if the events originated from themselves. They can also insert their own audio events into the sequence if desired.

    This capability lets us take advantage of the power of composition to build complex conversational interfaces from simple building blocks.
 */
@interface SAYConversationTopic : NSObject <SAYVerbalCommandRegistry, SAYAudioEventSource>

@property (nonatomic, readonly) NSArray <SAYVerbalCommandRecognizer *> *commandRecognizers;

/**
 @name Available Voice Commands
 **/

/**
 *  Add a command recognizer to the registry represented by the receiver.
 *
 *  @param commandRecognizer Command recognizer to associate with the topic.
 */
- (void)addCommandRecognizer:(SAYVerbalCommandRecognizer *)commandRecognizer;

/**
 *  Remove a command recognizer from the registry represented by the receiver.
 *
 *  @param commandRecognizer Command recognizer to disassociate from the topic.
 */
- (void)removeCommandRecognizer:(SAYVerbalCommandRecognizer *)commandRecognizer;

/**
 @name Audio Production
 **/

/**
 *  Posts the given event sequence to all listeners. This is accomplished via methods defined by the `SAYAudioEventSource` protocol, which the receiver conforms to.
 
    Note that although this is a public method, it is typically better to expose this functionality in subclasses via higher-level methods, relying on the subclass to call this method on the base implementation. 
 
    For example, for collaborators:
 
        [topic speakHelpMessage];
 
    would typically be preferable to:
 
        SAYSpeechEvent *helpEvent = [SAYSpeechEvent eventWithUtteranceString:@"... help message ..."];
        SAYAudioEventSequence *sequence = [SAYAudioEventSequence sequenceWithEvents:@[event]];
        [topic postEvents:sequence];
 *
 *  @param eventSequence Event sequence to be posted
 */
- (void)postEvents:(SAYAudioEventSequence *)eventSequence;

/**
 @name Interface Hierarchy
 **/

/**
 *  Array of subtopics directly underneath the receiver.
 */
@property (nonatomic, readonly) NSArray <SAYConversationTopic *> *subtopics;

/**
 *  Add a topic to the end of the receiver's `subtopics` array.
 *
 *  @param topic The `SAYConversationTopic` instance to add to the hierarchy
 */
- (void)addSubtopic:(SAYConversationTopic *)topic;

/**
 *  Remove a topic from the receiver's `subtopics`.
 *
 *  @param topic The `SAYConversationTopic` instance to remove to the hierarchy
 */
- (void)removeSubtopic:(SAYConversationTopic *)topic;

/**
 *  Empty all `subtopics` from the receiver.
 */
- (void)removeAllSubtopics;

// called when a subtopic posts a new audio event. not intended to be used by collaborators, but instead as a subclassing overriding point for topics that want to customize the sequencing of their subtopics' audio out
/**
 *  Notifies the receiver that one of its subtopics has posted audio events.
 * 
 *  This method acts as an override point to allow topics to re-arrange or modify a sequence before the sequence is passed onto its listeners. If not overridden, its default behavior is to simply concatenate all incoming sequences together and send them on as one ongoing sequence.
 
    If adding custom behavior, you are expected to post the outgoing events manually (typically by calling `postEvents:`). Otherwise, the events will not be passed up to the next listener.
 *
 *  @param subtopic Subtopic which has posted the audio events
 *  @param sequence Sequence of audio events
 */
- (void)subtopic:(SAYConversationTopic *)subtopic
   didPostEventSequence:(SAYAudioEventSequence *)sequence;

@end

NS_ASSUME_NONNULL_END
