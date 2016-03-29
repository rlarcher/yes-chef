//
//  SAYWaveformView.h
//  SayKit
//
//  Created by Adam Larsen on 2015/11/18.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import "SCSiriWaveformView.h"
#import <UIKit/UIKit.h>

@interface SAYWaveformView : SCSiriWaveformView

// Converts the raw level to one usable by the waveform view (non-negative and normalized) before displaying it.
- (void)updateWithRawLevel:(float)level;

@end
