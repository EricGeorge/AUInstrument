//
//  MIDIManager.h
//  AUInstrument
//
//  Created by Eric on 4/17/16.
//  Copyright © 2016 Eric George. All rights reserved.
//

@import Foundation;

@protocol MIDIManagerDelegate

- (void) handleMidiEvent:(uint8_t)status
             withChannel:(uint8_t)channel
               withData1:(uint8_t)data1
               withData2:(uint8_t)data2
          withStartFrame:(uint64_t)startFrame;

@end

@interface MIDIManager : NSObject

@property(nonatomic, assign) id delegate;

+ (instancetype)sharedMIDIManager;

@end
