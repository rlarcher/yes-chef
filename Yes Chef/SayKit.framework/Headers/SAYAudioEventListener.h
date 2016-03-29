//
//  SAYAudioEventListener.h
//  SayKit
//
//  Created by Greg Nicholas on 1/17/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAYAudioEventSource.h"

@protocol SAYAudioEvent;

NS_ASSUME_NONNULL_BEGIN

@protocol SAYAudioEventListener <NSObject>

- (void)eventSource:(id<SAYAudioEventSource>)source didPostEventSequence:(SAYAudioEventSequence *)sequence;

@end

NS_ASSUME_NONNULL_END
