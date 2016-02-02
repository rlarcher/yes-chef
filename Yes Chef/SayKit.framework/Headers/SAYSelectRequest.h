//
//  SAYSelectRequest.h
//  SayKit
//
//  Created by Adam Larsen on 2015/10/27.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAYStandardVoiceRequest.h"

@class SAYSelectOption;
@class SAYSelectResult;
@class SAYStandardRequestResponder;

NS_ASSUME_NONNULL_BEGIN

/**
 *  This request prompts the a user to make a choice between a pre-defined list of options. It includes an optional visual component to allow the user to tap an option directly.
 */
@interface SAYSelectRequest : SAYStandardVoiceRequest

/**
 *  Array of options the user must choose between
 */
@property (nonatomic, copy) NSArray<SAYSelectOption *> *options;

/**
 *  Convenience initializer to create a new request with basic string options (i.e. no aliases)
 *
 *  @param itemLabels      String values for the user to choose
 *  @param promptText      Message to present to the user when the prompt begins
 *  @param completionBlock Block to deliver result to
 *
 *  @return The newly-initialized `SAYSelectResult`
 */
- (instancetype)initWithItemLabels:(NSArray<NSString *> *)itemLabels
                        promptText:(NSString *)promptText
                            action:(void (^)(SAYSelectResult * __nullable))action;

/**
 *  Initializes new request with full options
 *
 *  @param options         String values for the user to choose
 *  @param promptText      Message to present to the user when the prompt begins
 *  @param completionBlock Block to deliver result to
 *
 *  @return The newly-initialized `SAYSelectRequest`
 */
- (instancetype)initWithOptions:(NSArray<SAYSelectOption *> *)options
                     promptText:(NSString *)promptText
                         action:(void (^)(SAYSelectResult * __nullable))action;


- (instancetype)initWithOptions:(NSArray<SAYSelectOption *> *)options
                         prompt:(SAYVoicePrompt *)prompt
                      responder:(SAYStandardRequestResponder *)responder;


@end

NS_ASSUME_NONNULL_END
