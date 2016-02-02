//
//  SAYSoundBoard.h
//  SayKit
//
//  Created by Adam Larsen on 2016/01/20.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SAYAudioEventSource.h"

@class AVSpeechUtterance;

NS_ASSUME_NONNULL_BEGIN

/**
 *  The `SAYSoundBoard` is a simple implementation of the `SAYAudioEventSource` protocol for a basic sound production engine that posts individual audio events.
 */
@interface SAYSoundBoard : NSObject <SAYAudioEventSource>

/**
 *  Posts a speech event immediately with the given text.
 
    Acts as a convenience method for speakUtterance:then: using default AVSpeechUtterance properties and an inert block.
 *
 *  @param promptText Prompt message to speak
 */
- (void)speakText:(NSString *)text;

/**
 *  Posts a speech event immediately with the given text. Once the speech utterance completes, the given block will be executed.
 
    Acts as a convenience method for speakUtterance:then: using default AVSpeechUtterance properties
 *
 *  @param text           Text to be spoken
 *  @param completion     Action block executed after speech completes
 */
- (void)speakText:(NSString *)text then:(void(^)())completion;

/**
 *  Posts a speech event with the given utterance. Once the speech utterance completes, the given block will be executed.
 *
 *  @param utterance Prompt utterance to speak
 *  @param completion Action block executed after speech completes
 */
- (void)speakUtterance:(AVSpeechUtterance *)utterance then:(void(^)())completion;

/**
 *  Posts a tone event with the given tone.
 *
 *  @param url URL of sound file to play
 */
- (void)playToneWithURL:(NSURL *)url;

/**
 *  Posts a tone event with the given tone. Once the tone completes, the given block will be executed.
 *
 *  @param url        URL of sound file to play
 *  @param completion Action block executed after sound playback completes
 */
- (void)playToneWithURL:(NSURL *)url then:(void (^)())completion;

@end

NS_ASSUME_NONNULL_END
