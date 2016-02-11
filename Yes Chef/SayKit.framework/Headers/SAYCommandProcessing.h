//
//  SAYCommandProcessing.h
//  SayKit
//
//  Created by Greg Nicholas on 11/28/15.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#ifndef SAYCommandProcessing_h
#define SAYCommandProcessing_h

#import <SayKit/SAYCommand.h>

#import <SayKit/SAYVerbalCommandRequest.h>
#import <SayKit/SAYVerbalCommandRegistry.h>
#import <SayKit/SAYVerbalCommandRecognizer.h>

// standard recognizers
#import <SayKit/SAYHelpCommandRecognizer.h>
#import <SayKit/SAYSearchCommandRecognizer.h>
#import <SayKit/SAYBackCommandRecognizer.h>
#import <SayKit/SAYHomeCommandRecognizer.h>
#import <SayKit/SAYSelectCommandRecognizer.h>
#import <SayKit/SAYNextCommandRecognizer.h>
#import <SayKit/SAYPreviousCommandRecognizer.h>
#import <SayKit/SAYPlayCommandRecognizer.h>
#import <SayKit/SAYPauseCommandRecognizer.h>
#import <SayKit/SAYAvailableCommandsCommandRecognizer.h>
#import <SayKit/SAYSwitchTabCommandRecognizer.h>
#import <SayKit/SAYSettingsCommandRecognizer.h>
#import <SayKit/SAYIncreaseSpeechRateCommandRecognizer.h>
#import <SayKit/SAYDecreaseSpeechRateCommandRecognizer.h>
#import <SayKit/SAYIncreaseSpeechVolumeCommandRecognizer.h>
#import <SayKit/SAYDecreaseSpeechVolumeCommandRecognizer.h>
#import <SayKit/SAYSetSpeechRateCommandRecognizer.h>
#import <SayKit/SAYSetSpeechVolumeCommandRecognizer.h>
#import <SayKit/SAYSetVoiceCommandRecognizer.h>
#import <SayKit/SAYCustomCommandRecognizer.h>

#import <SayKit/SAYStandardCommandLibrary.h>

#import <SayKit/SAYCommandSuggestion.h>

#import <SayKit/SAYTextCommandMatcher.h>
#import <SayKit/SAYBlockCommandMatcher.h>
#import <SayKit/SAYPatternCommandMatcher.h>

#import <SayKit/SAYCommandBar.h>
#import <SayKit/SAYCommandBarDelegate.h>
#import <SayKit/SAYCommandBarController.h>
#import <SayKit/SAYCommandBarPresentationController.h>

#endif /* SAYCommandProcessing_h */
