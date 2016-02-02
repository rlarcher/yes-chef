//
//  SAYConfirmationRequest.h
//  SayKit
//
//  Created by Adam Larsen on 2015/10/20.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAYStandardVoiceRequest.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Describes a voice request used to receive yes-or-no messages from the user. The request attempts to reduce recognized speech to boolean values.
 */
@interface SAYConfirmationRequest : SAYStandardVoiceRequest

/**
 *  Initializes new request
 *
 *  @param promptText      Message to present to the user when the prompt begins
 *  @param action          Block to take action on result (result is NSNumber-wrapped BOOL)
 *
 *  @return The newly-initialized `SAYConfirmationRequest`
 */
- (instancetype)initWithPromptText:(NSString *)promptText action:(void (^)(NSNumber * _Nullable))action;

@end

NS_ASSUME_NONNULL_END
