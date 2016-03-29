//
//  SAYSpeechIntent.h
//  SayKit
//
//  Created by Greg Nicholas on 10/14/15.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Represents a loosely structured intent suggestion returned from an external service.
 */
@interface SAYSpeechIntent : NSObject

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) NSDictionary *entities;
@property (nonatomic, assign, readonly) float confidence;
@property (nonatomic, copy, readonly, nullable) NSString *rawText;

+ (SAYSpeechIntent *)intentWithIdentifier:(NSString *)identifier
                                entities:(NSDictionary *)entities
                              confidence:(float)confidence
                                 rawText:(nullable NSString *)rawText;

- (instancetype)initWithIdentifier:(NSString *)identifier
                          entities:(NSDictionary *)entities
                        confidence:(float)confidence
                           rawText:(nullable NSString *)rawText NS_DESIGNATED_INITIALIZER;

/// @abstract Not supported. Use designated initialize for this class instead.
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
