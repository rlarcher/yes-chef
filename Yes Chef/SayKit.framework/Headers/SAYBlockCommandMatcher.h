//
//  SAYBlockCommandTranslator.h
//  SayKit
//
//  Created by Greg Nicholas on 1/5/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAYTextCommandMatcher.h"

@class SAYCommandSuggestion;

NS_ASSUME_NONNULL_BEGIN

/// Type describing a function that maps a string to a collection of commands
typedef SAYCommandSuggestion * _Nullable (^SAYCommandMatchBlock)(NSString *);

@interface SAYBlockCommandMatcher : NSObject <SAYTextCommandMatcher>

- (instancetype)initWithBlock:(SAYCommandMatchBlock)block;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
