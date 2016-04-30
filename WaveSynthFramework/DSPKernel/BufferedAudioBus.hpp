/*
	Taken directly from Audio Unit v3 Sample Code:  https://developer.apple.com/library/ios/samplecode/AudioUnitV3Example/Introduction/Intro.html
*/

#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>

// Reusable non-ObjC class, accessible from render thread.
struct BufferedAudioBus
{
	AUAudioUnitBus* bus = nullptr;
	AUAudioFrameCount maxFrames = 0;
    
	AVAudioPCMBuffer* pcmBuffer = nullptr;
    
	AudioBufferList const* originalAudioBufferList = nullptr;
	AudioBufferList* mutableAudioBufferList = nullptr;

	void init(AVAudioFormat* defaultFormat, AVAudioChannelCount maxChannels)
    {
		maxFrames = 0;
		pcmBuffer = nullptr;
		originalAudioBufferList = nullptr;
		mutableAudioBufferList = nullptr;
		
        bus = [[AUAudioUnitBus alloc] initWithFormat:defaultFormat error:nil];

        bus.maximumChannelCount = maxChannels;
	}
	
	void allocateRenderResources(AUAudioFrameCount inMaxFrames)
    {
		maxFrames = inMaxFrames;
		
		pcmBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:bus.format frameCapacity: maxFrames];
		
        originalAudioBufferList = pcmBuffer.audioBufferList;
        mutableAudioBufferList = pcmBuffer.mutableAudioBufferList;
	}
	
	void deallocateRenderResources()
    {
		pcmBuffer = nullptr;
		originalAudioBufferList = nullptr;
		mutableAudioBufferList = nullptr;
	}
};

/*
	`BufferedOutputBus`
	This class provides a prepareOutputBufferList method to copy the internal buffer pointers 
	to the output buffer list in case the client passed in null buffer pointers.
*/
struct BufferedOutputBus: BufferedAudioBus
{
	void prepareOutputBufferList(AudioBufferList* outBufferList, AVAudioFrameCount frameCount, bool zeroFill)
    {
		UInt32 byteSize = frameCount * sizeof(float);
		for (UInt32 i = 0; i < outBufferList->mNumberBuffers; ++i)
        {
			outBufferList->mBuffers[i].mNumberChannels = originalAudioBufferList->mBuffers[i].mNumberChannels;
			outBufferList->mBuffers[i].mDataByteSize = byteSize;
			if (outBufferList->mBuffers[i].mData == nullptr)
            {
				outBufferList->mBuffers[i].mData = originalAudioBufferList->mBuffers[i].mData;
			}
			if (zeroFill)
            {
				memset(outBufferList->mBuffers[i].mData, 0, byteSize);
			}
		}
	}
};

/*
	`BufferedInputBus`
	This class manages a buffer into which an audio unit with input busses can 
    pull its input data.
*/
struct BufferedInputBus : BufferedAudioBus
{
	/*
        Gets input data for this input by preparing the input buffer list and pulling
        the pullInputBlock.
    */
	AUAudioUnitStatus pullInput(AudioUnitRenderActionFlags *actionFlags,
								AudioTimeStamp const* timestamp,
								AVAudioFrameCount frameCount,
								NSInteger inputBusNumber,
								AURenderPullInputBlock pullInputBlock)
    {
        if (pullInputBlock == nullptr)
        {
			return kAudioUnitErr_NoConnection;
		}
		
		prepareInputBufferList();
		
		return pullInputBlock(actionFlags, timestamp, frameCount, inputBusNumber, mutableAudioBufferList);
	}

    /*
    	\c prepareInputBufferList populates the \c mutableAudioBufferList with the data
        pointers from the \c originalAudioBufferList.

        The upstream audio unit may overwrite these with its own pointers, so each
        render cycle this function needs to be called to reset them.
	*/
    void prepareInputBufferList()
    {
        UInt32 byteSize = maxFrames * sizeof(float);
		
        mutableAudioBufferList->mNumberBuffers = originalAudioBufferList->mNumberBuffers;
		
        for (UInt32 i = 0; i < originalAudioBufferList->mNumberBuffers; ++i)
        {
            mutableAudioBufferList->mBuffers[i].mNumberChannels = originalAudioBufferList->mBuffers[i].mNumberChannels;
            mutableAudioBufferList->mBuffers[i].mData = originalAudioBufferList->mBuffers[i].mData;
            mutableAudioBufferList->mBuffers[i].mDataByteSize = byteSize;
        }
    }
};

