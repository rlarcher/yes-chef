//
//  SAYAudioSequenceGenerator.h
//  SayKit
//
//  Created by Greg Nicholas on 2/25/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SAYAudioEventSource.h"

/**
 *  Basic conformer to the `SAYAudioEventSource` protocol, offering a method to directly post an audio sequence to all listeners.
 */
@interface SAYAudioSequenceGenerator : NSObject <SAYAudioEventSource>

/**
 *  Post the given sequence to all subscribed listeners. This method simply iterates through the listeners and sends the `eventSource:didPostEventSequence:` message to each one in turn.
 *
 *  @param sequence Sequence to be posted
 */
- (void)postSequence:(SAYAudioEventSequence *)sequence;

@end
