//
//  SAYAudioTrack.h
//  SayKit
//
//  Created by Greg Nicholas on 7/1/15.
//  Copyright (c) 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAYAudioFocusManagement.h"
#import "SAYAudioEvent.h"

@class SAYAudioEvent;

NS_ASSUME_NONNULL_BEGIN

/**
 *  The `SAYAudioTrack` class provides a queue for `SAYAudioEvent` instances to be posted to. When events are added, their corresponding operations are executed in serial order. These operations contain the actual execution logic for presenting audio to the speaker.
 
    As long as a track has operations that have not yet completed, it is considered "live",
 */
@interface SAYAudioTrack : NSObject <SAYAudioFocusRequester>

/**
 *  A numerical priority for the track. Higher-valued tracks are given priority over lower-valued ones.
 */
@property (nonatomic, assign, readonly) unsigned int priority;

/**
 *  YES if the track has unplayed events left on its queue, NO otherwise. 
 
    Note that this property reflects the instantaneous state of its receiver's internal operation queue at the time it is referenced, which is not necessarily a thread-safe observation. In other words, don't rely on this value being accurate by the time you use it.
 */
@property (nonatomic, readonly) BOOL isLive;

/**
 *  If the track is currently allowed to present its events, this is set to YES.
 */
@property (nonatomic, readonly) BOOL hasFocus;

/**
 *  Initalizes a new track with the given priority and focus guard. In post cases, a SAYAudioTrackCoordinator is responsibile for initializing new tracks.
 *
 *  @param priority     Priority of track. This comes into play when multiple tracks are being coordinated by a `SAYAudioTrackCoordinator`. The coordinator allows higher priority live tracks to present their events first.
 *  @param focusGuard   Agent in charge of coordinating track "focus" (typically a `SAYAudioTrackCoordinator`)
 *
 *  @return The newly-initiailized track
 */
- (instancetype)initWithPriority:(unsigned int)priority focusGuard:(id<SAYAudioFocusGuard>)focusGuard NS_DESIGNATED_INITIALIZER;

/// @abstract Use initWithPriority:focusGuard: to initialize.
- (instancetype)init NS_UNAVAILABLE;

/**
 *  Convenience method for addEvent:completion: that uses an empty completion block
 *
 *  @param event Event to add to the end of the track
 */
- (void)addEvent:(id<SAYAudioEvent>)event;

/**
 *  Adds a series of events to the track
 *
 *  @param events Events to add to the end of the track
 */
- (void)addEvents:(NSArray *)events;

/**
 *  Adds an event to the track's queue with the given block running after the event's operations complete.
 *
 *  @param event            Event to add to the end of the track
 *  @param completionBlock  Completion block run after event's operations complete. No guarantees are made about it's execution context (i.e. thread, synchronicity).
 */
- (void)addEvent:(id<SAYAudioEvent>)event completion:(SAYAudioEventCompletionBlock)completionBlock;

/**
 *  Cancels all ongoing and pending events in the track.
 */
- (void)cancelAll;


@end

NS_ASSUME_NONNULL_END
