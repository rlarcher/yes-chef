//
//  SAYNumericalRequest.h
//  SayKit
//
//  Created by Adam Larsen on 2015/10/28.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAYStandardVoiceRequest.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Describes a voice request used to receive speech input that contains numerical content.
 */
@interface SAYNumericalRequest : SAYStandardVoiceRequest

- (instancetype)initWithPromptText:(NSString *)promptText action:(void (^)(NSNumber * _Nullable))action;

@end

NS_ASSUME_NONNULL_END
