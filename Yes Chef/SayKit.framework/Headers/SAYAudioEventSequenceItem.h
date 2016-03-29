//
//  SAYAudioEventSequenceItem.h
//  SayKit
//
//  Created by Greg Nicholas on 1/19/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SAYAudioEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface SAYAudioEventSequenceItem : NSObject

@property (nonatomic, strong, readonly) id<SAYAudioEvent> event;
@property (nonatomic, copy, nullable, readonly) SAYAudioEventCompletionBlock completionBlock;

+ (instancetype)itemWithEvent:(id<SAYAudioEvent>)event;
+ (instancetype)itemWithEvent:(id<SAYAudioEvent>)event completionBlock:(SAYAudioEventCompletionBlock)completionBlock;

- (instancetype)initWithEvent:(id<SAYAudioEvent>)event;
- (instancetype)initWithEvent:(id<SAYAudioEvent>)event completionBlock:(nullable SAYAudioEventCompletionBlock)completionBlock NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
