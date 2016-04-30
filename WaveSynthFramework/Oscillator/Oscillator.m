//
//  Oscillator.m
//  AUInstrument
//
//  Created by Eric on 4/20/16.
//  Copyright © 2016 Eric George. All rights reserved.
//

#import "Oscillator.h"

const double twoPI = 2 * M_PI;

@interface Oscillator ()
{
    double _phase;
    double _phaseIncrement;
}

- (void) updateIncrement;

@end


@implementation Oscillator

- (instancetype)init
{
    if (self = [super init])
    {
        self.wave = OSCILLATOR_WAVE_SINE;
        self.frequency = 440.0;
        self.sampleRate = 44100;
        _phase = 0.0;
        
        [self updateIncrement];
    }
    
    return self;
}

- (void) setSampleRate:(double)sampleRate
{
    _sampleRate = sampleRate;
    [self updateIncrement];
}

- (void) setFrequency:(double)frequency
{
    _frequency = frequency;
    [self updateIncrement];
}

- (void) updateIncrement
{
    _phaseIncrement = _frequency * twoPI / _sampleRate;
}

- (double) nextSample
{
    double sample = 0.0;
    
    switch (self.wave)
    {
        case OSCILLATOR_WAVE_SINE:
            sample = sin(_phase);
            break;
        case OSCILLATOR_WAVE_SAW:
            sample = 1.0 - (2.0 * _phase / twoPI);
            break;
        case OSCILLATOR_WAVE_SQUARE:
            if (_phase <= M_PI)
            {
                sample = 1.0;
            }
            else
            {
                sample = -1.0;
            }
            break;
        case OSCILLATOR_WAVE_TRIANGLE:
            sample = -1.0 + (2.0 * _phase / twoPI);
            sample = 2.0 * (fabs(sample) - 0.5);
            break;
    }
    
    _phase += _phaseIncrement;
    
    while (_phase >= twoPI)
    {
        _phase -= twoPI;
    }
    
    return sample;
}

@end
