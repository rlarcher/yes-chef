//
//  SAYAudioEventSequence.h
//  SayKit
//
//  Created by Greg Nicholas on 1/19/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SAYAudioEvent.h"
@class SAYAudioEventSequenceItem;

@interface SAYAudioEventSequence : NSObject

- (void)addEvent:(id<SAYAudioEvent>)event;
- (void)addEvent:(id<SAYAudioEvent>)event withCompletionBlock:(SAYAudioEventCompletionBlock)completionBlock;

- (void)addEvents:(NSArray <id<SAYAudioEvent>> *)events;
- (void)addEvents:(NSArray <id<SAYAudioEvent>> *)events withCompletionBlock:(SAYAudioEventCompletionBlock)completionBlock;

- (void)appendSequence:(SAYAudioEventSequence *)sequence;

+ (instancetype)sequenceWithEvents:(NSArray <id<SAYAudioEvent>> *)events;

// returns an immutable copy of items created at the point it is called
- (NSArray <SAYAudioEventSequenceItem *> *)items;

@end
