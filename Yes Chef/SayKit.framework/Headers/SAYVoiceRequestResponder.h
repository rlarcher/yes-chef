//
//  SAYVoiceRequestResponder.h
//  SayKit
//
//  Created by Greg Nicholas on 12/16/15.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAYVoiceRequestResponse.h"

@protocol SAYVoiceRequest;
@class SAYInterpretation;

NS_ASSUME_NONNULL_BEGIN

/**
 *  The `SAYVoiceRequestResponder` protocol describes the three types of messages that can occur at the end of a voice request cycle. A class that conforms to `SAYVoiceRequestResponder` is responsible for receiving these messages and prescribing a response to them.
 
    ## Responders Build Responses
 
    Note that conforming classes are not intended to *directly* take action in response to these message. Rather, they are to define a response and pass it along, wrapped up in `SAYVoiceRequestResponse` instance. These responses include three properties, all optional:
 
    - A **feedback prompt**, which is a message presented to the user before the request is dismissed, or a follow-up request starts a new cycle
    - An **action**, which is a block called after the request is dismissed, or before a follow-up request starts a new cycle
    - A **follow-up request**, which is a new request that will begin immediately after the other two properties are executed
 
    ## Response cases
 
    Each request cycle will end in one (and only one) of three ways. Each method defined by this protocol corresponds to one of these cases:
 
    1. The request was able to receive and attempt to interpret user speech.
    2. The request failed due to a speech recognition error.
    3. The request was cancelled by outside means (e.g. the user hitting a cancel button)
 
    Each of these is discussed more below.
 
    ### Responding to Interpretations
 
    Assuming speech recognition succeeded, the voice request was able to employ its `SAYVoiceRequestInterpreter` to try to transform user speech into an actionable value, wrapped up in a `SAYInterpretation` instance. (If this is unfamiliar, see the documentation for `SAYInterpretation` before continuing with this section.)
 
    This interpretation is then handed over to the `SAYVoiceRequestResponder`, via the `voiceRequest:respondToInterpretation:` method. The receiver is responsible for unpacking the interpretation and deciding how to respond. This responsibility includes creating a response when the interpretation failed because user intent couldn't be determined (for example, defining a follow-up request to reprompt the user).
 
    Through this method, the `SAYVoiceRequestInterpreter` and `SAYVoiceRequestResponder` work together closely. As a result, the two classes typically have a shared contextual "understanding" between them. More concretely, a paired responder and interpreter will typically share knowledge about the data type stored inside the `SAYInterpretation` instance passed between them. In addition, they will often share knowledge about expected validation error types that may be inside the `SAYInterpration` -- that way, the responder will be able to properly communicate interpretation problems with users.
 
    ### Responding to Recognition Errors
 
    If speech recognition failed, there is nothing to interpret, so the `SAYVoiceRequestResponder` is consulted immediately for a response by sending it the `voiceRequest:respondToRecognitionError:` message. The receiver is tasked with constructing an appropriate response to this failure, consulting the details stored in the error parameter if necessary.
 
    Typically, in the event of a transient error (e.g. server glitch), the responder will direct the app to try again by constructing a response that re-issuing the original request as a follow-up. If the error is unlikely to be resolved by trying again (e.g. no network connectivity), the response may just be a feedback message with no follow-up request.
 
    ### Responding to Cancellation
 
    A request can be cancelled at any time. This will typically be due to the user simply wanting to cancel it directly. To notify the responder that the request was cancelled, its `respondToCancellationOfVoiceRequest:` method is called.
 
    Unlike with the cases above, the responder is not able to dictate the next step in the response cycle. It has already been decided that the request is terminating and there will be no follow-up. As a result, only a subset of a full `SAYVoiceRequestResponse` is applicable: the action block. Hence, the return type of this method is just an optional `SAYVoiceRequestResponseAction`.
 
    ## Reducing Boilerplate
 
    Although `SAYVoiceRequestResponder`-conforming classes typically have some context-specific logic when it comes to handling the given interpretation types its expected to handle, a lot of the other behavior expected from a responder class is fairly boilerplate. Validation errors usually  summon a "try again" response; speech recognition errors are typically met with informational error messages to the user and no follow-up request; and so on.
 
    To obviate the need for such boilerplate, these common behaviors are typically captured in a base class from which actual response classes are derived. Or, in the case of many of SayKit's standard `SAYVoiceRequest`, a single generic responder class, the `SAYStandardRequestResponder` is used. See the documentation for `SAYStandardRequestResponder` for details on customizing it for your own use.
 */
@protocol SAYVoiceRequestResponder <NSObject>

- (SAYVoiceRequestResponse *)voiceRequest:(id<SAYVoiceRequest>)voiceRequest respondToInterpretation:(SAYInterpretation *)interpretation;
- (SAYVoiceRequestResponse *)voiceRequest:(id<SAYVoiceRequest>)voiceRequest respondToRecognitionError:(NSError *)error;
- (nullable SAYVoiceRequestResponseAction)respondToCancellationOfVoiceRequest:(id<SAYVoiceRequest>)voiceRequest;

@end

NS_ASSUME_NONNULL_END
