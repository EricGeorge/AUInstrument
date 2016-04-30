//
//  WaveSynthProc.cpp
//  AUInstrument
//
//  Created by Eric on 4/23/16.
//  Copyright © 2016 Eric George. All rights reserved.
//

#import "WaveSynthProc.hpp"

#import "MIDIEvent.h"
#import "Utility.hpp"

WaveSynthProc::WaveSynthProc()
{
    sampleRate = 44100.0;
    frequencyScale = 2. * M_PI / sampleRate;
    
    outBufferListPtr = nullptr;
    
    osc = [[Oscillator alloc] init];
    osc.wave = OSCILLATOR_WAVE_SINE;
    noteOn = NO;
    velocity = 0;
    volume = 0.1;
}

void WaveSynthProc::init(int channelCount, double inSampleRate)
{
    sampleRate = float(inSampleRate);
    
    frequencyScale = 2. * M_PI / sampleRate;
}

void WaveSynthProc::reset()
{
    // this currently does nothing
}

void WaveSynthProc::setParameter(AUParameterAddress address, AUValue value)
{
    switch (address)
    {
        case WaveSynthProc::InstrumentParamVolume:
            volume = clamp(value, 0.001f, 1.0f);
            break;
        case WaveSynthProc::InstrumentParamWaveform:
            osc.wave = (OscillatorWave)value;
            break;
    }
}

AUValue WaveSynthProc::getParameter(AUParameterAddress address)
{
    AUValue value = 0.0f;
    
    switch (address)
    {
        case InstrumentParamVolume:
            value = volume;
            break;
        case InstrumentParamWaveform:
            value = osc.wave;
            break;
    }
    
    return value;
}

void WaveSynthProc::startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration)
{
    setParameter(address, value);
}

void WaveSynthProc::setBuffers(AudioBufferList* outBufferList)
{
    outBufferListPtr = outBufferList;
}

void WaveSynthProc::handleMIDIEvent(AUMIDIEvent const& midiEvent)
{
    MIDIEvent *event = [[MIDIEvent alloc] initWithAUMidiEvent:&midiEvent];
    
    switch (event.message)
    {
        default:
//            NSLog(@"Instrument received unhandled MIDI event");
            break;
        case MIDIMessageType_NoteOff:
            noteOn = NO;
            velocity = 0;
            break;
        case MIDIMessageType_NoteOn:
            osc.frequency = noteToHz(event.data1);
            velocity = event.data2;
            noteOn = YES;
            break;
    }
}

void WaveSynthProc::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset)
{
    float* outL = (float*)outBufferListPtr->mBuffers[0].mData + bufferOffset;
    float* outR = (float*)outBufferListPtr->mBuffers[1].mData + bufferOffset;
    
    if (noteOn)
    {
        for (AUAudioFrameCount i = 0; i < frameCount; ++i)
        {
            outL[i] = outR[i] = [osc nextSample] * (double)velocity / 127.0 * volume;
        }
    }
}
