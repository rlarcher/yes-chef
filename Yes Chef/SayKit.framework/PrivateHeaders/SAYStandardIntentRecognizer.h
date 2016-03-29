//
//  SAYStandardIntentRecognizer.h
//  SayKit
//
//  Created by Greg Nicholas on 12/29/15.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAYSpeechRecognitionService.h"

@class LuisResult;

NS_ASSUME_NONNULL_BEGIN

@interface SAYStandardIntentRecognizer : NSObject <SAYSpeechRecognitionService>

@property (nonatomic, copy, readonly) NSArray<NSString *> *apiKeyNames;

@property (nonatomic, weak, nullable) id<SAYSpeechRecognitionServiceDelegate> delegate;

- (instancetype)initWithLuisKeyName:(NSString *)keyName;
- (instancetype)initWithLuisKeyNames:(NSArray<NSString *> *)keyNames NS_DESIGNATED_INITIALIZER;

@end

FOUNDATION_EXPORT NSString * const SAYStandardIntentRecognizerErrorDomain;

typedef NS_ENUM(NSUInteger, SAYStandardIntentRecognizerErrorCode) {
    SAYStandardIntentRecognizerErrorSpeechRecognitionFailure = 1,
    SAYStandardIntentRecognizerErrorUnknown,
};

NS_ASSUME_NONNULL_END
