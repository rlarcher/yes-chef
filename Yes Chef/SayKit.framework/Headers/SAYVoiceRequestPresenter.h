//
//  SAYVoiceRequestPresenter.h
//  SayKit
//
//  Created by Greg Nicholas on 11/15/15.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SAYVoiceRequest;
@protocol SAYAudioEventListener;

@class UIViewController;
@class SAYSpeechRecognitionManager;

NS_ASSUME_NONNULL_BEGIN

/**
 *  The `SAYVoiceRequestPresenter` is responsible for integrating all system components necessary to presenting and activate a `SAYVoiceRequest`.
 
    @warning Note that this is a fairly "internal" SayKit class, not typically needed for developer manipulation. The API of this class is expected to change significantly before version 1.0 is released.
 */
@interface SAYVoiceRequestPresenter : NSObject

/**
 *  Recognition manager to be provided to all presented requests. To ensure the manager is idle when presenting, no other parts of the application should interact with it.
 */
@property (nonatomic, strong) SAYSpeechRecognitionManager *recognitionManager;

/**
 *  Initiates a `SAYVoiceRequestPresenter` with the given request manager and output audio track.
 *
 *  @param manager Manager to run speech recognition sessions
 *
 *  @return The newly-initiated presenter
 */
- (instancetype)initWithSpeechRecognitionManager:(SAYSpeechRecognitionManager *)manager;

/**
 *  Presents the given request, using the provided view controller to present the voice request controller.
 
    Note: Requests will play audio through the system conversation manager's SAYAudioTrackVoiceRequestIdentifier track. This is currently fixed, but will more flexible in future releases.
 *
 *  @param request Request to be presented
 *  @param presentingViewController View controller from which to modally present request's visual component
 */
- (void)presentRequest:(id<SAYVoiceRequest>)request fromViewController:(UIViewController *)presentingViewController;

/**
 *  Deactivates and dismisses the given request. Once the request deactivates, the view controller is dismissed, the `outputTrack` is disconnected, and any active recognition session with manager is cancelled.
 *
 *  @param completion Block to be executed when dismissal completes
 */
- (void)dismissPresentedRequestCompletion:(void (^ __nullable)(void))completion;

@end

NS_ASSUME_NONNULL_END
