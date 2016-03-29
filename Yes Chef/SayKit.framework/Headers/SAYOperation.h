//
//  SAYOperation.h
//  SayKit
//
//  Created by Greg Nicholas on 7/1/15.
//  Copyright (c) 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SAYOperationObserver;

/**
 *  An NSOperation-subclass that adds a suspended state to the typical NSOperation KVO states.

    A collaborator interested in the operation execution state should not need to observe KVO notifications. Instead, the collaborator should conform to SAYOperationObserver and register itself with the operation.
 
    In addition, SAYOperation was designed to abstract away the error-prone manual manipulation KVO state flags so that subclasses can be implemented with much less overhead. See "Subclassing Notes" for more details.
 
    ## Suspension
 
    SAYOperations support an additional boolean state flag, `isSuspended`. While this flag is modeled after the similar flags available in NSOperation, the NSOperationQueue knows nothing about it. Instead, the suspended state is a logical one in which subclasses can implement their own custom notion of suspended execution around. There is no requirement that prevents suspended operations from finishing without being resumed -- this is completely up to subclasses to implement.
 
    ## Subclassing Notes

    Subclasses should be able to avoid any manual manipulation of conventional NSOperation KVO state management. Instead, this state management is handled by a combination of SAYOperation's implementation of `start` & `cancel` methods and a special method defined to signal operation completion, `markFinished`.

    At the very least, most subclasses will only have two or three responsibilities:
        1. Override `execute` to kick off the operation's actual work
        2. Call `markFinished` on itself when work has completed
        3. Override `didCancel` to wind down execution as soon as possible, if applicable
 
    Additionally, subclasses may need to react to suspension, resumption, cancellation, and finish events. This logic is best inserted by overriding the following methods, which are hooks called in response to the appropriate events.
 
        - `didCancel`
        - `didSuspend`
        - `didResume`
        - `didFinish`

    @warning Unlike typical NSOperations, SAYOperation subclasses should NEVER override `start` or `cancel`.
 
    @warning Setting `isFinished` to YES on a non-running, still queued operation will put the queue in an inconsistent state, which will often lead to a hard to track down runtime error. All subclasses should ensure they don't illegally call `markFinished`, but just in case, SAYOperation will refuse to act on the `markFinished` message for pending operations.

    ## Cancellation
 
    Note that cancellation is only to be used as a mechanism for queue management and operation lifecycle. A operation with "cancelled" status simply means that the operation has gotten word that it should finish up it's work as soon as possible. The operaton is not guaranteeing that all meaningful execution of the operation will cease at that instant. In fact, an operation can conceivably finish successfully even after being cancelled (see SAYSpeechOperation for an example of this).
 
    Therefore, subclasses that want to differentiate between "completed" and "interrupted" finshed states should define custom properties to expose this status to collaborators. The collaborators should never look to `isCancelled` to get this kind of information.
 
    Similarly, an operation should never have to send itself a `cancel` message. If it's operation has completed work but needs to report an error condition, it should set a custom property to signify the problem and then mark itself as finished.
 
    @warning It is still necessary for a subclass to call `markFinished` on itself after cancellation.
 */
@interface SAYOperation : NSOperation

#pragma mark Suspension

@property (readonly, getter=isSuspended) BOOL suspended;

/**
 *  Puts an executing operation in a suspended state. If the operation is not executing (i.e. it has not yet started, has finished, or is already suspended), there will be no effect.
 
    @notice Subclasses should not override this method
 */
- (void)suspend;

/**
 *  Puts a suspended operation into an executing state. If the operation is not suspended, there will be no effect.
 
    @notice Subclasses should not override this method
 */
- (void)resume;


#pragma mark State observation

/**
 *  Add object as a subscriber to execution state changes on the receiver.
 *
 *  @param observer Agent to subscribe to operation state updates
 */
- (void)addObserver:(id<SAYOperationObserver>)observer;

/**
 *  Remove object as subscriber. Not typically necessary for memory management reasons, since the receiver's lifetime is typically limited.
 *
 *  @param observer Agent to unsubscribe to operation state updates
 */
- (void)removeObserver:(id<SAYOperationObserver>)observer;


#pragma mark State management for subclasses

/**
 *  Puts a started operation (i.e. executing or suspended) into a finished state. Once finished, an operation cannot change states.
 
    Due to NSOperationQueue requirements, an operation must be started before it enters the finished state, or else an internal consistency runtime error may result. To avoid exceptions, this method will do nothing if it is called on a not yet started operation.

    @notice Subclasses should not override this function
 */
- (void)markFinished;


#pragma mark Subclass override points

/**
 *  Override point for starting actual operation work. Only called once, at the end of the `start` method.
 
    Subclasses are discouraged from collaborating with classes unreleated to the core operation work here: in most cases using the observer protocol is a better choice. Observers will receive the operationDidStart: message immediately before this is called.
 
     @notice Subclasses should never override `start`. This method should be overwritten instead.
 */
- (void)execute;

/**
 *  Override point for operation to suspend work.
 
    Subclasses are discouraged from collaborating with classes unreleated to the core operation work here: in most cases using the observer protocol is a better choice. Observers will receive the operationDidSuspend: message immediately after this is called.
 */
- (void)didSuspend;

/**
 *  Override point for operation to resume work.
 
    Subclasses are discouraged from collaborating with classes unreleated to the core operation work here: in most cases using the observer protocol is a better choice. Observers will receive the operationDidResume: message immediately after this is called.

 */
- (void)didResume;

/**
 *  Override point for acting after an operation enters the finished state.
 
    Subclasses are discouraged from collaborating with classes unreleated to the core operation work here: in most cases using the observer protocol is a better choice. Observers will receive the operationDidFinish: message immediately after this is called.
 */
- (void)didFinish;

/**
 *  Override point for acting after an operation enters the cancelled state.
 
    Subclasses are discouraged from collaborating with classes unreleated to the core operation work here: in most cases using the observer protocol is a better choice. Observers will receive the operationDidCancel: message immediately after this is called.
 */
- (void)didCancel;

@end

/**
 *  Descripts a protocol for classes interested in operation lifecycle events.
 */
@protocol SAYOperationObserver <NSObject>

/**
 *  Message sent when an operation begins executing.
 *
 *  @param operation Operation that just started execution
 */
- (void)operationDidStart:(SAYOperation *)operation;

/**
 *  Message sent when an operation enters a suspended state.
 *
 *  @param operation Operation that is now suspended
 */
- (void)operationDidSuspend:(SAYOperation *)operation;

/**
 *  Message sent when an operation leaves a suspended state and resumes executing.
 *
 *  @param operation Operation that just resumed execution
 */
- (void)operationDidResume:(SAYOperation *)operation;

/**
 *  Called when the operation finishes. Note that there is no guarantee that this method will be called before subsequent operations in a  queue are started.
 *
 *  @param operation Operation that just finished its execution
 */
- (void)operationDidFinish:(SAYOperation *)operation;

@end

NS_ASSUME_NONNULL_END
