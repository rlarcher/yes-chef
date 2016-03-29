//
//  SAYOperationQueue.h
//  SayKit
//
//  Created by Greg Nicholas on 7/1/15.
//  Copyright (c) 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SAYOperationQueueDelegate;

@interface SAYOperationQueue : NSOperationQueue
@property (nonatomic, weak) id<SAYOperationQueueDelegate> __nullable delegate;
@end

@protocol SAYOperationQueueDelegate <NSObject>

- (void)operationQueue:(SAYOperationQueue *)queue didChangeOperationCount:(NSUInteger)count;

@end

NS_ASSUME_NONNULL_END
