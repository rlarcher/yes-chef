//
//  SAYVerbalCommandRegistry.h
//  SayKit
//
//  Created by Greg Nicholas on 1/12/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SAYVerbalCommandRecognizer;
@class SAYCommandMenuItem;

NS_ASSUME_NONNULL_BEGIN

@protocol SAYVerbalCommandRegistry <NSObject>

@property (nonatomic, readonly) NSArray<SAYVerbalCommandRecognizer *> *commandRecognizers;
@property (nonatomic, readonly) NSArray<SAYCommandMenuItem *> *menuItems;

@end

NS_ASSUME_NONNULL_END
