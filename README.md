# AUInstrument

AUInstrument can be used as a starting point for an Audio Unit v3 plugin for iOS.  It consists of 3 targets:

 - AUInstrumentDemoApp:  A stand alone application that hosts (and installs) the AU Extension
 - WaveSynthFramework:  The WaveSynth implementation
 - WaveSynthExtension:  The actual App Extension that can be loaded into GarageBand and other hosts.
 
The following resources were helpful in putting together this project:
 - The main sample from Apple that demonstrates AU v3 and AU v3 Host implementation:  https://developer.apple.com/library/ios/samplecode/AudioUnitV3Example/Introduction/Intro.html
 - MIKMIDI Objective C MIDI library by Mixed In Key:  https://github.com/mixedinkey-opensource/MIKMIDI
 - Martin Finke's Audio Plug-In Tutorial:  http://www.martin-finke.de/blog/
 
The App Extension has been tested in both GarageBand and Cubasis on an iPad Air.  It is a single oscillator that has naive implementations for sine, saw, square and triangle waveform.  It doesn't sound very good, nor does it have an envelope or polyphony.  But it is a good starting point for an iOS AU plug-in and has all of the internal plumbing, including MIDI keyboard handling and parameter changing, hooked up.  All you need to do is write some reasonable DSP and UI and you can have a basic synth iOS AU Extension.

