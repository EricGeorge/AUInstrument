//
//  MIDIEvent.m
//  AUInstrument
//
//  Created by Eric on 4/24/16.
//  Copyright © 2016 Eric George. All rights reserved.
//

#import "MIDIEvent.h"

@implementation MIDIEvent

- (_Nonnull id) initWithAUMidiEvent:(nonnull const AUMIDIEvent * )midiEvent
{
    self = [super init];
    if (self)
    {
        self.message = midiEvent->data[0] & 0xF0;
        self.channel = midiEvent->data[0] & 0x0F;
        self.data1 = midiEvent->data[1];
        self.data2 = midiEvent->data[2];
        self.messageLength = midiEvent->length;
        self.sampleTime = midiEvent->eventSampleTime;
    }
    
    return self;
}

@end