//
//  SAYVoiceRequestInterpreter.h
//  SayKit
//
//  Created by Greg Nicholas on 12/16/15.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SAYSpeechRecognitionResult;
@protocol SAYVoiceRequest;
@class SAYInterpretation;

NS_ASSUME_NONNULL_BEGIN

/**
 *  The `SAYVoiceRequestInterpreter` protocol describes a class capable of transforming the raw results of speech recognition into a more useful form for the application to use. This higher-level form is encapsulated in a `SAYInterpretation`, which holds the result as well as other relevant data discovered during the interpretation process.
 
    For example, an interpreter might be tasked with classify speech as either having a "yes" or "no" intent, transforming the text into a boolean value stored inside the `SAYInterpretation`. If the user speech has no clear intent, the interpretation could instead hold a validation error describing the reason no intent could be interpreted.
 
    Interpreters are al
 */
@protocol SAYVoiceRequestInterpreter <NSObject>

/**
 *  The sole method required by the `SAYVoiceRequestInterpreter` protocol. It consumes the result of a speech recognition process, and produces an interpretation of that speech suitable for it's source voice request.
 *
 *  Oftentimes, this process can be intensive, needing external services to help with the interpretation. As a result, this method is an asyncrhnous, accepting a callback block to be called when the process completes.
 *
 *  @param voiceRequest The source voice request
 *  @param result       Raw result produced by the `SAYSpeechRecognitionService` used in this request
 *  @param completion   Completion block, **must** be called when interpretation finishes.
 */
- (void)voiceRequest:(id<SAYVoiceRequest>)voiceRequest interpretResult:(id<SAYSpeechRecognitionResult>)result completion:(void (^)(SAYInterpretation *))completion;

@end

NS_ASSUME_NONNULL_END
