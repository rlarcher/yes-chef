//
//  SAYCommandMenuItem.h
//  SayKit
//
//  Created by Adam Larsen on 2016/01/20.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SAYCommand;
@class SAYVerbalCommandRecognizer;

NS_ASSUME_NONNULL_BEGIN

@interface SAYCommandMenuItem : NSObject

@property (nonatomic, copy, readonly) NSString *label;
@property (nonatomic, strong, readonly) SAYCommand *command;
@property (nonatomic, strong, readonly) SAYVerbalCommandRecognizer *recognizer;

+ (instancetype)menuItemWithLabel:(NSString *)label command:(SAYCommand *)command recognizer:(SAYVerbalCommandRecognizer *)recognizer;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
