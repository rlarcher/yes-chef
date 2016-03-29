//
//  SAYVerbalCommandRequest.h
//  SayKit
//
//  Created by Greg Nicholas on 10/20/15.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SAYVoiceRequest.h"

@class SAYCommandDispatcher;
@protocol SAYVerbalCommandRegistry;

NS_ASSUME_NONNULL_BEGIN

/**
 *  The `SAYVerbalCommandRequest` is a `SAYVoiceRequest` tailored towards allowing users to speak commands. The recognized speech is sent into the SayKit command processing pipeline, being resolved as potenetial commands and then dispatched to the application.
 
    In the current version of SayKit, the speech recognizer underlying this command cannot be cusotmized.
 */
@interface SAYVerbalCommandRequest : NSObject <SAYVoiceRequest>

/**
 *  Initialize a new request backed by the given command registry
 *
 *  @param commandRegistry
 *
 *  @return The newly-initialized request
 */
- (instancetype)initWithCommandRegistry:(id<SAYVerbalCommandRegistry>)commandRegistry;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
