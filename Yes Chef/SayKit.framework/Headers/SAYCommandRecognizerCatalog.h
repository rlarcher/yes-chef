//
//  SAYCommandRecognizerCatalog.h
//  SayKit
//
//  Created by Adam Larsen on 1/22/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SAYVerbalCommandRegistry.h"

@interface SAYCommandRecognizerCatalog : NSObject <SAYVerbalCommandRegistry>

@property (nonatomic, readonly) NSArray <SAYVerbalCommandRecognizer *> *commandRecognizers;

- (void)addCommandRecognizer:(SAYVerbalCommandRecognizer *)commandRecognizer;
- (void)removeCommandRecognizer:(SAYVerbalCommandRecognizer *)commandRecognizer;

- (void)clearCommandRecognizers;

@end
