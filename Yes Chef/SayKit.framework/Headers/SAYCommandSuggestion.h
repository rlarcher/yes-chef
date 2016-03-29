//
//  SAYCommandSuggestion.h
//  SayKit
//
//  Created by Greg Nicholas on 1/12/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// TODO: better name? ResolveCommand? Match? something else? It's not a full command, just a suggested form of one

FOUNDATION_EXPORT const float kSAYCommandConfidenceNone;
FOUNDATION_EXPORT const float kSAYCommandConfidenceVeryUnlikely;
FOUNDATION_EXPORT const float kSAYCommandConfidenceUnlikely;
FOUNDATION_EXPORT const float kSAYCommandConfidenceLikely;
FOUNDATION_EXPORT const float kSAYCommandConfidenceVeryLikely;
FOUNDATION_EXPORT const float kSAYCommandConfidenceCertain;

@interface SAYCommandSuggestion : NSObject

@property (nonatomic, readonly) float confidence;
@property (nonatomic, copy, readonly, nullable) NSDictionary <NSString *, id> *parameters;

+ (instancetype)suggestionWithConfidence:(float)confidence;
+ (instancetype)suggestionWithConfidence:(float)confidence parameters:(nullable NSDictionary <NSString *, id> *)parameters;

- (instancetype)initWithConfidence:(float)confidence;
- (instancetype)initWithConfidence:(float)confidence parameters:(nullable NSDictionary <NSString *, id> *)parameters NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
