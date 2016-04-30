//
//  WaveSynthAUViewController.m
//  AUInstrument
//
//  Created by Eric on 4/23/16.
//  Copyright © 2016 Eric George. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "WaveSynthAUViewController.h"
#import <WaveSynthFramework/WaveSynthAU.h>
#import "WaveSynthConstants.h"

static NSArray *_waveformNames;

@interface WaveSynthAUViewController ()
{
    IBOutlet UISlider *_volumeSlider;
    IBOutlet UIButton *_waveformButton;
    IBOutlet UILabel *_waveformLabel;
    
    AUParameter *_volumeParameter;
    AUParameter *_waveformParameter;
    AUParameterObserverToken *_parameterObserverToken;
}

@end

@implementation WaveSynthAUViewController

-(void)setAudioUnit:(WaveSynthAU *)audioUnit
{
    _audioUnit = audioUnit;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self isViewLoaded]) {
            [self connectViewWithAU];
        }
    });
}

-(WaveSynthAU *)getAudioUnit
{
    return _audioUnit;
}

- (void) connectViewWithAU
{
    AUParameterTree *parameterTree = self.audioUnit.parameterTree;
    
    if (parameterTree)
    {
        _volumeParameter = [parameterTree valueForKey:@"volume"];
        _waveformParameter = [parameterTree valueForKey:@"waveform"];
        
        _parameterObserverToken = [parameterTree tokenByAddingParameterObserver:^(AUParameterAddress address, AUValue value) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (address == _volumeParameter.address)
                {
                    [self updateVolume];
                }
                else if (address == _waveformParameter.address)
                {
                    [self updateWaveform];
                }
                
            });
        }];
        
        [self updateVolume];
    }

    [self updateVolume];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[_waveformButton layer] setBorderWidth:1.0f];
    [[_waveformButton layer] setBorderColor:[UIColor blackColor].CGColor];
    
    if (_audioUnit)
    {
        [self connectViewWithAU];
    }

    _waveformNames = @[@"Sine", @"Sawtooth", @"Square", @"Triangle"];
    
    OscillatorWave waveform = self.audioUnit.selectedWaveform;
    _waveformLabel.text = _waveformNames[waveform];
}

- (void) updateVolume
{
    _volumeSlider.value = _volumeParameter.value;
}

- (IBAction)volumeChanged:(UISlider *)sender
{
    _volumeParameter.value =  sender.value;
}

- (void) updateWaveform
{
    OscillatorWave waveform = self.audioUnit.selectedWaveform;
    _waveformLabel.text = _waveformNames[waveform];
}

- (IBAction)waveformChanged:(id)sender
{
    OscillatorWave waveform = self.audioUnit.selectedWaveform;
    if (waveform == OSCILLATOR_WAVE_LAST)
    {
        waveform = OSCILLATOR_WAVE_FIRST;
    }
    else
    {
        ++waveform;
    }
    
    self.audioUnit.selectedWaveform = waveform;
    _waveformLabel.text = _waveformNames[waveform];
}

@end
