//
//  SAYSoundTrackCoordinator.h
//  SayKit
//
//  Created by Greg Nicholas on 7/1/15.
//  Copyright (c) 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAYAudioFocusManagement.h"

@class SAYManagedSynthesizer;
@class SAYAudioTrack;

NS_ASSUME_NONNULL_BEGIN

/**
 *  The `SAYAudioTrackCoordinator` is the nerve-center for all audio operations. It manages multiple `SAYAudioTrack`s, giving each permission to present their events according to their priority.
 */
@interface SAYAudioTrackCoordinator : NSObject <SAYAudioFocusGuard>

/**
 *  The managed synthesizer controlled by this coordinator. It is available to tracks when audio focus is granted to them.
 */
@property (nonatomic, readonly) SAYManagedSynthesizer * managedSynth;

/**
 *  Initailizes a new coordinator with the given synthesizer
 *
 *  @param managedSynth Managed synthesizer instance to coordinate  multi-agent speech synthesis
 *
 *  @return The newly-initialized `SAYAudioTrackCoordinator`
 */
- (instancetype)initWithManagedSynthesizer:(SAYManagedSynthesizer *)managedSynth NS_DESIGNATED_INITIALIZER;

/// @abstract Use initWithManagedSynthesizer: to initialize.
- (instancetype)init NS_UNAVAILABLE;

/**
 *  Create a new audio track to be managed by the receiver.
 *
 *  @param identifier New track identifier string
 *  @param priority Priorty of the track for the sake of focus management. Higher number means higher priority.
 *
 *  @return The new SAYAudioTrack instance
 */
- (SAYAudioTrack *)registerTrackWithIdentifier:(NSString *)identifier priority:(unsigned int)priority;

/**
 *  Release the track with the given identifier from the receiver.
 *
 *  @param identifier Track identifier string
 */
- (void)unregisterTrackWithIdentifier:(NSString *)identifier;

/**
 *  Returns the track registered with the given identifier, if it exists.
 *
 *  @param identifier Track identifier string
 *
 *  @return Registered track, if one exists. Nil otherwise.
 */
- (nullable SAYAudioTrack *)trackWithIdentifier:(NSString *)identifier;

/**
 *  Suspends execution on all tracks, regardless of priority.
 */
- (void)suspendTracks;

/**
 *  Resumes execution of tracks, according to standard prioritization rules.
 */
- (void)resumeTracks;

@end

NS_ASSUME_NONNULL_END
