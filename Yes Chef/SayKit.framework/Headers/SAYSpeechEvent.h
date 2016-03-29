//
//  SAYSpeechEvent.h
//  SayKit
//
//  Created by Greg Nicholas on 7/1/15.
//  Copyright (c) 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAYAudioEvent.h"
#import "SAYManagedSynthesizer.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  A `SAYSpeechEvent` represents an verbal utterance to be spoken to the user via speech synthesis.
 */
@interface SAYSpeechEvent : NSObject <SAYAudioEvent>

@property (nonatomic, copy, readonly) AVSpeechUtterance *utterance;

/**
 *  Initializer that creates an event for speaking the given utterance.
 *
 *  @param utterance Speech utterance to be synthesized when this event fires
 *
 *  @return The newly-initialized `SAYSpeechEvent`
 */
- (instancetype)initWithUtterance:(AVSpeechUtterance *)utterance NS_DESIGNATED_INITIALIZER;

/**
 *  Convenience initializer that creates an event using an utterance with default settings and the given text string.
 *
 *  @param string Speech text to be synthesized when this event fires
 *
 *  @return The newly-initialized `SAYSpeechEvent`
 */
- (instancetype)initWithUtteranceString:(NSString *)string;

/// @abstract Use initWithUtterance: to initialize.
- (instancetype)init NS_UNAVAILABLE;

/**
 *  Factory initializer to create a `SAYSpeechEvent` with the given utterance.
 *
 *  @param utterance Speech utterance to be synthesized when this event fires
 *
 *  @return The newly-initialized `SAYSpeechEvent`
 */
+ (SAYSpeechEvent *)eventWithUtterance:(AVSpeechUtterance *)utterance;

/**
 *  Factory initializer to create a `SAYSpeechEvent` using an utterance with default settings and the given text string.
 *
 *  @param string Speech text to be synthesized when this event fires
 *
 *  @return The newly-initialized `SAYSpeechEvent`
 */
+ (SAYSpeechEvent *)eventWithUtteranceString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
