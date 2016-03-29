//
//  SAYSpeechRecognitionManager.h
//  SayKit
//
//  Created by Greg Nicholas on 7/28/15.
//  Copyright (c) 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SAYSpeechRecognitionService;
@protocol SAYSpeechRecognitionManagerDelegate;
@protocol SAYSpeechRecognitionResult;

NS_ASSUME_NONNULL_BEGIN

/**
 *  During a request, the manager owns a session object that cycle between the states represented by `SAYSpeechRecognitionSessionState`.
 */
typedef NS_ENUM(NSUInteger, SAYSpeechRecognitionSessionState) {
    /**
     *  No request is currently underway
     */
    SAYSpeechRecognitionSessionStateNone,
    /**
     *  The delay before a session is created and the microphone activates
     */
    SAYSpeechRecognitionSessionStateInitializing,
    /**
     *  Once the microphone is actively listening
     */
    SAYSpeechRecognitionSessionStateListening,
    /**
     *  The delay between the microphone deactivating and a result (or error) being received
     */
    SAYSpeechRecognitionSessionStateProcessing
};

/**
 *  `SAYSpeechRecognitionManager` is a class used to provide a higher-level session-based interface to the voice recognition service's. In addition, the manager acts as a guard to ensure only one request is active at a time.
 */
@interface SAYSpeechRecognitionManager : NSObject

/**
 *  Amount of time to wait for a response from the recognition server after a stop action is requested.
 
 If `stopListeningNow` is not followed by a success or failure response from the intent recongition server in this time window, the session will abort.
 */
@property (nonatomic, assign) NSTimeInterval responseTimeout;

/**
 *  The current state of the manager's session. See `SAYSpeechRecognitionSessionState` for descriptions.
 */
@property (atomic, readonly) SAYSpeechRecognitionSessionState sessionState;

/**
 *  A delegate instance to receive updates during a recognition session.
 */
@property (atomic, weak, nullable) id<SAYSpeechRecognitionManagerDelegate> delegate;

/**
 *  Starts a new session, if possible. If an session initiated by this manager is still in progress, no new session will be begun.
 *
 *  @param recognitionService Agent in charge of handling communication with speech recognition service.
 *
 *  @return YES if a new session was initiated, NO if it could not be due to an already active session.
 */
- (BOOL)initiatePromptWithService:(id<SAYSpeechRecognitionService>)recognitionService;

/**
 *  Stops the audio recording process of the recognition session immediately, though the session will still attempt to recognized the recorded speech. The session will only end when a response is returned to the delegate via the `recognitionManager:didCompleteRequestWithResponse:error:` method.
 
    Sessions can also stop on their own (for example, if the service detects a pause in speech).
 */
- (void)stopListeningNow;

/**
 *  Stops the recognition service and cancels the recognition session immediately. No recognition response will be received by the delegate after this call.
 */
- (void)cancel;

@end

/**
 *  The `SAYSpeechRecognitionManagerDelegate` protocol describes messages the manager will send in response to recognition events it receives during a session.
 */
@protocol SAYSpeechRecognitionManagerDelegate <NSObject>

/**
 *  Sent when the state of the manager's active session changes.
 *
 *  @param manager  Manager facilitating the recognition session
 *  @param state    New state of manager's active session
 */
- (void)recognitionManager:(SAYSpeechRecognitionManager *)manager stateDidChange:(SAYSpeechRecognitionSessionState)state;

/**
 *  Audio level change messages that are forwarded on from the `SAYSpeechRecognitionService`.
 *
 *  @param manager      Manager facilitating the recognition session
 *  @param audioLevel   Raw decibel level of the input audio
 */
- (void)recognitionManager:(SAYSpeechRecognitionManager *)manager recordingAudioLevelDidChange:(float)audioLevel;

/**
 *  Partial text recognition results that are forwarded on from the `SAYSpeechRecognitionService`.
 *
 *  @param manager  Manager facilitating the recognition session
 *  @param text     Partial transcript text content
 */
- (void)recognitionManager:(SAYSpeechRecognitionManager *)manager didReceivePartialTranscriptText:(NSString *)text;

/**
 *  Sent as a session concludes with either successful response data, or error information.
 *
 *  @param manager      Manager facilitating the recognition session
 *  @param result       Result (exact type depends on underlying `SAYSpeechRecognitionService`). Will be nil if error occurs.
 *  @param error        If non-nil, error describing why a recognition response could not be received
 */
- (void)recognitionManager:(SAYSpeechRecognitionManager *)manager didCompleteRequestWithResult:(nullable id<SAYSpeechRecognitionResult>)result error:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
