//
//  SAYVerbalCommandRecognizer+Private.h
//  SayKit
//
//  Created by Greg Nicholas on 1/13/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

#import "SAYVerbalCommandRecognizer.h"

@class SAYCommandRecognizerOperation;

@interface SAYVerbalCommandRecognizer (Private)

+ (SAYVerbalCommandResponseBuilder)wrapTarget:(id)target action:(SEL)selector;
+ (SAYVerbalCommandResponseBuilder)wrapActionBlock:(SAYCommandActionBlock)block;

- (NSArray <SAYCommandRecognizerOperation *> *)operationsForInputText:(NSString *)text;

@end

