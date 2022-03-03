//
//  WaveSynthAU.m
//  WaveSynth
//
//  Created by Eric on 4/22/16.
//  Copyright © 2016 Eric George. All rights reserved.
//

#import "WaveSynthAU.h"

#import "BufferedAudioBus.hpp"
#import "Utility.h"
#import "WaveSynthProc.hpp"

@interface WaveSynthAU ()

@property (nonatomic, strong) AUAudioUnitBus *outputBus;
@property (nonatomic, strong) AUAudioUnitBusArray *outputBusArray;
@property (nonatomic, readwrite) AUParameterTree *parameterTree;

@end


@implementation WaveSynthAU
{
    // C++ members need to be ivars; they would be copied on access if they were properties.
    WaveSynthProc _kernel;
    BufferedOutputBus _outputBusBuffer;
}

@synthesize parameterTree = _parameterTree;
@synthesize selectedWaveform = _selectedWaveform;

- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription
                                     options:(AudioComponentInstantiationOptions)options
                                       error:(NSError **)outError
{
    self = [super initWithComponentDescription:componentDescription options:options error:outError];
    
    if (self == nil)
    {
        return nil;
    }
    
    // Initialize a default format for the busses.
    AVAudioFormat *defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:44100. channels:2];
    
    // Create a DSP kernel to handle the signal processing.
    _kernel.init(defaultFormat.channelCount, defaultFormat.sampleRate);
    
    // Create a parameter object for the volume.
    AudioUnitParameterOptions flags = kAudioUnitParameterFlag_IsWritable | kAudioUnitParameterFlag_IsReadable | kAudioUnitParameterFlag_DisplayLogarithmic;
    AUParameter *volumeParam = [AUParameterTree createParameterWithIdentifier:volumeParamKey name:@"Volume"
                                                                      address:WaveSynthProc::InstrumentParamVolume
                                                                          min:0.001 max:1.0 unit:kAudioUnitParameterUnit_Decibels unitName:nil
                                                                        flags: flags valueStrings:nil dependentParameters:nil];
    AUParameter *waveformParam = [AUParameterTree createParameterWithIdentifier:waveformParamKey name:@"Waveform"
                                                                      address:WaveSynthProc::InstrumentParamWaveform
                                                                          min:0 max:4 unit:kAudioUnitParameterUnit_Indexed unitName:nil
                                                                        flags: flags valueStrings:nil dependentParameters:nil];

    // Initialize the parameter values.
    volumeParam.value = 0.1;
    _kernel.setParameter(WaveSynthProc::InstrumentParamVolume, volumeParam.value);
    
    volumeParam.value = 0;
    _kernel.setParameter(WaveSynthProc::InstrumentParamWaveform, volumeParam.value);
    
    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
                                                               volumeParam,
                                                               waveformParam
                                                               ]];

    // Create the output bus.
    _outputBusBuffer.init(defaultFormat, 2);
    _outputBus = _outputBusBuffer.bus;
    
    // Create the input and output bus arrays.
    _outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self busType:AUAudioUnitBusTypeOutput busses: @[_outputBus]];
    
    // Make a local pointer to the kernel to avoid capturing self.
    __block WaveSynthProc *instrumentKernel = &_kernel;
    
    // implementorValueObserver is called when a parameter changes value.
    _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        instrumentKernel->setParameter(param.address, value);
    };
    
    // implementorValueProvider is called when the value needs to be refreshed.
    _parameterTree.implementorValueProvider = ^(AUParameter *param) {
        return instrumentKernel->getParameter(param.address);
    };
    
    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;
        
        switch (param.address)
        {
            case WaveSynthProc::InstrumentParamVolume:
            {
                return [NSString stringWithFormat:@"%.3f", value];
            }
            case WaveSynthProc::InstrumentParamWaveform:
            {
                return [NSString stringWithFormat:@"%d", (uint8_t)value];
            }
                
            default:
                return @"?";
        }
    };

    self.maximumFramesToRender = 512;
    
    return self;
}

- (OscillatorWave) selectedWaveform
{
    return (OscillatorWave)_kernel.getParameter(WaveSynthProc::InstrumentParamWaveform);
}

- (void) setSelectedWaveform:(OscillatorWave)selectedWaveform
{
    _kernel.setParameter(WaveSynthProc::InstrumentParamWaveform, selectedWaveform);
}

- (AUAudioUnitBusArray *)outputBusses
{
    return _outputBusArray;
}

- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError
{
    if (![super allocateRenderResourcesAndReturnError:outError])
    {
        return NO;
    }
    
    _outputBusBuffer.allocateRenderResources(self.maximumFramesToRender);
    
    _kernel.init(self.outputBus.format.channelCount, self.outputBus.format.sampleRate);
    _kernel.reset();
    
    return YES;
}

- (void)deallocateRenderResources
{
    [super deallocateRenderResources];
    
    _outputBusBuffer.deallocateRenderResources();
}

- (AUInternalRenderBlock)internalRenderBlock
{
    /*
     Capture in locals to avoid ObjC member lookups. If "self" is captured in
     render, we're doing it wrong.
     */
    __block WaveSynthProc *state = &_kernel;
    __block BufferedOutputBus *outputBusBuffer = &_outputBusBuffer;
    
    return ^AUAudioUnitStatus(
                              AudioUnitRenderActionFlags *actionFlags,
                              const AudioTimeStamp       *timestamp,
                              AVAudioFrameCount           frameCount,
                              NSInteger                   outputBusNumber,
                              AudioBufferList            *outputData,
                              const AURenderEvent        *realtimeEventListHead,
                              AURenderPullInputBlock      pullInputBlock)
    {
        outputBusBuffer->prepareOutputBufferList(outputData, frameCount, true);
        state->setBuffers(outputData);		
        state->processWithEvents(timestamp, frameCount, realtimeEventListHead);
        
        return noErr;
    };
}

@end

