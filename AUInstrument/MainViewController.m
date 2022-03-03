//
//  MainViewController.m
//  AUInstrument
//
//  Created by Eric on 4/18/16.
//  Copyright © 2016 Eric George. All rights reserved.
//

#import "MainViewController.h"

@import AudioUnit;
#import <WaveSynthFramework/WaveSynthFramework.h>

#import "AudioEngine.h"
#import "MIDILogs.h"
#import "MIDIManager.h"

@interface MainViewController ()
{
    AudioEngine *_audioEngine;
    AUParameter *_volumeParameter;
    AUParameterObserverToken *_parameterObserverToken;
}

@property (strong, nonatomic) IBOutlet UIView *auContainerView;
@property (strong, nonatomic) WaveSynthAUViewController *waveSynthViewController;
@property (strong, nonatomic) IBOutlet UILabel *volumeLabel;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MIDIManager *midiManager = MIDIManager.sharedMIDIManager;
    midiManager.delegate = self;

    [self embedPlugInView];
    
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_MusicDevice;
    desc.componentSubType = 0x77617665; /*'wave'*/
    desc.componentManufacturer = 0x44656d6f; /*'Demo'*/
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    
    [AUAudioUnit registerSubclass:WaveSynthAU.self asComponentDescription:desc name:@"Local WaveSynth" version:1];
    
    _audioEngine = [[AudioEngine alloc] init];
    [_audioEngine setupAUWithComponentDescription:desc andCompletion:^{
        [self connectParametersToControls];
    }];
}

- (void) embedPlugInView
{
    NSURL *builtInPlugInsURL = [[NSBundle mainBundle] builtInPlugInsURL];
    NSURL *pluginURL = [builtInPlugInsURL URLByAppendingPathComponent:(@"WaveSynthExtension.appex")];
    NSBundle *appExtensionBundle = [[NSBundle alloc] initWithURL:pluginURL];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainInterface" bundle:appExtensionBundle];
    
    self.waveSynthViewController = [storyboard instantiateInitialViewController];
    
    UIView *view = self.waveSynthViewController.view;
    if (view)
    {
        [self addChildViewController:self.waveSynthViewController];
        view.frame = self.auContainerView.bounds;
        
        [self.auContainerView addSubview:view];
        [self.waveSynthViewController didMoveToParentViewController:self];
    }
}

- (void) connectParametersToControls
{
    AUParameterTree *parameterTree = _audioEngine.synthAU.parameterTree;
    
    if (parameterTree)
    {
        self.waveSynthViewController.audioUnit = (WaveSynthAU *)_audioEngine.synthAU;
        
        _volumeParameter = [parameterTree valueForKey:volumeParamKey];
        
        __weak __typeof(self) weakSelf = self;
        _parameterObserverToken = [parameterTree tokenByAddingParameterObserver:^(AUParameterAddress address, AUValue value) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                __strong __typeof(weakSelf) Self = weakSelf;
                if (Self) {
                    if (address == Self->_volumeParameter.address) {
                        [Self updateVolume];
                    }
                }
            });
        }];
        
        [self updateVolume];
    }
}

- (void) updateVolume
{
    self.volumeLabel.text = [_volumeParameter stringFromValue:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) handleMidiEvent:(uint8_t)status
             withChannel:(uint8_t)channel
               withData1:(uint8_t)data1
               withData2:(uint8_t)data2
          withStartFrame:(uint64_t)startFrame
{
    MusicDeviceMIDIEvent(_audioEngine.synth,
                         status,
                         data1,
                         data2,
                         0);
}

@end
