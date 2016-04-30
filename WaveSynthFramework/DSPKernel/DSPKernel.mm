/*
	Taken directly from Audio Unit v3 Sample Code:  https://developer.apple.com/library/ios/samplecode/AudioUnitV3Example/Introduction/Intro.html
 */

#import "DSPKernel.hpp"

void DSPKernel::handleOneEvent(AURenderEvent const *event)
{
	switch (event->head.eventType)
    {
		case AURenderEventParameter:
		case AURenderEventParameterRamp:
        {
			AUParameterEvent const& paramEvent = event->parameter;
			
			startRamp(paramEvent.parameterAddress, paramEvent.value, paramEvent.rampDurationSampleFrames);
			break;
		}
			
		case AURenderEventMIDI:
			handleMIDIEvent(event->MIDI);
			break;
		
		default:
			break;
	}
}

void DSPKernel::performAllSimultaneousEvents(AUEventSampleTime now, AURenderEvent const *&event)
{
	do
    {
		handleOneEvent(event);

		// Go to next event.
		event = event->head.next;
		
		// While event is not null and is simultaneous.
	} while (event && event->head.eventSampleTime == now);
}

/**
	This function handles the event list processing and rendering loop for you.
	Call it inside your internalRenderBlock.
*/
void DSPKernel::processWithEvents(AudioTimeStamp const *timestamp, AUAudioFrameCount frameCount, AURenderEvent const *events)
{

	AUEventSampleTime now = AUEventSampleTime(timestamp->mSampleTime);
	AUAudioFrameCount framesRemaining = frameCount;
	AURenderEvent const *event = events;
	
	while (framesRemaining > 0)
    {
		// If there are no more events, we can process the entire remaining segment and exit.
		if (event == nullptr)
        {
			AUAudioFrameCount const bufferOffset = frameCount - framesRemaining;
			process(framesRemaining, bufferOffset);
			return;
		}

		AUAudioFrameCount const framesThisSegment = AUAudioFrameCount(event->head.eventSampleTime - now);

		// Compute everything before the next event.
		if (framesThisSegment > 0)
        {
			AUAudioFrameCount const bufferOffset = frameCount - framesRemaining;
            
			process(framesThisSegment, bufferOffset);
							
			// Advance frames.
			framesRemaining -= framesThisSegment;

			// Advance time.
			now += AUEventSampleTime(framesThisSegment);
		}
		
		performAllSimultaneousEvents(now, event);
	}
}

