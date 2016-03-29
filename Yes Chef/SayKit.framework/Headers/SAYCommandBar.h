//
//  SAYCommandBar.h
//  SayKit
//
//  Created by Greg Nicholas on 11/3/15.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SAYCommandBarDelegate;

/**
 *  The `SAYCommandBar` offers a visual interface for interacting with SayKit's verbal command processing capabilities. It gives a user the ability to initiate a `VerbalCommandRequest` and a way to display all available commands in the current command context.
 */
@interface SAYCommandBar : UIView

/**
 *  Delegate instance to handle UI control events.
 */
@property (nonatomic, weak) id<SAYCommandBarDelegate> delegate;

@property (nonatomic, assign) BOOL commandsMenuEnabled;

/**
 *  Button to start a voice command session
 */
@property (nonatomic, strong, readonly) UIButton *microphoneButton;

/**
 *  Button to display a menu of available commands
 */
@property (nonatomic, strong, readonly) UIButton *commandsMenuButton;

@end

NS_ASSUME_NONNULL_END