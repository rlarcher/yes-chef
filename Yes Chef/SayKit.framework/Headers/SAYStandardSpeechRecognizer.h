//
//  SAYStandardSpeechRecognizer.h
//  SayKit
//
//  Created by Greg Nicholas on 12/18/15.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAYSpeechRecognitionService.h"

NS_ASSUME_NONNULL_BEGIN

@interface SAYStandardSpeechRecognizer : NSObject <SAYSpeechRecognitionService>

@property (nonatomic, weak, nullable) id<SAYSpeechRecognitionServiceDelegate> delegate;

+ (SAYStandardSpeechRecognizer *)sharedRecognizer;

@end

FOUNDATION_EXPORT NSString * const SAYStandardSpeechRecognizerErrorDomain;

typedef NS_ENUM(NSUInteger, SAYStandardSpeechRecognizerErrorCode) {
    SAYStandardSpeechRecognizerErrorNoContent = 1,
    SAYStandardSpeechRecognizerErrorResponseTimeout,
    SAYStandardSpeechRecognizerErrorUnauthorized,
    SAYStandardSpeechRecognizerErrorServerFailure,
    SAYStandardSpeechRecognizerErrorUnknown,
    SAYStandardSpeechRecognizerErrorAuthorizationKeyUnavailable
};

NS_ASSUME_NONNULL_END