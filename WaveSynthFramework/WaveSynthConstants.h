//
//  WaveSynthConstants.h
//  AUInstrument
//
//  Created by Eric on 4/30/16.
//  Copyright © 2016 Eric George. All rights reserved.
//

typedef NS_ENUM(NSInteger, OscillatorWave)
{
    OSCILLATOR_WAVE_FIRST,
    OSCILLATOR_WAVE_SINE = OSCILLATOR_WAVE_FIRST,
    OSCILLATOR_WAVE_SAW,
    OSCILLATOR_WAVE_SQUARE,
    OSCILLATOR_WAVE_TRIANGLE,
    OSCILLATOR_WAVE_LAST = OSCILLATOR_WAVE_TRIANGLE
};

static NSString *volumeParamKey = @"volume";
static NSString *waveformParamKey = @"waveform";