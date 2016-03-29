//
//  SAYVoiceRequestSoundBoard.h
//  SayKit
//
//  Created by Greg Nicholas on 11/23/15.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SAYSoundBoard.h"

@class SAYAudioTrack;
@class AVSpeechUtterance;

NS_ASSUME_NONNULL_BEGIN

/**
 *  The `SAYVoiceRequestSoundBoard` a `SAYSoundBoard` subclass with settings and methods specific for sounds used during voice requests (e.g. microphone activity earcons).
 */
@interface SAYVoiceRequestSoundBoard : SAYSoundBoard

/**
 *  Tone to play when the microphone becomes active.
 
 When set to nil, the SayKit default tone will be used.
 */
@property (nonatomic, copy, null_resettable) NSURL *microphoneStartToneURL;

/**
 *  Tone to play when the microphone becomes inactive.
 
 When set to nil, the SayKit default tone will be used.
 */
@property (nonatomic, copy, null_resettable) NSURL *microphoneStopToneURL;

/**
 *  Tone to play when a command is not recognized.
 
 When set to nil, the SayKit default tone will be used.
 */
@property (nonatomic, copy, null_resettable) NSURL *unrecognizedCommandToneURL;

/**
 *  Plays the receiver's preset microphone start tone.
 */
- (void)playMicrophoneStartTone;

/**
 *  Plays the receiver's preset microphone stop tone.
 */
- (void)playMicrophoneStopTone;

/**
 *  Plays the receiver's preset tone for an unrecognized command.
 */
- (void)playUnrecognizedCommandTone;

@end

NS_ASSUME_NONNULL_END
