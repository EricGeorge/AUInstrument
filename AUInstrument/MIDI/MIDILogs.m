//
//  MIDILogs.m
//  AUInstrument
//
//  Created by Eric on 4/17/16.
//  Copyright © 2016 Eric George. All rights reserved.
//

@import Foundation;
@import CoreMIDI;

#import "MIDIConstants.h"
#import "MIDILogs.h"
#import "Utility.h"

void printProperties(MIDIObjectRef ref, ItemCount iter)
{
    CFPropertyListRef midiProperties;
    
    MIDIObjectGetProperties(ref, &midiProperties, YES);
    
    NSDictionary *dict = (__bridge NSDictionary *)midiProperties;
    
    QLog(@"Midi properties: %lu \n %@", iter, dict);
}

void printDevices()
{
    QLog(@"\n********************");
    QLog(@"*** MIDI DEVICES ***");
    QLog(@"********************");
    // How many MIDI devices do we have?
    ItemCount deviceCount = MIDIGetNumberOfDevices();
    
    // Iterate through all MIDI devices
    for (ItemCount i = 0 ; i < deviceCount ; ++i)
    {
        // Grab a reference to current device
        printProperties(MIDIGetDevice(i), i);
    }
}

void printSources()
{
    QLog(@"\n********************");
    QLog(@"*** MIDI SOURCES ***");
    QLog(@"********************");
    
    // Virtual sources and destinations don't have entities
    ItemCount sourceCount = MIDIGetNumberOfSources();
    for (ItemCount i = 0 ; i < sourceCount ; ++i)
    {
        
        printProperties(MIDIGetSource(i), i);
    }
}

void printDestinations()
{
    QLog(@"\n*************************");
    QLog(@"*** MIDI DESTINATIONS ***");
    QLog(@"*************************");
    
    ItemCount destCount = MIDIGetNumberOfDestinations();
    for (ItemCount i = 0 ; i < destCount ; ++i)
    {
        
        // Grab a reference to a destination endpoint
        printProperties(MIDIGetDestination(i), i);
    }
}

void LogMidiEventToConsole(uint8_t status,
                           uint8_t channel,
                           uint8_t data1,
                           uint8_t data2,
                           uint64_t startFrame)
{
    switch (status)
    {
        case MIDIMessageType_NoteOff:
            QLog(@"-- Note Off: \tCh:%d \tNote:%d \tVel:%d", channel, data1, data2);
            break;
            
        case MIDIMessageType_NoteOn:
            QLog(@"-- Note On: \tCh:%d \tNote:%d \tVel:%d", channel, data1, data2);
            break;
            
        case MIDIMessageType_PolyphonicKeyPressure:
            QLog(@"-- Aftertouch: \tCh:%d \tNote:%d \tValue:%d", channel, data1, data2);
            break;
            
        case MIDIMessageType_ControlChange:
            switch (data1)
        {
            default:
                QLog(@"-- Unspecified Control Change: \tCh:%d \tCC:%d \tValue:%d", channel, data1, data2);
                break;
                
            case MIDIControlChange_ModWheel:
                QLog(@"-- CC01 Mod Wheel: \tCh:%d \tValue:%d", channel, data2);
                break;
                
            case MIDIControlChange_ChannelVolume:
                QLog(@"-- CC07 Channel Volume: \tCh:%d \tValue:%d", channel, data2);
                break;
                
            case MIDIControlChange_Pan:
                QLog(@"-- CC10 Pan: \tCh:%d \tValue:%d", channel, data2);
                break;
                
            case MIDIControlChange_Expression:
                QLog(@"-- CC11 Expression: \tCh:%d \tValue:%d", channel, data2);
                break;
                
            case MIDIControlChange_SustainPedal:
                QLog(@"-- CC64 Sustain Pedal: \tCh:%d \tValue:%d", channel, data2);
                break;
                
            case MIDIControlChange_Panic:
                QLog(@"-- CC123 All Notes Off: \tCh:%d \tValue:%d", channel, data2);
                break;
        }
            break;
            
        case MIDIMessageType_ProgramChange:
            QLog(@"-- Program Change: \tCh:%d \tProgram#:%d", channel, data1);
            break;
            
        case MIDIMessageType_ChannelPressure:
            QLog(@"-- Channel Aftertouch: \tCh:%d \tValue:%d", channel, data1);
            break;
            
        case MIDIMessageType_PitchWheelChange:
            QLog(@"-- Pitch wheel: \tCh:%d \tLow:%d \tHigh:%d", channel, data1, data2);
            break;
            
        default:
            QLog(@"-- Unhandled message: \tStatus:%d \tCh:%d \tData1:%d \tData2%d", status, channel, data1, data2);
            break;
    }
}

NSString* GetMidiObjectTypeName(MIDIObjectType type)
{
    NSString *typeName = @"Unknown Type";
    switch (type)
    {
        case kMIDIObjectType_Other:
            typeName = @"Other";
            break;
        case kMIDIObjectType_Device:
            typeName = @"Device";
            break;
        case kMIDIObjectType_Entity:
            typeName = @"Entity";
            break;
        case kMIDIObjectType_Source:
            typeName = @"Source";
            break;
        case kMIDIObjectType_Destination:
            typeName = @"Destination";
            break;
        case kMIDIObjectType_ExternalDevice:
            typeName = @"External Device";
            break;
        case kMIDIObjectType_ExternalEntity:
            typeName = @"ExternalEntity";
            break;
        case kMIDIObjectType_ExternalSource:
            typeName = @"External Source";
            break;
        case kMIDIObjectType_ExternalDestination:
            typeName = @"External Destination";
            break;
    }
    return typeName;
}

