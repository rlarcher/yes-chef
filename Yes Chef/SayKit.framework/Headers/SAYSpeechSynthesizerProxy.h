//
//  SAYSpeechSynthesizerProxy.h
//  SayKit
//
//  Created by Greg Nicholas on 7/1/15.
//  Copyright (c) 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class SAYManagedSynthesizer;
@protocol SAYSpeechSynthesizerProxyDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 *  The `SAYSpeechSynthesizerProxy` is a speech synthezier with a similar interface to an `AVSpeechSynthesizer`, but it acts only on a particular utterance during its lifetime.
 
    Multiple `SAYSpeechSynthesizerProxy`s still cannot speak at the same time, but interruptions from other instances will be interpretted as pause messages, not a stop. Continue messages sent after an interruption will more-or-less work just like a continue after a pause.
 */
@interface SAYSpeechSynthesizerProxy : NSObject

/**
 *  The underlying agent capable of synthesizing the speech
 */
@property (nonatomic, strong, readonly) SAYManagedSynthesizer *managedSynth;

/**
 *  The fixed utterance this synthesizer is capable of speaking
 */
@property (nonatomic, strong, readonly) AVSpeechUtterance *utterance;

/**
 *  A delegate to receive events about the synthesis process
 */
@property (nonatomic, weak, nullable) id<SAYSpeechSynthesizerProxyDelegate> delegate;

/**
 *  Initializes a new proxy synthesizer to speak the given utterance backed by the given `SAYManagedSynthesizer` instance.
 *
 *  @param synthesizer Agent that provides the managed synthesizer "engine" capable of producing speech
 *  @param utterance Speech utterance to be spoken by this proxy synth
 *
 *  @return The newly-initialized `SAYSpeechSynthesizerProxy`
 */
- (instancetype)initWithManagedSynthesizer:(SAYManagedSynthesizer *)synthesizer utterance:(AVSpeechUtterance *)utterance NS_DESIGNATED_INITIALIZER;

/// @abstract Use initWithManagedSynthesizer:utterance: to initialize.
- (instancetype)init NS_UNAVAILABLE;

/**
 *  Starts not-yet-begun speech. Has no effect once speech has begun.
 */
- (void)startSpeaking;

/**
 *  Pauses speech.
 *
 *  @param boundary Whether speech should stop at the next word boundary or immediately
 *
 *  @return YES if speech has paused, NO otherwise (just sends return value of the underlying AVSpeechSynthesizer's method).
 */
- (BOOL)pauseSpeakingAtBoundary:(AVSpeechBoundary)boundary;

/**
 *  Stops speech.
 *
 *  @param boundary Whether speech should stop at the next word boundary or immediately
 *
 *  @return YES if speech has stopped, NO otherwise (just sends return value of the underlying AVSpeechSynthesizer's method).
 */
- (BOOL)stopSpeakingAtBoundary:(AVSpeechBoundary)boundary;

/**
 *  Continues speaking where the synth left off when last paused or interrupted. Has no effect if not paused or interrupted.
 *
 *  @return YES if speech has continued, or NO otherwise (just sends return value of the underlying AVSpeechSynthesizer's method)
 */
- (BOOL)continueSpeaking;

@end

/**
 *  The `SAYSpeechSynthesizerProxyDelegate` protocol describes messages sent back from `SAYSpeechSynthesizerProxy` instances as they receive events.
 */
@protocol SAYSpeechSynthesizerProxyDelegate

/**
 *  Called when the synthesizer is finished speaking its utterance.
 *
 *  @param synthProxy Synthesizer proxy whose utterance just completed
 *  @param didFinish YES if the utterance was spoken to completion, NO if it was cancelled before it could complete
 */
- (void)synthesizerProxyDidReceiveCompletedMessage:(SAYSpeechSynthesizerProxy *)synthProxy didFinish:(BOOL)didFinish;

/**
 *  Called when the synthesizer is interrupted when another `SAYSpeechSynthesizerProxy` instance that uses the same underlying managed synthesizer starts speaking an utterance. 
 *
 *   It is important to note that this is not to signify that the utterance was cancelled. Rather, it is a message marking a potentially temporary interruption.
 *
 *  @param synthProxy Synthesizer proxy whose utterance was just interrupted
 */
- (void)synthesizerProxyDidReceiveInterruptedMessage:(SAYSpeechSynthesizerProxy *)synthProxy;

@end

NS_ASSUME_NONNULL_END
