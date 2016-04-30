//
//  MIDIConstants.h
//  AUInstrument
//
//  Created by Eric on 4/17/16.
//  Copyright © 2016 Eric George. All rights reserved.
//

#ifndef MIDIConstants_h
#define MIDIConstants_h

typedef NS_ENUM(NSUInteger, MIDIMessageType)
{
    /* Note off */
    MIDIMessageType_NoteOff = 0x80,
    
    /* Note on */
    MIDIMessageType_NoteOn = 0x90,
    
    /* Polyphonic key pressure */
    MIDIMessageType_PolyphonicKeyPressure = 0xA0,
    
    /* Control change */
    MIDIMessageType_ControlChange = 0xB0,
    
    /* Program change */
    MIDIMessageType_ProgramChange = 0xC0,
    
    /* Channel pressure */
    MIDIMessageType_ChannelPressure = 0xD0,
    
    /* Pitch wheel change */
    MIDIMessageType_PitchWheelChange = 0xE0,
    
    /* System Exclusive */
    MIDIMessageType_SystemExclusive = 0xF0,
    
    /* Time Code */
    MIDIMessageType_TimeCode = 0xF1,
    
    /* Song Position Pointer */
    MIDIMessageType_SongPositionPointer = 0xF2,
    
    /* Song Select */
    MIDIMessageType_SongSelect = 0xF3,
    
    /* Tune Request */
    MIDIMessageType_TuneRequest = 0xF6,
    
    /* End of Exclusive */
    MIDIMessageType_EndOfExclusive = 0xF7,
    
    /* Timing Clock */
    MIDIMessageType_TimingClock = 0xF8,
    
    /* Start */
    MIDIMessageType_Start = 0xFA,
    
    /* Continue */
    MIDIMessageType_Continue = 0xFB,
    
    /* Stop */
    MIDIMessageType_Stop = 0xFC,
    
    /* Active Sensing */
    MIDIMessageType_ActiveSensing = 0xFE,
    
    /* System Reset */
    MIDIMessageType_SystemReset = 0xFF,
};

// supported MIDI Control Change Messages
typedef NS_ENUM(NSUInteger, MIDIControlChange)
{
    /* Mod Wheel */
    MIDIControlChange_ModWheel = 0x01,
    
    /* Channel Volume */
    MIDIControlChange_ChannelVolume = 0x07,
    
    /* Pan */
    MIDIControlChange_Pan = 0x0A,
    
    /* Expression */
    MIDIControlChange_Expression = 0x0B,
    
    /* Sustain Pedal */
    MIDIControlChange_SustainPedal = 0x40,
    
    /* Panic/All Notes Off */
    MIDIControlChange_Panic = 0x7B,
};

#endif /* MIDIConstants_h */
