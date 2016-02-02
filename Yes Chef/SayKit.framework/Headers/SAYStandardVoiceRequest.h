//
//  SAYVoiceRequest.h
//  SayKit
//
//  Created by Greg Nicholas on 11/18/15.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAYVoiceRequest.h"
#import "SAYStandardRequestResponder.h"

@class SAYVoicePrompt;

@protocol SAYSpeechRecognitionService;
@protocol SAYVoiceRequestInterpreter;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Configuration class integrating all components necessary for a full voice-based request-response cycle. This includes the user prompt, the underlying speech recognition service, the interpreter for recognized speech, and the application's ultimate response.
 */
@interface SAYStandardVoiceRequest : NSObject <SAYVoiceRequest>

@property (nonatomic, copy, readonly, nullable) SAYVoicePrompt *prompt;
@property (nonatomic, strong, readonly) SAYStandardRequestResponder *responder;

- (instancetype)initWithPrompt:(SAYVoicePrompt *)prompt responder:(SAYStandardRequestResponder *)responder NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithPromptText:(NSString *)promptText action:(void (^)(id __nullable))action;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)clone;
- (instancetype)cloneReplacingPrompt:(SAYVoicePrompt *)newPrompt;

@end

NS_ASSUME_NONNULL_END