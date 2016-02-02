//
//  SAYTextCommandMatcher.h
//  SayKit
//
//  Created by Greg Nicholas on 1/5/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SAYCommandSuggestion;

@protocol SAYTextCommandMatcher <NSObject>

- (nullable SAYCommandSuggestion *)attemptMatch:(nonnull NSString *)text;

@end
