//
//  SAYCommandBarDelegate.h
//  SayKit
//
//  Created by Greg Nicholas on 11/3/15.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SAYCommandBar;

/**
 *  Describes methods for classes that intend to respond to `SAYCommanddBar` controls.
 */
@protocol SAYCommandBarDelegate <NSObject>

/**
 *  Called when the user taps on the microphone button
 *
 *  @param commandBar Bar containing microphone that was selected
 */
- (void)commandBarDidSelectMicrophone:(SAYCommandBar *)commandBar;

/**
 *  Called when the user taps on the command menu button
 *
 *  @param commandBar Bar containing microphone that was selected
 */
- (void)commandBarDidSelectCommandMenu:(SAYCommandBar *)commandBar;

@end
