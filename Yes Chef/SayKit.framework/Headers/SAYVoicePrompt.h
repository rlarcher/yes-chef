//
//  SAYVoicePrompt.h
//  SayKit
//
//  Created by Greg Nicholas on 12/16/15.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIViewController;
@class AVSpeechUtterance;
@class SAYVoicePromptViewController;

NS_ASSUME_NONNULL_BEGIN

/**
 *  The `SAYVoicePrompt` describes a prompt designed for the application to present to the user, often in the form of a question. It contains a message to be displayed, a message to be spoken (often echoing the displayed message), and an optional view controller for the sake of adding custom visuals to the prompt.
 */
@interface SAYVoicePrompt : NSObject <NSCopying>

/**
 *  Text to be displayed
 */
@property (nonatomic, copy, readonly) NSAttributedString *displayMessage;

/**
 *  Message to be spoken
 */
@property (nonatomic, copy, readonly) AVSpeechUtterance *spokenMessage;

/**
 *  An optional view controller to be paired along with the verbal messages, in order to supplement them with custom visuals. The supplemental view can include controls, creating an opportunity for touch-based responses to prompts.
 */
@property (nonatomic, strong, nullable) UIViewController *supplementalViewController;

/**
 *  Factory method to create a simple prompt with the same message to be spoken and displayed.
 *
 *  @param message Message to be both spoken and displayed.
 *
 *  @return A new `SAYVoicePrompt` instance with the given message.
 */
+ (instancetype)promptWithMessage:(NSString *)message;

/**
 *  Creates and returns a simple prompt with the same message to be spoken and displayed.
 *
 *  @param message message Message to be both spoken and displayed.
 *
 *  @return A new `SAYVoicePrompt` instance with the given message.
 */
- (instancetype)initWithMessage:(NSString *)message;

/**
 *  Creates an returns a prompt with a potentially different message for display and speech purposes.
 *
 *  @param displayMessage Attributed text message to be displayed
 *  @param spokenMessage  Message as a speech utterance
 *
 *  @return A new `SAYVoicePrompt` instance with the given message componenets.
 */
- (instancetype)initWithDisplayMessage:(NSAttributedString *)displayMessage spokenMessage:(AVSpeechUtterance *)spokenMessage NS_DESIGNATED_INITIALIZER;

/// @abstract Not supported. Use designated initialize for this class instead.
- (instancetype)init NS_UNAVAILABLE;

/**
 *  Equality method specific to `SAYVoicePrompt` classes.
 *
 *  @param voicePrompt Other prompt to test for equality.
 *
 *  @return YES if the prompter are equal (that is their underlying message and view controllers are equal); NO otherwise.
 */
- (BOOL)isEqualToVoicePrompt:(SAYVoicePrompt *)voicePrompt;

@end

NS_ASSUME_NONNULL_END
