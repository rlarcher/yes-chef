//
//  SAYAudioFocusManagement.h
//  SayKit
//
//  Created by Greg Nicholas on 7/1/15.
//  Copyright (c) 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SAYManagedSynthesizer;
@protocol SAYAudioFocusGuard;
@protocol SAYAudioFocusRequester;

NS_ASSUME_NONNULL_BEGIN

// TODO: revisit naming here. yield/revoke doesn't feel quite right given how we're using them and the contract they guarantee. do we even need these protocols? they only have one implementer.
// TODO: sohuld we make these protocols internal?

/**
 *  The `SAYAudioFocusRequester` protocol describes a class that wants to receive the right to present its audio information (i.e. an audio track).
 */
@protocol SAYAudioFocusRequester <NSObject>

/**
 *  Guard is granting audio focus. This means the requester is free to use the focus immediately.
 *
 *  @param focusGuard Guard granting focus
 */
- (void)focusGuardGrantsFocus:(id<SAYAudioFocusGuard>)focusGuard;

/**
 *  Guard is revoking audio focus. It is the responsibility of the requester to immediately release focus upon receiving this call.
 *
 *  Note that unless the request has yielded focus, the guard guarantees to grant focus once again as soon as possible.
 *
 *  @param focusGuard Guard granting focus
 */
- (void)focusGuardRevokesFocus:(id<SAYAudioFocusGuard>)focusGuard;

/**
 *  Inherent priority of the requester
 */
@property (nonatomic, assign, readonly) unsigned int priority;

@end

/**
 *  The `SAYAudioFocusGuard` protocol describes a class that ensures only one `SAYFocusRequester` is given focus at a time.
 */
@protocol SAYAudioFocusGuard <NSObject>

@property (nonatomic, readonly) SAYManagedSynthesizer * managedSynth;

/**
 *  Caller is requesting audio focus. It is the responsibility of the receiver to call `focusGuardGrantsFocus:` on the caller as soon as possible (i.e. once all higher priority requesters have yielded their focus).
 *
 *   The guard reserves the right to retain a reference to any object that makes a request to it.
 *
 *  @param requester Agent requesting focus
 */
- (void)focusRequesterRequestsFocus:(id<SAYAudioFocusRequester>)requester;

/**
 *  Request no longer needs audio focus. Note that it is still the responsiblity of the receiver to call `focusGuardRevokesFocus:` in response to this message. As a result, it is safe for the requester to only internally release focus upon receiving a revoke message.
 *
 *  @param requester Agent requesting focus
 */
- (void)focusRequesterYieldsFocus:(id<SAYAudioFocusRequester>)requester;

@end

NS_ASSUME_NONNULL_END
