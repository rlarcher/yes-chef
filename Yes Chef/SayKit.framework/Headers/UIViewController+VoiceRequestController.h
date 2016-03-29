//
//  UIViewController+VoiceRequestController.h
//  SayKit
//
//  Created by Greg Nicholas on 12/16/15.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SAYVoiceRequestController;

@interface UIViewController (VoiceRequestController)

@property (nonatomic, weak, readonly, nullable) SAYVoiceRequestController *parentVoiceRequestController;

@end
