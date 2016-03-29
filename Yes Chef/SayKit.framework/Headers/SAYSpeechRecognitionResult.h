//
//  SAYSpeechRecognitionResult.h
//  SayKit
//
//  Created by Greg Nicholas on 12/16/15.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SAYSpeechRecognitionResult <NSObject>

/**
 *  A string of recognized speech
 */
@property (nonatomic, copy, readonly) NSString *transcript;

@end

NS_ASSUME_NONNULL_END
