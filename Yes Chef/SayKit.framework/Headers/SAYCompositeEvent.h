//
//  SAYCompositeEvent.h
//  SayKit
//
//  Created by Greg Nicholas on 7/20/15.
//  Copyright (c) 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAYAudioEvent.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  A `SAYCompositeEvent` is a `SAYAudioEvent` that contains multiple "component events" that are to be considered a single event to outside observers. The operations generated from this event will be a concatenated array of all component events' operations.
 */
@interface SAYCompositeEvent : NSObject <SAYAudioEvent>

@property (nonatomic, copy, readonly) NSArray <id<SAYAudioEvent>> *componentEvents;

/**
 *  Factory initializer for an event composed of the given sub-events
 *
 *  @param events Array of `SAYAudioEvent`-conforming instances
 *
 *  @return The newly-initialized `SAYCompositeEvent`
 */
+ (SAYCompositeEvent *)eventWithComponentEvents:(NSArray *)events;

/**
 *  Initializes an event composed of the given sub-events
 *
 *  @param events Array of `SAYAudioEvent`-conforming instances
 *
 *  @return The newly-initialized `SAYCompositeEvent`
 */
- (instancetype)initWithComponentEvents:(NSArray <id<SAYAudioEvent>> *)events NS_DESIGNATED_INITIALIZER;

/// @abstract Use initWithComponentEvents: to initialize.
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
