//
//  SAYVoiceRequestView.h
//  SayKit
//
//  Created by Greg Nicholas on 12/16/15.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SAYVoiceRequestMicrophoneDelegate;
@class SAYWaveformView;

typedef NS_ENUM(NSUInteger, SAYVoiceRequestViewMicState) {
    SAYVoiceRequestViewMicDisabled,     // !enabled, !waveform.hidden
    SAYVoiceRequestViewMicEnabled,      // enabled, !waveform.hidden
    SAYVoiceRequestViewMicActive,       // enabled, waveform.hidden
};

@interface SAYVoiceRequestView : UIView

/**
 *  Displays the current prompt text. 
 
    @warning To update the view's text content, use `setPromptString:` or `setPromptAttributedString:` rather than setting it directly through this property.
 */
@property (nonatomic, strong, readonly) UITextView *promptTextView;

/**
 *  Button to control microphone activity
 */
@property (nonatomic, strong, readonly) UIButton *microphoneButton;

@property (nonatomic, assign) SAYVoiceRequestViewMicState microphoneState;

/**
 *  Displays a partial transcript received from the speech recognition service
 */
@property (nonatomic, strong, readonly) UILabel *partialTranscriptLabel;

/**
 *  View containing the supplemental prompt view
 */
@property (nonatomic, strong, readonly) UIView *supplementalViewContainer;

/**
 *  Delegate listening for microphone events
 */
@property (nonatomic, weak) id<SAYVoiceRequestMicrophoneDelegate> microphoneDelegate;

/**
 *  Visualization of microphone activity
 */
@property (nonatomic, strong, readonly) SAYWaveformView *waveformView;

- (void)setSupplementalView:(nullable UIView *)view;

- (void)setPromptString:(nullable NSString *)string;

- (void)setPromptAttributedString:(nullable NSAttributedString *)aString;

@end

/**
 *  The `SAYVoiceRequestMicrophoneDelegate` protocol prescribes an interface for communicating control events from a `SAYVoiceRequestController`.
 */
@protocol SAYVoiceRequestMicrophoneDelegate <NSObject>

/**
 *  Called when the view's microphone button is tapped
 *
 *  @param voiceRequestView View containing microphone control
 */
- (void)voiceRequestViewMicrophoneWasTapped:(SAYVoiceRequestView *)voiceRequestView;

@end

NS_ASSUME_NONNULL_END
