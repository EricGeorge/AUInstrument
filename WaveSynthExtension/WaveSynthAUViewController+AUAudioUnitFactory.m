//
//  WaveSynthAUViewController_AUAudioUnitFactory.m
//  AUInstrument
//
//  Created by Eric on 4/23/16.
//  Copyright © 2016 Eric George. All rights reserved.
//

#import "WaveSynthAUViewController+AUAudioUnitFactory.h"

@implementation WaveSynthAUViewController (AUAudioUnitFactory)

- (WaveSynthAU *) createAudioUnitWithComponentDescription:(AudioComponentDescription) desc error:(NSError **)error
{
    self.audioUnit = [[WaveSynthAU alloc] initWithComponentDescription:desc error:error];
    return self.audioUnit;
}

@end
