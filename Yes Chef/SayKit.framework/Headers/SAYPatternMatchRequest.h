//
//  SAYPatternMatchRequest.h
//  SayKit
//
//  Created by Adam Larsen on 2015/10/29.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAYStandardVoiceRequest.h"

@class SAYPatternMatch;

NS_ASSUME_NONNULL_BEGIN

/**
 *  The `SAYPatternMatchRequest` describes a voice request for speech matching a particular string pattern. If user speech does not conform to the prescribed patterns provided, the user will be prompted to try again.
 */
@interface SAYPatternMatchRequest : SAYStandardVoiceRequest

/**
 *  Array of templates. User speech must match one of these patterns to be accepted.
 *
 *  TODO: add a reference to docs for pattern syntax
 */
@property (nonatomic, copy) NSArray<NSString *> *templates;

- (instancetype)initWithTemplates:(NSArray<NSString *> *)templates
                           prompt:(SAYVoicePrompt *)prompt
                        responder:(SAYStandardRequestResponder *)responder NS_DESIGNATED_INITIALIZER;

/**
 *  Create a new `SAYPatternMatchRequest` with the given templates
 *
 *  @param templates       An array of templates to use in parsing the recognized text
 *  @param promptText      Message to present to the user when the prompt begins
 *  @param action          Block to deliver result to
 *
 * Entities in each template must be defined according to the following examples:
 *      "Call @recipient:String."
 *      "Ask @nameOfFriend for @cookieCount:Number cookies."
 *       "@payer gave @payee @amount:Number dollars."
 *       "@payee received @amount:Number dollars from @payer."
 *       In general, the syntax of an entity is "@entityName:EntityType", where EntityType can be either "String" or "Number". If ":EntityType" is omitted, the parser assumes the Entity is a string.
 */
- (instancetype)initWithTemplates:(NSArray<NSString *> *)templates
                       promptText:(NSString *)promptText
                           action:(void (^)(SAYPatternMatch * __nullable))action;

@end

NS_ASSUME_NONNULL_END
