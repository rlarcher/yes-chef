//
//  SAYStringRequest.h
//  SayKit
//
//  Created by Adam Larsen on 2015/11/03.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAYStandardVoiceRequest.h"

@class SAYStringResult;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Describes a voice request used to receive arbitrary speech input. The recognized speech transcript is delivered directly with no additional interpretation.
 */
@interface SAYStringRequest : SAYStandardVoiceRequest

- (instancetype)initWithPromptText:(NSString *)promptText action:(void (^)(NSString * _Nullable))action;

@end

NS_ASSUME_NONNULL_END
