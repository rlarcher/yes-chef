//
//  SAYInterpretation.h
//  SayKit
//
//  Created by Greg Nicholas on 12/23/15.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SAYValidationError;

NS_ASSUME_NONNULL_BEGIN

/**
 *  The `SAYIntepretation` class is value type, containing either the result of a voice request interpretation, or a set of validation errors that prevented such an interpretation.
 */
@interface SAYInterpretation : NSObject

/**
 *  Underlying interpretted value.
 *
 *  Convention is to set this to nil when a validation error has occured, but nil can also be used to represent a "valid" absence of value as well.
 */
@property (nonatomic, strong, readonly, nullable) id value;

/**
 *  Any validation errors that prevented a value from being interpreted.
 */
@property (nonatomic, copy, readonly) NSArray <SAYValidationError *> *validationErrors;

/**
 *  Whether or not the value was interpreted without any validation errors. Shortcut for checking if the validation error collection is empty.
 */
@property (nonatomic, readonly) BOOL isValid;

/**
 *  Factory initializer for an interpretation containing a value and no validation errors.
 *
 *  @param value Intepreted value
 *
 *  @return A new interpretation with the given value.
 */
+ (instancetype)interpretationWithValue:(nullable id)value;

/**
 *  Factory initializer for an interpretation containing validation errors and no value.
 *
 *  @param validationErrors List of errors encountered that prevented a value from being interpreted
 *
 *  @return A new interpretation with the given validation errors
 */
+ (instancetype)interpretationWithErrors:(NSArray<SAYValidationError *> *)validationErrors;

/**
 *  Initializes a new interpretation. Typically, at least one of the parameters are nil.
 *
 *  @param value            Interpretated value
 *  @param validationErrors List of validation errors (which typically prevented a value from being interpreted)
 *
 *  @return A new interpretation
 */
- (instancetype)initWithValue:(nullable id)value validationErrors:(NSArray<SAYValidationError *> *)validationErrors NS_DESIGNATED_INITIALIZER;

/// Unsupported. Use either a factory method or the designated initializer.
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
