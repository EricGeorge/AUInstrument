//
//  Oscillator.h
//  AUInstrument
//
//  Created by Eric on 4/20/16.
//  Copyright © 2016 Eric George. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WaveSynthConstants.h"

@interface Oscillator : NSObject

@property (nonatomic, assign) OscillatorWave wave;
@property (nonatomic, assign) double frequency;
@property (nonatomic, assign) double sampleRate;

- (double) nextSample;

@end

