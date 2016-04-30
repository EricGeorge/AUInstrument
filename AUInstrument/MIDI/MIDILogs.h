//
//  MIDILogs.h
//  AUInstrument
//
//  Created by Eric on 4/15/16.
//  Copyright © 2016 Eric George. All rights reserved.
//

#ifndef MIDILogs_h
#define MIDILogs_h

@import CoreMIDI;

void printDevices();
void printSources();
void printDestinations();

void LogMidiEventToConsole(uint8_t status,
                           uint8_t channel,
                           uint8_t data1,
                           uint8_t data2,
                           uint64_t startFrame);

NSString* GetMidiObjectTypeName(MIDIObjectType type);

#endif /* MIDILogs_h */
