//
//  SAYSelectOption.h
//  SayKit
//
//  Created by Adam Larsen on 2015/11/30.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  A `SAYSelectOption` represents an option presented to the user during a `SAYSelectRequest` request. Options are represented primarily with string labels, but they can have associated aliases.
 */
@interface SAYSelectOption : NSObject

/**
 *  Primary label for the option. This label will be used when attempting to interpret user speech.
 */
@property (nonatomic, copy, readonly) NSString *label;

/**
 *  Set of aliases for the option. These can be used to make language interpretation more robust by giving alternative strings to match recognized speech to.
 */
@property (nonatomic, copy) NSArray<NSString *> *aliases;

/**
 *  Convenience factory initializer for an option with no aliases
 *
 *  @param label Option label
 *
 *  @return A new `SAYSelectOption` with the given label set
 */
+ (instancetype)optionWithLabel:(NSString *)label;

/**
 *  Initialzes a `SAYSelectOption` with the given primary label and aliases.
 *
 *  @param label   Option label
 *  @param aliases Alternative labels for the option
 *
 *  @return The newly-initialized `SAYSelectOption`
 */
- (instancetype)initWithLabel:(NSString *)label aliases:(NSArray<NSString *> *)aliases NS_DESIGNATED_INITIALIZER;

// Use initWithLabel:aliases: instead
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
