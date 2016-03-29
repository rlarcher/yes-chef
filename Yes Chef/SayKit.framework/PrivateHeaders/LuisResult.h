//
//  LuisResult.h
//  SayKit
//
//  Created by Adam Larsen on 2015/10/16.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAYSpeechRecognitionResult.h"

@class SAYSpeechIntent;

NS_ASSUME_NONNULL_BEGIN

@interface LuisResult : NSObject <SAYSpeechRecognitionResult, NSCopying>

@property (nonatomic, copy, readonly) NSString *transcript;
@property (nonatomic, copy, readonly) NSArray<SAYSpeechIntent *> *intents;
@property (nonatomic, copy, readonly) NSDictionary *entities;

- (instancetype)initWithTranscript:(NSString *)transcript intents:(NSArray<SAYSpeechIntent *> *)intents entities:(NSDictionary *)entities;

- (LuisResult * __nullable)mergeWithResult:(LuisResult * __nullable)other error:(NSError * __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
