//
//  SAYVerbalCommandRegistry.h
//  SayKit
//
//  Created by Greg Nicholas on 1/12/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SAYVerbalCommandRecognizer;

NS_ASSUME_NONNULL_BEGIN

@protocol SAYVerbalCommandRegistry <NSObject>

@property (nonatomic, readonly) NSArray<SAYVerbalCommandRecognizer *> *commandRecognizers;

@end

NS_ASSUME_NONNULL_END
