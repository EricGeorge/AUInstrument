//
//  MIDIManager.m
//  AUInstrument
//
//  Created by Eric on 4/17/16.
//  Copyright © 2016 Eric George. All rights reserved.
//

#import "MIDIManager.h"

@import CoreMIDI;

#import "MIDILogs.h"
#import "Utility.h"

static MIDIManager *sharedMIDIManager;

@interface MIDIManager ()

- (void)handleMIDINotification:(const MIDINotification *)notification;
- (void)handleMIDIRead:(MIDIPacketList *)packets;

@end

void MIDINotificationCallback(const MIDINotification *notification,
                              void                   *context)
{
    id wrapper = (__bridge id)context;
    [wrapper handleMIDINotification:notification];
}

void MIDIReadCallback(const MIDIPacketList *packets,
                      void                 *context,
                      void                 *sourceContext)
{
    id wrapper = (__bridge id)context;
    [wrapper handleMIDIRead:(MIDIPacketList *)packets];
}

static inline const uint8_t* GetNextMIDIEvent(const uint8_t *event,
                                              const uint8_t *end)
{
    uint8_t c = *event;
    switch (c >> 4)
    {
        default:	// data byte -- assume in sysex
            while ((*++event & 0x80) == 0 && event < end)
                ;
            break;
        case 0x8:
        case 0x9:
        case 0xA:
        case 0xB:
        case 0xE:
            event += 3;
            break;
        case 0xC:
        case 0xD:
            event += 2;
            break;
        case 0xF:
            switch (c)
        {
            case 0xF0:
                while ((*++event & 0x80) == 0 && event < end)
                    ;
                break;
            case 0xF1:
            case 0xF3:
                event += 2;
                break;
            case 0xF2:
                event += 3;
                break;
            default:
                ++event;
                break;
        }
    }
    return (event >= end) ? end : event;
}

@implementation MIDIManager

+ (instancetype)sharedMIDIManager
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedMIDIManager = [(MIDIManager *)[super alloc] init];
    });
    
    return sharedMIDIManager;
}

- (id) init
{
    if (self == sharedMIDIManager)
    {
        return sharedMIDIManager;
    }

    self = [super init];
    if (self)
    {
        MIDIClientRef client;
        MIDIClientCreate(CFSTR("AU Instrument"),
                         MIDINotificationCallback,
                         (__bridge void * _Nullable)(self),
                         &client);
        
        MIDIPortRef inPort;
        MIDIInputPortCreate(client,
                            CFSTR("Input port"),
                            MIDIReadCallback,
                            (__bridge void * _Nullable)(self),
                            &inPort);
        
        ItemCount numSources = MIDIGetNumberOfSources();

        for (ItemCount i=0; i<numSources; i++)
        {
            MIDIEndpointRef src = MIDIGetSource(i);
            MIDIPortConnectSource(inPort, src, NULL);
        }
    }
        
    return self;
}

- (void)handleMIDINotification:(const MIDINotification *)notification
{
    switch (notification->messageID)
    {
        case kMIDIMsgSetupChanged:
            [self handleNotificationSetupChanged];
            break;
        case kMIDIMsgObjectAdded:
            [self handleNotificationObjectAdded:(MIDIObjectAddRemoveNotification *)notification];
            break;
        case kMIDIMsgObjectRemoved:
            [self handleNotificationObjectRemoved:(MIDIObjectAddRemoveNotification *)notification];
            break;
        case kMIDIMsgPropertyChanged:
            [self handleNotificationPropertyChanged:(MIDIObjectPropertyChangeNotification *)notification];
            break;
        case kMIDIMsgThruConnectionsChanged:
            [self handleNotificationThruConnectionsChanged];
            break;
        case kMIDIMsgSerialPortOwnerChanged:
            [self handleNotificationSerialPortOwnerChanged];
            break;
        case kMIDIMsgIOError:
            [self handleNotificationIOError:(MIDIIOErrorNotification *)notification];
            break;
        default:
            QLog(@"MIDI Notification - unhandled messageId:%d", notification->messageID);
            break;
    }
}

- (void) handleNotificationSetupChanged
{
    QLog(@"MIDI Notification - kMIDIMsgSetupChanged");
}

- (void) handleNotificationObjectAdded:(MIDIObjectAddRemoveNotification *)notification
{
    MIDIObjectRef parentRef = notification->parent;
    MIDIObjectType parentType = notification->parentType;
    MIDIObjectRef childRef = notification->child;
    MIDIObjectType childType = notification->childType;
    QLog(@"MIDI Notification - Object added:  parentRef:%d, parentType:%@, childRef:%d, childType:%@", parentRef, GetMidiObjectTypeName(parentType), childRef, GetMidiObjectTypeName(childType));
}

- (void) handleNotificationObjectRemoved:(MIDIObjectAddRemoveNotification *)notification
{
    MIDIObjectRef parentRef = notification->parent;
    MIDIObjectType parentType = notification->parentType;
    MIDIObjectRef childRef = notification->child;
    MIDIObjectType childType = notification->childType;
    QLog(@"MIDI Notification - Object removed:  parentRef:%d, parentType:%@, childRef:%d, childType:%@", parentRef, GetMidiObjectTypeName(parentType), childRef, GetMidiObjectTypeName(childType));
}

- (void) handleNotificationPropertyChanged:(MIDIObjectPropertyChangeNotification *)notification
{
    MIDIObjectPropertyChangeNotification *data = (MIDIObjectPropertyChangeNotification *)notification;
    MIDIObjectRef ref = data->object;
    MIDIObjectType type = data->objectType;
    NSString *name = (__bridge NSString *)(data->propertyName);
    QLog(@"MIDI Notification - Property Change:  object:%d, type:%@, name:%@", ref, GetMidiObjectTypeName(type), name);
}

- (void) handleNotificationThruConnectionsChanged
{
    QLog(@"MIDI Notification - kMIDIMsgThruConnectionsChanged");
}

- (void) handleNotificationSerialPortOwnerChanged
{
    QLog(@"MIDI Notification - kMIDIMsgSerialPortOwnerChanged");
}

- (void) handleNotificationIOError:(MIDIIOErrorNotification *)notification
{
    MIDIIOErrorNotification *data = (MIDIIOErrorNotification *)notification;
    MIDIDeviceRef device = data->driverDevice;
    OSStatus err = data->errorCode;
    QLog(@"MIDI Notification: IO Error - device:%d, error:%d", device, err);
}

- (void)handleMIDIRead:(MIDIPacketList *)packets
{
    int nPackets = packets->numPackets;
    const MIDIPacket *pkt = packets->packet;
    
    while (nPackets-- > 0)
    {
        const uint8_t *event = pkt->data, *packetEnd = event + pkt->length;
        uint64_t startFrame = (uint64_t)pkt->timeStamp;

        while (event < packetEnd)
        {
            uint8_t status = event[0];
            if (status & 0x80)
            {
                [self handleMidiEvent:status & 0xF0
                          withChannel:status & 0x0f
                            withData1:event[1]
                            withData2:event[2]
                       withStartFrame:startFrame];
            }
            
            event = GetNextMIDIEvent(event, packetEnd);
        }
        pkt = MIDIPacketNext(pkt);
    }
    
}

- (void) handleMidiEvent:(uint8_t)status
             withChannel:(uint8_t)channel
               withData1:(uint8_t)data1
               withData2:(uint8_t)data2
          withStartFrame:(uint64_t)startFrame
{
    [self.delegate handleMidiEvent:status
                       withChannel:channel
                         withData1:data1
                         withData2:data2
                    withStartFrame:startFrame];
}


@end