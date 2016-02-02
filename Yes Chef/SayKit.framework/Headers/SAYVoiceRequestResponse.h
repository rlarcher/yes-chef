//
//  SAYVoiceRequestResponse.h
//  SayKit
//
//  Created by Greg Nicholas on 12/16/15.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SAYVoiceRequest;
@class SAYVoicePrompt;

NS_ASSUME_NONNULL_BEGIN

typedef void (^SAYVoiceRequestResponseAction)();

@interface SAYVoiceRequestResponse : NSObject

@property (nonatomic, strong, readonly, nullable) SAYVoicePrompt *feedbackPrompt;
@property (nonatomic, strong, readonly, nullable) id<SAYVoiceRequest> followupRequest;
@property (nonatomic, copy, readonly, nullable) SAYVoiceRequestResponseAction action;

+ (instancetype)terminalResponseWithAction:(nullable SAYVoiceRequestResponseAction)action;
+ (instancetype)responseWithFollowupRequest:(id<SAYVoiceRequest>)request;

- (instancetype)initWithFeedbackPrompt:(nullable SAYVoicePrompt *)feedbackPrompt
                       followupRequest:(nullable id<SAYVoiceRequest>)followupRequest
                                action:(nullable SAYVoiceRequestResponseAction)action NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
