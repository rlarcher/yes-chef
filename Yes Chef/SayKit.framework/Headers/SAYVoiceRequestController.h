//
//  SAYVoiceRequestController.h
//  SayKit
//
//  Created by Greg Nicholas on 10/20/15.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SAYSpeechRecognitionManager.h"

@protocol SAYVoiceRequestMicrophoneDelegate;
@protocol SAYVoiceRequest;

@class SAYVoiceRequestSoundBoard;
@class SAYVoiceRequestPresenter;
@class SAYVoiceRequestView;
@class SAYInterpretation;

#import "SAYVoiceRequestResponse.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  The `SAYVoiceRequestController` manages the lifecycle of a `SAYVoiceRequest`. It is a `UIViewController` subclass, so in addition to managing the lifecycle, it also manages the visual presentation of the request.
 
    Voice request sessions begin once the controller appears on screen (i.e. it's `viewDidAppear:` method is called. This controller will remain presented until a request session finishes with no followup request.
 
    @warning Note that this is a fairly "internal" SayKit class, not typically needed for developer manipulation. The API of this class is expected to change significantly before version 1.0 is released.
 */
@interface SAYVoiceRequestController : UIViewController <SAYSpeechRecognitionManagerDelegate>

/**
 *  Primary view displaying state of request and allowing interaction with the request flow
 */
@property (nonatomic, strong, null_unspecified) SAYVoiceRequestView *voiceRequestView;

/**
 *  A sound board used to provide feedback during the request session.
 */
@property (nonatomic, strong) SAYVoiceRequestSoundBoard *soundBoard;

/**
 *  Customizable style for the overlay underlying the request view
 */
@property (nonatomic, assign) UIBlurEffectStyle overlayBlurEffectStyle;

/**
 *  A supplemental child controller whose view is embedded in the `voiceRequestView`
 */
@property (nonatomic, strong, readonly, nullable) UIViewController *supplementalViewController;

/**
 When the request is active, the instance that presented it.
 
 This property should be set by the presenter itself.
 */
@property (nonatomic, strong, nullable) SAYVoiceRequestPresenter *presenter;

/**
 *  The agent managing the speech recognition process during the request.
 */
@property (nonatomic, strong, nullable) SAYSpeechRecognitionManager *recognitionManager;

/**
 The voice request this controller is managing.
 
 @warning This should not be set while the controller is presented on screen. Doing so will cause an assertion error.
 */
@property (nonatomic, strong, nullable) id<SAYVoiceRequest> voiceRequest;

/**
 Short-circuits the voice request process by skipping to the request's "responding" stage with the given processed user input. This method is commonly called when the speech recognition process is bypassed due to an interactive control in the request prompt.

 @param interpretation An interpretation representing the user's intent. It's contents should mirror what the request's `interpreter` would produce.
 */
- (void)respondImmediatelyToInterpretation:(SAYInterpretation *)interpretation;

/**
 Cancels the request immediately. This will send a cancel message to the request's `responder`.
 
 @warning Note that this method *does not* directly dismiss the controller. That role is delegated to the `presenter`, which is the typical collaborator calling this method. Expect this to change by version 1.0.
 
 @return A cleanup action as dictated by the request's responder.
 */
- (nullable SAYVoiceRequestResponseAction)cancelRequest;

@end

NS_ASSUME_NONNULL_END
