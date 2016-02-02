//
//  SAYCustomCommandRecognizer.h
//  SayKit
//
//  Created by Greg Nicholas on 1/14/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SAYVerbalCommandRecognizer.h"

NS_ASSUME_NONNULL_BEGIN

@interface SAYCustomCommandRecognizer : SAYVerbalCommandRecognizer

- (instancetype)initWithCustomType:(NSString *)commandType responseBuilder:(SAYVerbalCommandResponseBuilder)responseBuilder NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCustomType:(NSString *)commandType responseTarget:(nullable id)target action:(nullable SEL)action;

- (instancetype)initWithCustomType:(NSString *)commandType actionBlock:(SAYCommandActionBlock)actionBlock;

@end

NS_ASSUME_NONNULL_END
