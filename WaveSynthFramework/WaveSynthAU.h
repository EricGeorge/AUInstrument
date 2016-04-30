//
//  WaveSynthAU.h
//  WaveSynth
//
//  Created by Eric on 4/22/16.
//  Copyright © 2016 Eric George. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "WaveSynthConstants.h"

@interface WaveSynthAU : AUAudioUnit

@property(nonatomic, assign) OscillatorWave selectedWaveform;

@end
