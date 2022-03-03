//
//  MIDIEvent.h
//  AUInstrument
//
//  Created by Eric on 4/24/16.
//  Copyright © 2016 Eric George. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <Foundation/Foundation.h>

#import "MIDIConstants.h"

@interface MIDIEvent : NSObject

@property(nonatomic, assign)myMIDIMessageType message;
@property(nonatomic, assign)uint16_t messageLength;
@property(nonatomic, assign)uint8_t channel;
@property(nonatomic, assign)uint8_t data1;
@property(nonatomic, assign)uint8_t data2;
@property(nonatomic, assign)int64_t sampleTime;

- (_Nonnull id) initWithAUMidiEvent:(nonnull const AUMIDIEvent *)midiEvent;

@end
