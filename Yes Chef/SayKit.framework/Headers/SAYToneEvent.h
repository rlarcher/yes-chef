//
//  SAYToneEvent.h
//  SayKit
//
//  Created by Greg Nicholas on 7/20/15.
//  Copyright (c) 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAYAudioEvent.h"

@class AVAudioPlayer;

NS_ASSUME_NONNULL_BEGIN

/**
 *  A `SAYToneEvent` represents an sound backed by an audio file.
 */
@interface SAYToneEvent : NSObject <SAYAudioEvent>

/**
 *  The URL of the sound file
 */
@property (nonatomic, copy, readonly) NSURL *audioURL;

/**
 *  Factory initializer to create a `SAYToneEvent` for the given URL.
 *
 *  @param url URL for audio file to be played with this event fires
 *
 *  @return The newly-initialized `SAYSpeechEvent`
 */
+ (SAYToneEvent *)eventWithAudioURL:(NSURL *)url;

/**
 *  Initializer that creates an event for playing the sound in the file referenced by the given URL.
 *
 *  @param url URL for audio file to be played with this event fires
 *
 *  @return The newly-initialized `SAYSpeechEvent`
 */
- (instancetype)initWithAudioURL:(NSURL *)url NS_DESIGNATED_INITIALIZER;

/// @abstract Use initWithAudioURL: to initialize.
- (instancetype)init NS_UNAVAILABLE;

/**
 *  Creates an array consisting of one or zero SAYToneOperations. Will return an empty array if there is an error processing the URL.
 *
 *  @return Array of one or zero SAYToneOperations.
 */
- (NSArray *)operations;

@end

NS_ASSUME_NONNULL_END