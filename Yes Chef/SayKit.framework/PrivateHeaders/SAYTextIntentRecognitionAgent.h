//
//  SAYTextIntentRecognitionManager.h
//  SayKit
//
//  Created by Adam Larsen on 2015/11/12.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPRequestOperation;
@class LuisResult;

NS_ASSUME_NONNULL_BEGIN

@class SAYTextIntentRecognitionOperation;

@interface SAYTextIntentRecognitionAgent : NSObject

@property (nonatomic, copy) NSArray<NSString *> *luisKeyNames;

- (instancetype)initWithLuisKeyNames:(NSArray<NSString *> *)luisKeyNames;

- (SAYTextIntentRecognitionOperation *)sendQuery:(NSString *)text
                                         success:(nullable void (^)(LuisResult *))success
                                         failure:(nullable void (^)(NSError *))failure;

@end

@interface SAYTextIntentRecognitionOperation : NSOperation

@property (nonatomic, copy, readonly) NSArray<AFHTTPRequestOperation *> *components;

// "output" values
@property (nonatomic, copy, nullable) LuisResult *result;
@property (nonatomic, copy, nullable) NSError *error;   // will be of SAYTextIntentRecognitionErrorCode type

- (SAYTextIntentRecognitionOperation *)initWithComponents:(NSArray<AFHTTPRequestOperation *> *)components
                                                  success:(nullable void (^)(LuisResult *))success
                                                  failure:(nullable void (^)(NSError *))failure;

@end

typedef NS_ENUM(NSUInteger, SAYTextIntentRecognitionErrorCode) {
    SAYTextIntentRecognitionErrorUnexpectedResponse,
    SAYTextIntentRecognitionErrorNetworking,
    SAYTextIntentRecognitionErrorCancelled,
    SAYTextIntentRecognitionErrorUnknown,
};

FOUNDATION_EXPORT NSString * const SAYTextIntentRecognitionErrorDomain;


NS_ASSUME_NONNULL_END
