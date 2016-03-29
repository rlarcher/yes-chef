//
//  SAYCommandBarController.h
//  SayKit
//
//  Created by Greg Nicholas on 11/3/15.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SAYCommandBarDelegate.h"

@class SAYCommandBar;
@class SAYConversationManager;

NS_ASSUME_NONNULL_BEGIN

/**
 *  The `SAYCommandBarController` connects a `SAYCommandBar` with the SayKit systems needed to perform a voice command request. Like a `UITabBarController` it is a container view controller intended to have content embedded inside it.
 */
@interface SAYCommandBarController : UIViewController <SAYCommandBarDelegate>

/**
 *  The command bar displayed
 */
@property (nonatomic, strong) SAYCommandBar *commandBar;

/**
 *  The conversation manager to handle the execution of user requests
 */
@property (nonatomic, strong) SAYConversationManager *conversationManager;

/**
 *  The content view controller embedded in the frame above the command bar. 
 
    @warning Use this to manage the single `SAYCommandBarController` child controller, not `addChildViewController:` and `removeChildViewController:`.
 */
@property (nonatomic, strong, nullable) UIViewController *contentViewController;

@end

NS_ASSUME_NONNULL_END