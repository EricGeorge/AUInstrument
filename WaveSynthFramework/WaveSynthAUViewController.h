//
//  WaveSynthAUViewController.h
//  AUInstrument
//
//  Created by Eric on 4/23/16.
//  Copyright © 2016 Eric George. All rights reserved.
//

#import <CoreAudioKit/AUViewController.h>

@class WaveSynthAU;

@interface WaveSynthAUViewController : AUViewController

@property (nonatomic)WaveSynthAU *audioUnit;

@end
