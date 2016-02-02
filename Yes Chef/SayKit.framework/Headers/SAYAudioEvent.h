//
//  SAYAudioEvent.h
//  SayKit
//
//  Created by Greg Nicholas on 7/1/15.
//  Copyright (c) 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAYOperation.h"

// TODO: revisit concept of event copying. seems relevant with signal composition

NS_ASSUME_NONNULL_BEGIN

typedef SAYOperation SAYAudioOperation;

/**
 *  A `SAYAudioEvent` represents a piece of audible information to be conveyed to the user.
 */
@protocol SAYAudioEvent <NSObject>

/**
 *  A series of operations that contain the actual logic capable of presenting the event to the user.
 *
 *  @return Array of `SAYAudioOperation` instances
 */
- (NSArray <SAYAudioOperation *> *)operations;

@end

/**
 *  Alias for a simple execution block with no argument or return value. Used in this context as an action to execute after audio events complete.
 
    Note: this may be extended in future versions to include information about whether or not the related audio event completed or was cancelled.
 */
typedef void (^SAYAudioEventCompletionBlock)();

NS_ASSUME_NONNULL_END
