//
//  SAYCommandResolutionOperation.h
//  SayKit
//
//  Created by Greg Nicholas on 1/12/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SAYVerbalCommandRecognizer;
@class SAYCommandSuggestion;

NS_ASSUME_NONNULL_BEGIN

@interface SAYCommandRecognizerOperation : NSOperation

@property (nonatomic, strong, readonly) SAYVerbalCommandRecognizer *sourceRecognizer;

@property (nonatomic, strong, nullable) SAYCommandSuggestion *suggestion;

- (instancetype)initWithSourceRecognizer:(SAYVerbalCommandRecognizer *)sourceRecognizer;

@end

NS_ASSUME_NONNULL_END
