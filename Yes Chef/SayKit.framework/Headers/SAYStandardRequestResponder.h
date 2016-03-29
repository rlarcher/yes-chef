//
//  SAYStandardRequestResponder.h
//  SayKit
//
//  Created by Adam Larsen on 2015/11/30.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAYVoiceRequestResponder.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN const NSInteger SAYVoiceRequestRetryForever;

@class SAYValidationError;
@class SAYStandardVoiceRequest;

@interface SAYStandardRequestResponder : NSObject <SAYVoiceRequestResponder>

// initializer for auto-pilot
- (instancetype)initWithUserAction:(void (^)(id _Nullable))action;

// initializer for more manual control over responses
// TODO: revisit this. maybe package these guys up into some kind of struct? as a delegate?
- (instancetype)initWithSuccessResponder:(SAYVoiceRequestResponse * (^)(id _Nullable interpretationValue, SAYStandardVoiceRequest *voiceRequest))successResponder
                        invalidResponder:(SAYVoiceRequestResponse * (^)(NSArray <SAYValidationError *> * validationErrors, SAYStandardVoiceRequest *voiceRequest))invalidResponder
                           failureAction:(void (^)())failureAction;

@property (nonatomic, copy, nullable) void (^userAction)(id _Nullable);

@property (nonatomic, copy, nullable) SAYVoiceRequestResponse * (^successResponder)(id _Nullable interpretationValue, SAYStandardVoiceRequest *voiceRequest);
@property (nonatomic, copy, nullable) SAYVoiceRequestResponse * (^invalidResponder)(NSArray <SAYValidationError *> *validationErrors, SAYStandardVoiceRequest *voiceRequest);
@property (nonatomic, copy, nullable) void (^failureAction)(SAYStandardVoiceRequest *);

@property (nonatomic) NSInteger supportedRetryCount;   // default to 1?
@property (nonatomic, copy, nullable) NSString *repromptMessageText;

@end

NS_ASSUME_NONNULL_END
