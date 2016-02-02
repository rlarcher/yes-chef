//
//  SAYStandardCommandLibrary.h
//  SayKit
//
//  Created by Adam Larsen on 2015/12/03.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Name for SayKit standard Help command type
 */
FOUNDATION_EXPORT NSString * const SAYStandardCommandHelp;

/**
 *  Name for SayKit standard Search command type
 */
FOUNDATION_EXPORT NSString * const SAYStandardCommandSearch;

/**
 *  Parameter dictionary key for a search query associated with the SayKit Search command.
 */
FOUNDATION_EXPORT NSString * const SAYSearchCommandRecognizerParameterQuery;

/**
 *  Name for SayKit standard Select command type
 */
FOUNDATION_EXPORT NSString * const SAYStandardCommandSelect;

/**
 *  Parameter dictionary key for a selected item name associated with the SayKit Select command.
 */
FOUNDATION_EXPORT NSString * const SAYSelectCommandRecognizerParameterItemName;

/**
 *  Parameter dictionary key for a selected item number associated with the SayKit Select command.
 */
FOUNDATION_EXPORT NSString * const SAYSelectCommandRecognizerParameterItemNumber;

/**
 *  Name for SayKit standard Play command type
 */
FOUNDATION_EXPORT NSString * const SAYStandardCommandPlay;

/**
 *  Name for SayKit standard Pause command type
 */
FOUNDATION_EXPORT NSString * const SAYStandardCommandPause;

/**
 *  Name for SayKit standard Next command type
 */
FOUNDATION_EXPORT NSString * const SAYStandardCommandNext;

/**
 *  Name for SayKit standard Previous command type
 */
FOUNDATION_EXPORT NSString * const SAYStandardCommandPrevious;

/**
 *  Name for SayKit standard Available Commands command type
 */
FOUNDATION_EXPORT NSString * const SAYStandardCommandAvailableCommands;

/**
 *  Name for SayKit standard Home (navigation) command type
 */
FOUNDATION_EXPORT NSString * const SAYStandardCommandHome;

/**
 *  Name for SayKit standard Back (navigation) command type
 */
FOUNDATION_EXPORT NSString * const SAYStandardCommandBack;

/**
 *  Name for SayKit standard Switch Tab command type
 */
FOUNDATION_EXPORT NSString * const SAYStandardCommandSwitchTab;

/**
 *  Parameter dictionary key for a tab name associated with the SayKit Switch Tab command.
 */
FOUNDATION_EXPORT NSString * const SAYSwitchTabCommandRecognizerParameterTabName;

/**
 *  Parameter dictionary key for a tab number associated with the SayKit Switch Tab command.
 */
FOUNDATION_EXPORT NSString * const SAYSwitchTabCommandRecognizerParameterTabNumber;

/**
 *  Name for SayKit standard Settings command type
 */
FOUNDATION_EXPORT NSString * const SAYStandardCommandSettings;

/**
 *  Name for SayKit standard Increase Speech Rate command type
 */
FOUNDATION_EXPORT NSString * const SAYStandardCommandIncreaseSpeechRate;

/**
 *  Name for SayKit standard Decrease Speech Rate command type
 */
FOUNDATION_EXPORT NSString * const SAYStandardCommandDecreaseSpeechRate;

/**
 *  Name for SayKit standard Increase Speech Volume command type
 */
FOUNDATION_EXPORT NSString * const SAYStandardCommandIncreaseSpeechVolume;

/**
 *  Name for SayKit standard Decrease Speech Volume command type
 */
FOUNDATION_EXPORT NSString * const SAYStandardCommandDecreaseSpeechVolume;

/**
 *  Name for SayKit standard Set Speech Rate command type
 */
FOUNDATION_EXPORT NSString * const SAYStandardCommandSetSpeechRate;

/**
 *  Parameter dictionary key for a speech rate associated with the SayKit Set Speech Rate command.
 */
FOUNDATION_EXPORT NSString * const SAYSetSpeechRateCommandRecognizerParameterSpeechRate;

/**
 *  Name for SayKit standard Set Speech Volume command type
 */
FOUNDATION_EXPORT NSString * const SAYStandardCommandSetSpeechVolume;

/**
 *  Parameter dictionary key for a speech volume associated with the SayKit Set Speech Volume command.
 */
FOUNDATION_EXPORT NSString * const SAYSetSpeechVolumeCommandRecognizerParameterSpeechVolume;

/**
 *  Name for SayKit standard Set Voice command type
 */
FOUNDATION_EXPORT NSString * const SAYStandardCommandSetVoice;

/**
 *  Parameter dictionary key for a voice associated with the SayKit Set Voice command.
 */
FOUNDATION_EXPORT NSString * const SAYSetVoiceCommandRecognizerParameterVoice;

NS_ASSUME_NONNULL_END
