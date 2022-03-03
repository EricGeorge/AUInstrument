//
//  Oscillator.h
//  AUInstrument
//
//  Created by Eric on 4/20/16.
//  Copyright © 2016 Eric George. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WaveSynthConstants.h"

class Oscillator {
    double _phase;
    double _phaseIncrement;
    OscillatorWave _wave;
    double _frequency;
    double _sampleRate;

    void updateIncrement();
    
public:
    Oscillator();
    void setSampleRate(double sampleRate);
    void setFrequency(double frequency);
    void setWave(OscillatorWave wave);
    OscillatorWave getWave();
    double nextSample();
};
