//
//  SAYVoiceRequestResponder.h
//  SayKit
//
//  Created by Greg Nicholas on 12/16/15.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAYVoiceRequestResponse.h"

@protocol SAYVoiceRequest;
@class SAYInterpretation;

NS_ASSUME_NONNULL_BEGIN

@protocol SAYVoiceRequestResponder <NSObject>

- (SAYVoiceRequestResponse *)voiceRequest:(id<SAYVoiceRequest>)voiceRequest respondToInterpretation:(SAYInterpretation *)interpretation;
- (SAYVoiceRequestResponse *)voiceRequest:(id<SAYVoiceRequest>)voiceRequest respondToRecognitionError:(NSError *)error;
- (nullable SAYVoiceRequestResponseAction)respondToCancellationOfVoiceRequest:(id<SAYVoiceRequest>)voiceRequest;

@end

NS_ASSUME_NONNULL_END
