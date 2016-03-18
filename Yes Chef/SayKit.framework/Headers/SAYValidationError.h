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
 *  A `SAYValidationError` is a simple value type used to represent interpretation issues, typically due to user speech content having a problem that prevents the interpreter from discerning a value from it.
 */
@interface SAYValidationError : NSObject

/**
 *  The error "type". Typically a known string constant value that allows an interpreter to communicate the nature of the problem with a responder.
 */
@property (nonatomic, copy, readonly) NSString *type;

/**
 *  A freeform description string useful to provide more information about the validation problem. Analagous to the "NSLocalizedDescription" in the `NSError` paradigm.
 */
@property (nonatomic, copy, readonly, nullable) NSString *reason;

/**
 *  Factory method to creaete a new error.
 *
 *  @param type   Basic error type
 *  @param reason More detailed reason for error
 *
 *  @return The new `SAYValidationError` instance
 */
+ (instancetype)errorWithType:(NSString *)type reason:(nullable NSString *)reason;

/**
 *  Initializes a new error
 *
 *  @param type   Basic error type
 *  @param reason More detailed reason for error
 *
 *  @return A newly initialized validation error
 */
- (instancetype)initWithType:(NSString *)type reason:(nullable NSString *)reason NS_DESIGNATED_INITIALIZER;

/// Unsupported. Use either the factory method or designated initializer.
- (instancetype)init NS_UNAVAILABLE;

@end

/**
 *  Generic error type used when the speeech content is discernable, but makes no sense in the given interpretation context (e.g. the speech "peanut butter" for an interpreter looking for a "yes"/"no"-type response)
 */
FOUNDATION_EXPORT NSString * const SAYValidationErrorTypeInvalidInput;

/**
 *  Generic error type used when no speech content was available for interpretation.
 */
FOUNDATION_EXPORT NSString * const SAYValidationErrorTypeNoInput;

NS_ASSUME_NONNULL_END
