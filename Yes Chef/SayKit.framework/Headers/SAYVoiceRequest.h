//
//  SAYVoiceRequest.h
//  SayKit
//
//  Created by Greg Nicholas on 12/31/15.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SAYVoicePrompt;
@protocol SAYSpeechRecognitionService;
@protocol SAYVoiceRequestInterpreter;
@protocol SAYVoiceRequestResponder;

/**
 The `SAYVoiceRequest` protocol integrates the set of collaborators necessary to complete a single  SayKit voice request session. Any class conforming to this protocol can be a voice request by providing values for each property.
 
 ## Request Stages
 
 Each voice request process flows through the following four stages in order, each one represented by a collaborating agent:

 1. Prompting: The application displays and speaks a message before beginning speech recognition. This `prompt` can include custom visuals by attaching a supplemental view to it.
 2. Speech Recognition: The application activates the microphone and connects to a `speechRecognition` service to translate audio into a text representation of the speech.
 3. Interpretation: Given the speech in text form, in `interpreter` can attempt to transform the text into a value more meaningful to the application (e.g. from the text "Yes" into a `true` Boolean value).
 4. Responding: Given the interpreted value, how should the application respond? Should it perform some kind of action, or ask the user another question? The `responder` defines this behavior.

 For the record, the `SAYVoiceRequestController` class manages the flow between these stages, but this is handled automatically.

 ## Supported Data Types Between Stages

 Some of collaborating agents' protocols deal in general types, but it is very important to be aware of the concrete data types that the actual agents will consume and produce. in particular:

 - If successful in recognizing speech, the `speechRecognizer` will produce an instance conforming to the `SAYSpeechRecognitionResult` protocol. This simple protocol only mandates a string property, but it can be expanded to include more metadata. The corresponding `interpreter` consumes a type conforming to `SAYSpeechRecognitionResult` as input when performing its interpretation routine, so it can take advantage of that metadata if paired with a compatible `speechRecognizer`.
 - The `interpreter` produces a `SAYInterpretation` instance, which wraps a value of type `id` along with other potentially relevant interpretation data. This underlying value represents the ultimate "result" of the voice request which the `responder` must be able to handle. As a result, this `responder` should be wired with awareness of the value type underlying the interpretation it is consuming. For example, the `responder` of a `SAYConfirmationRequest` should be expecting an interpretation whose value is of type `NSNumber` (either @0 or @1).

 Since Objective-C has no language-level generics support, it is the responsibility of the developer to ensure type compatability constraints are being respected across collaborators. A future Swift-specific library will bring this type-checking to the compilation-level with true generics support.

 See the documentation below for each collaborator for more details.

 A set of concrete standard SayKit voice requests classes exist, these classes include:
 
 - `SAYStringRequest`
 - `SAYConfirmationRequest`
 - `SAYSelectRequest`
 - `SAYNumericalRequest`
 - `SAYPatternMatchRequest`
 */
@protocol SAYVoiceRequest <NSObject>

/**
 *  The prompt to present at the beginning of the request. Conceptually, this provides the application's "turn" in a dialogue.
 */
@property (nonatomic, copy, readonly, nullable) SAYVoicePrompt *prompt;

/**
 Service responsible for managing speech recognition.
 
 Upon successful speech recognition, the service will produce an object conforming to the `SAYSpeechRecognitionResult` protocol, which only requires a string property representing the recognized speech. This result will be consumed by the paired `interpreter`.
 */
@property (nonatomic, readonly, nonnull) id<SAYSpeechRecognitionService> recognitionService;

/**
 Agent responsible for translating the text from user speech into a form useful for the application.
 
 This instance must be capable of consuming the particular `SAYSpeechRecognitionResult` type that it's associated `speechRecognizer` will produce. This interpretation process produces an object of type `SAYInterpretation`, which wraps an value of unspecified type. This interpretation will be consumed by the paired `responder` type.
 */
@property (nonatomic, readonly, nonnull) id<SAYVoiceRequestInterpreter> interpreter;

/**
 Agent responsible for responding to the interpreted user speech. This response can take many forms, including feedback messaging, application logic, and/or a followup request (see the `SAYVoiceRequestResponder` protocol for details).
 
 This instance will consume `SAYInterpretation` objects. It should expect these interpretations to wrap a value of a particular type, dictated by the associated `interpreter` that built it.
 */
@property (nonatomic, readonly, nonnull) id<SAYVoiceRequestResponder> responder;

@end
