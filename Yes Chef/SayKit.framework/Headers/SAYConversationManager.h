//
//  SAYConversationManager.h
//  SayKit
//
//  Created by Greg Nicholas on 1/12/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SAYAudioEventListener.h"

@protocol SAYVerbalCommandRegistry;
@protocol SAYAudioEventSource;
@protocol SAYVoiceRequest;
@class SAYAudioTrackCoordinator;
@class UIWindow;
@class UIViewController;

NS_ASSUME_NONNULL_BEGIN

/**
 As the foundation of the SayKit stack, the `SAYConversationManager` class integrates application-wide interfaces for audio track coordination, voice request presentation, and verbal command availability.
 
 The provided `systemManager` should be the only instance of this class needed for the vast majority of applications.
 
 ## Audio Source Configuration
 
 The `SAYConversationManager` conforms to the `SAYAudioEventListener` protocol, sending any audio event sequences from its registered sources to their respective tracks for audio production. To enable this connection, a source must be explicitly added to a manager (and connected to one of the tracks supported by it's track coordinator). This is configuration is often done during app initialization. For more details, see the documentation for `SAYAudioEventSource` and `SAYAudioTrackCoordinator`.
 
 The `trackCoordinator` on the application-wide `systemManager` is preconfigured with two tracks: the "main" and "voice request" track. The "main" track is intended for typical application speech and the "voice request" track is intended for audio out during voice requests (i.e. prompts and microphone activation sounds). These two tracks can be referenced with the string constants `SAYAudioTrackMainIdentifier` and `SAYAudioTrackVoiceRequestIdentifier`, respectively.
 
 ## Voice Command Configuration

 To support voice commands, applications must explicitly set the manager's `commandRegistry`. This collaborator is tasked with being the central authority on available voice commands. See the documentation for the `SAYVerbalCommandRegistry` protocol for more details.
 */
@interface SAYConversationManager : NSObject <SAYAudioEventListener>

/**
 Returns the persistent system manager, which is typically the only instance needed in a SayKit application.
 
 It is preconfigured to use the window provided by the application's `UIApplicationDelegate` and a track coordinator with a tracks named `SAYAudioTrackMainIdentifier` and `SAYAudioTrackVoiceRequestIdentifier`.
 *
 *  @return The persistent conversation manager
 */
+ (SAYConversationManager *)systemManager;

/**
 *  Initializes a `SAYConversationManager` with an `trackCoordinator` and `window`, used to integrate a SayKit application with the respective device interfaces.
 *
 *  @param trackCoordinator The `trackCoodinator` to manage audio output
 *  @param window           The primary `window` responsible for the application's visual content
 *
 *  @return The newly initialized manager
 */
- (instancetype)initWithTrackCoordinator:(SAYAudioTrackCoordinator *)trackCoordinator window:(UIWindow *)window;

/**
 @name Audio Output Coordination
 **/

/**
 *  Tells the receiver to begin listening to the given source, passing it's posted audio event sequences to the specified track.
 *
 *  @param source          A source that produces `SAYAudioEventSequence`s for playback
 *  @param trackIdentifier Name of a track managed by the receiver's `trackCoordinator`. If an unknown track name is provided, the source's events will not produce audio.
 */
- (void)addAudioSource:(id<SAYAudioEventSource>)source forTrack:(NSString *)trackIdentifier;

/**
 *  Tells the receiver to stop listening to the given source. In essence, this disconnects the source from it's output track.
 *
 *  @param source The source to silence
 */
- (void)removeAudioSource:(id<SAYAudioEventSource>)source;

/**
 *  The agent coordinating the set of audio tracks available for queuing events onto.
 */
@property (nonatomic, strong, readonly, nonnull) SAYAudioTrackCoordinator *trackCoordinator;

/**
 @name Voice Request Presentation
 **/

/**
 *  Used as a provider for the application's root view controller, from which typical voice requests are presented.
 */
@property (nonatomic, strong, readonly, nonnull) UIWindow *window;

/**
 *  Present the given voice request. This is a convenience method for `presentVoiceRequest:fromViewController that uses the root view controller attached to the receiver's `window`.
 *
 *  @param voiceRequest A `SAYVoiceRequest`-conforming class instance to be immediately presented to the screen and speaker.
 */
- (void)presentVoiceRequest:(id<SAYVoiceRequest>)voiceRequest;

/**
 *  Present the given voice request, using the given view controller to present the `UIViewController` associated with the active request.
 *
 *  @param voiceRequest A `SAYVoiceRequest`-conforming class instance to be immediately presented to the screen and speaker.
 */
- (void)presentVoiceRequest:(id<SAYVoiceRequest>)voiceRequest fromViewController:(UIViewController *)viewController;

/**
 @name Voice Command Management
 **/

/**
 *  Provides the a set of `SAYCommandRecognizer` instances that are available for use at any given time.
 */
@property (nonatomic, strong, nullable) id<SAYVerbalCommandRegistry> commandRegistry;

@end

/**
 *  String identifier for the default "main" audio track, responsible for queuing normal application audio.
 */
FOUNDATION_EXPORT NSString * const SAYAudioTrackMainIdentifier;

/**
 *  Priority value for the audio track identified by `SAYAudioTrackMainIdentifier`. Value is set to 10.
 */
FOUNDATION_EXPORT const unsigned int SAYAudioTrackMainPriority;

/**
 *  String identifier for the default "voice request" audio track, responsible for queuing audio during voice requests.
 */
FOUNDATION_EXPORT NSString * const SAYAudioTrackVoiceRequestIdentifier;

/**
 *  Priority value for the audio track identified by `SAYAudioTrackVoiceRequestIdentifier`. Value is set to 999.
 */
FOUNDATION_EXPORT const unsigned int SAYAudioTrackVoiceRequestPriority;

NS_ASSUME_NONNULL_END
