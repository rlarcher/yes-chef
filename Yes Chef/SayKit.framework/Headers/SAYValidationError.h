//
//  SAYValidationError.h
//  SayKit
//
//  Created by Greg Nicholas on 12/29/15.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  A `SAYValidationError` is a simple value type used to represent interpretation issues, typically due to user speech not an intent the interpreter can discern.
 */
@interface SAYValidationError : NSObject

@property (nonatomic, copy, readonly) NSString *type;
@property (nonatomic, copy, readonly, nullable) NSString *reason;

+ (instancetype)errorWithType:(NSString *)type reason:(nullable NSString *)reason;
- (instancetype)initWithType:(NSString *)type reason:(nullable NSString *)reason NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

// Errors common to all requests
FOUNDATION_EXPORT NSString * const SAYValidationErrorTypeInvalidInput;
FOUNDATION_EXPORT NSString * const SAYValidationErrorTypeNoInput;

NS_ASSUME_NONNULL_END
