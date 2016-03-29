//
//  SAYAPIKeyManager.h
//  SayKit
//
//  Created by Adam Larsen on 2016/01/05.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Class that handles the fetching, storage, and querying of API keys required by the recognition services.
@interface SAYAPIKeyManager : NSObject

+ (SAYAPIKeyManager *)sharedInstance;

/**
 *  Tells the manager to load the API keys into memory from the server (if available) or local storage (if unable to connect to the server). Should be called near the launch of an app to avoid unnecessary delay on the first speech request.
 */
- (void)prefetchAPIKeys;

/**
 *  Synchronously returns the map of keyIds corresponding to the given keyNames.
 *
 *  @param keyNames An array of key names. Valid values include `SAYWitKeyStandardASRToken`, `SAYLuisKeySubscriptionToken`, or the series of `SAYLuisKey...`.
 *  @param error A writeable error.
 *  @return  An array of key ids corresponding to the given keyNames.
 */
- (NSArray<NSString *> * _Nullable)keyIdsForKeyNames:(NSArray<NSString *> *)keyNames error:(NSError *__autoreleasing *)error;

@end

typedef NS_ENUM(NSUInteger, SAYAPIKeyManagerErrorCode) {
    kSAYAPIKeyManagerErrorCodeProblemInitializingKeyCache,
    kSAYAPIKeyManagerErrorCodeKeyNotFound
};

FOUNDATION_EXPORT NSString * const SAYAPIKeyManagerErrorDomain;

NS_ASSUME_NONNULL_END
