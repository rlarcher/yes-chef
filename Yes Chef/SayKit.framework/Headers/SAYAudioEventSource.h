//
//  SAYAudioEventSource.h
//  SayKit
//
//  Created by Greg Nicholas on 1/17/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SAYAudioEvent;
@protocol SAYAudioEventListener;
@class SAYAudioEventSequence;

NS_ASSUME_NONNULL_BEGIN

@protocol SAYAudioEventSource <NSObject>

- (nullable SAYAudioEventSequence *)lastPostedEvents;

- (void)addListener:(id<SAYAudioEventListener>)listener;
- (void)removeListener:(id<SAYAudioEventListener>)listener;
                   
@end

NS_ASSUME_NONNULL_END
