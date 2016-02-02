//
//  SAYManagedSynthesizer.h
//  SayKit
//
//  Created by Greg Nicholas on 7/1/15.
//  Copyright (c) 2015 Conversant Labs. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@class SAYSpeechSynthesizerProxy;

NS_ASSUME_NONNULL_BEGIN

/**
 *  The `SAYManagedSynthesizer` is a `AVSpeechSynthesizer` with additional capabilities that support per-utterance delegation. As a side effect of this, a delegate should not be set directly on the synthesizer.
 
    iOS does not behave well with multiple active `AVSpeechSynthesizer` instances, which is what led to the development of this class. If multiple synthesizers are needed, a single instance of this class should be used to spawn `SAYSpeechSynthesizerProxy` satellite synthesizers.
 
    As a consequence, this class should be treated like a singleton: only use the system-wide `sharedInstance`.
 */
@interface SAYManagedSynthesizer : AVSpeechSynthesizer

/**
 *  Returns a system-wide shared instance of a `SAYManagedSynthesizer`. Most applications will only need this instance.
 *
 *  @return A system-wide shared instance of a `SAYManagedSynthesizer`
 */
+ (SAYManagedSynthesizer *)sharedInstance;

/**
 *  Same as base class `speakUtterance:` method, except the delegate for events specific to the given utterance is provided directly in the call. The synthesizer guarantees that all delegate callbacks will be applicable to the given utterance only.
 *
 *  @param utterance    Utterance to be spoken
 *  @param handler      Delegate reference that will be retained for the lifetime of utterance (until cancelled or finished)
 */
- (void)speakUtterance:(AVSpeechUtterance *)utterance updateHandler:(id<AVSpeechSynthesizerDelegate>)handler;

@end

/**
 *  The `SAYManagedSynthesizerDependant` protocol describes a class that needs a `SAYManagedSynthesizer` to perform its duties (i.e. the processes underlying `SAYSpeechEvent` operations).
 */
@protocol SAYManagedSynthesizerDependant <NSObject>

/**
 *  A set-able synthesizer property
 */
@property (nonatomic, strong, nullable) SAYManagedSynthesizer *managedSynthesizer;

@end

NS_ASSUME_NONNULL_END
