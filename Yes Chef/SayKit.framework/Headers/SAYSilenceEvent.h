//
//  SAYSilenceEvent.h
//  SayKit
//
//  Created by Greg Nicholas on 7/20/15.
//  Copyright (c) 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAYAudioEvent.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  The `SAYSilenceEvent` is a special `SAYAudioEvent` that does not actually produce a sound. Instead, it holds a specific interval of silence.
 */
@interface SAYSilenceEvent : NSObject <SAYAudioEvent>

/**
 *  The interval of silence
 */
@property (nonatomic, assign, readonly) NSTimeInterval interval;

/**
 *  Factory initializer to creates a `SAYSilenceEvent` for the given amount of time
 *
 *  @param interval Time in seconds
 *
 *  @return The newly-initialized `SAYSilenceEvent`
 */
+ (SAYSilenceEvent *)eventWithInterval:(NSTimeInterval)interval;

/**
 *  Initializer that creates an event for keeping the track silent for the given amount of time
 *
 *  @param interval Time in seconds
 *
 *  @return The newly-initialized `SAYSilenceEvent`
 */
- (instancetype)initWithInterval:(NSTimeInterval)interval NS_DESIGNATED_INITIALIZER;

/// @abstract Use initWithInterval: to initialize.
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END