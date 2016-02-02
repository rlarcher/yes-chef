//
//  SAYVerbalCommandRecognizer.h
//  SayKit
//
//  Created by Greg Nicholas on 1/11/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SAYVoiceRequestResponse;
@protocol SAYTextCommandMatcher;
@class SAYCommand;
@class SAYCommandMenuItem;

NS_ASSUME_NONNULL_BEGIN

typedef void (^SAYCommandActionBlock)(SAYCommand *);
typedef SAYVoiceRequestResponse * _Nonnull (^SAYVerbalCommandResponseBuilder)(SAYCommand *);

@interface SAYVerbalCommandRecognizer : NSObject

// set at class-level
@property (nonatomic, strong, readonly) NSString *commandType;
@property (nonatomic, strong, readonly) NSArray <id<SAYTextCommandMatcher>> *textMatchers;

// configured from initialization arguments
@property (nonatomic, copy, readonly) SAYVerbalCommandResponseBuilder responseBuilder;

// managed via calls to add/removeMenuItem
@property (nonatomic, copy, readonly) NSArray<SAYCommandMenuItem *> *menuItems;

- (instancetype)initWithResponseBuilder:(SAYVerbalCommandResponseBuilder)responseBuilder NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithActionBlock:(SAYCommandActionBlock)actionBlock;

// Convenience factory for Cocoa Touch-like target/action interface. This target/action is used in the responseBuilder.
// Supported action selector signatures come in two flavors, which determine the behavior of the response builder.
// 1. Basic command handling:
// -(void)handleCommand
// -(void)handleCommand:(SAYCommand *)command
// Internally, the target/action will be used to create a block that builds a terminal response with this selector as the action
//
// 2. Command responding
// -(SAYVerbalCommandResponse *)respondToCommand
// -(SAYVerbalCommandResponse *)respondToCommand:(SAYCommand *)command
// Internally, the response builder will just be a block-wrapped call of the target/action
- (instancetype)initWithResponseTarget:(nullable id)target action:(nullable SEL)action;

- (instancetype)init NS_UNAVAILABLE;

- (void)addTextMatcher:(id<SAYTextCommandMatcher>)textMatcher;
- (void)removeTextMatcher:(id<SAYTextCommandMatcher>)textMatcher;

- (void)addMenuItemWithLabel:(NSString *)label parameters:(NSDictionary<NSString *, NSString *> *)parameters;
- (void)removeMenuItemWithLabel:(NSString *)label;

@end

NS_ASSUME_NONNULL_END
