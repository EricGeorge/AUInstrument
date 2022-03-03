//
//  Oscillator.m
//  AUInstrument
//
//  Created by Eric on 4/20/16.
//  Copyright © 2016 Eric George. All rights reserved.
//

#import "Oscillator.h"

const double twoPI = 2 * M_PI;


Oscillator::Oscillator ()
    : _wave(OSCILLATOR_WAVE_SINE)
    , _frequency(440.0)
    , _sampleRate(44100)
    , _phase(0.0) {
        updateIncrement();
}

void Oscillator::setSampleRate(double sampleRate) {
    _sampleRate = sampleRate;
    updateIncrement();
}

void Oscillator::setFrequency(double frequency) {
    _frequency = frequency;
    updateIncrement();
}

void Oscillator::setWave(OscillatorWave wave) {
    _wave = wave;
}

OscillatorWave Oscillator::getWave() {
    return _wave;
}

void Oscillator::updateIncrement() {
    _phaseIncrement = _frequency * twoPI / _sampleRate;
}

double Oscillator::nextSample() {
    double sample = 0.0;
    switch (_wave) {
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

