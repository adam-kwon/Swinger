//
//  AudioEngine.m
//  apocalypsemmxii
//
//  Created by min on 4/6/11.
//  Copyright 2011 GAMEPEONS LLC. All rights reserved.
//

#import "AudioEngine.h"
#import "UserData.h"

@implementation AudioEngine

@synthesize customMusicLoadingStatus;
@synthesize isAlienPlaying;

static AudioEngine *sharedEngine = nil;
static CDSoundEngine *soundEngine = nil;
static CDAudioManager *am = nil;
static CDBufferManager *bufferManager = nil;

+ (AudioEngine *) sharedEngine {
	@synchronized(self)     {
		if (!sharedEngine) {
			sharedEngine = [[AudioEngine alloc] init];
        }
	}
	return sharedEngine;
}

+ (id) alloc {
	@synchronized(self)     {
		NSAssert(sharedEngine == nil, @"Attempted to allocate a second instance of a singleton.");
		return [super alloc];
	}
	return nil;
}

- (void) loadSoundBuffers:(NSObject*)data {
    // Wait for the audio manager if it is not initialized yet
    while ([CDAudioManager sharedManagerState] != kAMStateInitialised) {
        [NSThread sleepForTimeInterval:0.1];
    }
    
    // Load the buffers with audio data. There is no correspondence between voices/channels and
	// buffers.  For example you can play the same sound in multiple channel groups with different
	// pitch, pan and gain settings.
    //
	// Buffers can be loaded with different sounds simply by calling loadBuffer again, however,
	// any sources attached to the buffer will be stopped if they are currently playing
	// Use: afconvert -f caff -d ima4 yourfile.wav to create an ima4 compressed version of a wave file
	CDSoundEngine *sse = [CDAudioManager sharedManager].soundEngine;
    
	NSArray *defs = [NSArray arrayWithObjects:
                     [NSNumber numberWithInt:1],        // index 0, 1 voice available
                     [NSNumber numberWithInt:1],        // index 1, 1 voice available
                     [NSNumber numberWithInt:4],        // index 2
                     [NSNumber numberWithInt:1],        // index 2, 8 voices available
                     [NSNumber numberWithInt:19],       // index 3, 16 voices available
                     [NSNumber numberWithInt:2],        // index 4, 2 voices available 
                     [NSNumber numberWithInt:4],        // index 5, 4 voices available
                     nil];   
	[sse defineSourceGroups:defs];
    
	
	// Load sound buffers asynchrounously    
    //	NSMutableArray *loadRequests = [[[NSMutableArray alloc] init] autorelease];
    //	[loadRequests addObject:[[[CDBufferLoadRequest alloc] init:SND_ID_BOMB filePath:@"bomb_hit.caf"] autorelease]];
    //	[sse loadBuffersAsynchronously:loadRequests];
    //	_appState = kAppStateSoundBuffersLoading;
    
	// Load sound buffers synchronously
    //    [sse loadBuffer:SND_ID_BACKGROUND filePath:@GAME_MUSIC];
    
//    [sse loadBuffer:SND_ID_BOMB filePath:@"bomb_hit.caf"];
//    [sse loadBuffer:SND_ID_HEARTBEAT filePath:@"heartBeat1.aiff"];
//    [sse loadBuffer:SND_ID_CRUMBLE filePath:@"crumble.caf"];
//    [sse loadBuffer:SND_ID_JUMP filePath:@"jump.caf"];
    //    [sse loadBuffer:SND_ID_FOOTSTEP1 filePath:@"foot1.caf"];
    //    [sse loadBuffer:SND_ID_FOOTSTEP2 filePath:@"foot2.caf"];
	
    // Sound engine is now set up. You can check the functioning property to see if everything worked.
	// In addition the loadBuffer method returns a boolean indicating whether it worked.
	// If your buffers loaded and the functioning = TRUE then you are set to play sounds.
    CDLOG(@"**** Sound buffers initialized");
}

- (ALuint) playEffect:(NSString*)filePath loop:(BOOL)loop {
    return [self playEffect:filePath sourceGroupId:CGROUP2_4VOICE pitch:1.0f pan:0.0f gain:1.0f loop:loop];        
}

- (void) stopAllEffects {
    for (int i = 0; i < counter; i++) {
        [self stopEffect:playingEffects[i]];
    }
    counter = 0;
}

- (ALuint) playEffect:(NSString*)filePath sourceGroupId:(int)sourceGroupId pitch:(Float32)pitch pan:(Float32)pan gain:(Float32)gain loop:(BOOL)loop {
    if ([SND_SPACE_SHIP isEqualToString:filePath] && isAlienPlaying) {
        return CD_MUTE;
    } else if ([SND_SPACE_SHIP isEqualToString:filePath]) {
        isAlienPlaying = YES;
    }
    
    int soundId = [bufferManager bufferForFile:filePath create:YES];
    if (soundId != kCDNoBuffer) {
        ALuint effectId = [soundEngine playSound:soundId sourceGroupId:sourceGroupId pitch:pitch pan:pan gain:gain loop:loop];
        playingEffects[counter++] = effectId;
        if (counter >= PLAYING_SIZE) {
            counter = 0;
        }
        return effectId;
    } else {
        return CD_MUTE;
    }	    
}

- (ALuint) playEffect:(NSString*)filePath sourceGroupId:(int)sourceGroupId {
	return [self playEffect:filePath sourceGroupId:sourceGroupId pitch:1.0f pan:0.0f gain:1.0f loop:false];    
}

- (ALuint) playEffect:(NSString*)filePath sourceGroupId:(int)sourceGroupId gain:(Float32)gain {
    return [self playEffect:filePath sourceGroupId:sourceGroupId pitch:1.0f pan:0.0f gain:gain loop:false];
}


- (ALuint) playEffect:(NSString*)filePath {
	return [self playEffect:filePath sourceGroupId:CGROUP3_16VOICE pitch:1.0f pan:0.0f gain:1.0f loop:false];
}

- (ALuint) playEffect:(NSString*)filePath gain:(Float32)gain {
    return [self playEffect:filePath sourceGroupId:CGROUP3_16VOICE pitch:1.0f pan:0.0f gain:gain loop:false];    
}

- (ALuint) playEffect:(NSString*)filePath gain:(Float32)gain loop:(BOOL)loop {
    return [self playEffect:filePath sourceGroupId:CGROUP3_16VOICE pitch:1.0f pan:0.0f gain:gain loop:loop];
}


- (ALuint) playEffect:(NSString*)filePath pitch:(Float32)pitch pan:(Float32)pan gain:(Float32)gain {
    return [self playEffect:filePath sourceGroupId:CGROUP3_16VOICE pitch:pitch pan:pan gain:gain loop:false];    
}

- (ALuint) playEffect:(NSString*)filePath pitch:(Float32)pitch {
    return [self playEffect:filePath sourceGroupId:CGROUP3_16VOICE pitch:pitch pan:0.0f gain:1.0f loop:false];    
}

- (void) stopEffect:(ALuint) soundId {
	[soundEngine stopSound:soundId];
}	


- (void) preloadEffect:(NSString*) filePath {
	int soundId = [bufferManager bufferForFile:filePath create:YES];
	if (soundId == kCDNoBuffer) {
		CDLOG(@"Denshion::SimpleAudioEngine sound failed to preload %@",filePath);
	}
}

- (void) unloadEffect:(NSString*) filePath {
	CDLOGINFO(@"Denshion::SimpleAudioEngine unloadedEffect %@",filePath);
	[bufferManager releaseBufferForFile:filePath];
}

- (id) init {
	if((self=[super init])) {        

		am = [CDAudioManager sharedManager];
		soundEngine = am.soundEngine;
		bufferManager = [[CDBufferManager alloc] initWithEngine:soundEngine];
		mute_ = NO;
		enabled_ = YES;
        ipodPlayer = nil;
        customMusicLoadingStatus = kCustomMusicLoadingNone;
        counter = 0;
        
        if ([CDAudioManager sharedManagerState] != kAMStateInitialised) {
            //The audio manager is not initialised yet so kick off the sound loading as an NSOperation that will wait for the audio manager
            NSInvocationOperation* bufferLoadOp = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadSoundBuffers:) object:nil] autorelease];
            NSOperationQueue *opQ = [[[NSOperationQueue alloc] init] autorelease]; 
            [opQ addOperation:bufferLoadOp];        
        } else {
            [self loadSoundBuffers:nil];
        } 
	}
	return self;
}


- (void) setNotificationCallBack:(id)cbo onSelector:(SEL)selector {
    callBackObject = cbo;
    callBackSelector = selector;
}

- (void) nowPlayingItemChanged:(id)notification {
    // Debug code
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Really reset?" message:@"Do you really want to reset this game?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil] autorelease];
    // optional - add more buttons:
    [alert addButtonWithTitle:@"Yes"];
    [alert show];

    [callBackObject performSelector:callBackSelector];
}

- (BOOL)isHeadsetPluggedIn {
    UInt32 routeSize = sizeof (CFStringRef);
    CFStringRef route;
    
    OSStatus error = AudioSessionGetProperty (kAudioSessionProperty_AudioRoute,
                                              &routeSize,
                                              &route);
    
    /* Known values of route:
     * "Headset"
     * "Headphone"
     * "Speaker"
     * "SpeakerAndMicrophone"
     * "HeadphonesAndMicrophone"
     * "HeadsetInOut"
     * "ReceiverAndMicrophone"
     * "Lineout"
     */
    
    if (!error && (route != NULL)) {
        
        NSString* routeStr = (NSString*)route;
        
        NSRange headphoneRange = [routeStr rangeOfString : @"Head"];
        
        if (headphoneRange.location != NSNotFound) {
            return YES;
        }        
    }
    
    return NO;
}

- (void) initIpodPlayer {    
    if (nil == ipodPlayer) {
        ipodPlayer = [MPMusicPlayerController applicationMusicPlayer];
        customMusicVolume = [ipodPlayer volume];
        if (customMusicVolume >= 0.5) {
            // If volume of iPod player is set to max and earphones are plugged in, then reduce the
            // volume so that it doesn't rip out the player's eardrums!
            if ([self isHeadsetPluggedIn]) {
                customMusicVolume = 0.5;
                [ipodPlayer setVolume:customMusicVolume];
            }
        }

        //NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        //[notificationCenter addObserver:self selector:@selector(nowPlayingItemChanged:) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:ipodPlayer];
        //[ipodPlayer beginGeneratingPlaybackNotifications];
    }    
}

- (void) setCustomMusicLibrary:(MPMediaItemCollection*)collection {
    [self initIpodPlayer];
    [ipodPlayer setQueueWithItemCollection:collection];
}

- (void) loadCustomMusic {
    if (customMusicLoadingStatus == kCustomMusicLoading) {
        CCLOG(@"**** Custom Music already loading in background");
        return;
    }
    customMusicLoadingStatus = kCustomMusicLoading;
    [self initIpodPlayer];
    ipodPlayer = [MPMusicPlayerController applicationMusicPlayer];
    [[UserData sharedInstance] loadPlayList];
    MPMediaItemCollection *collection = [[UserData sharedInstance] playList];
    if (nil == collection) {
        [ipodPlayer setQueueWithQuery:[MPMediaQuery songsQuery]];
    } else {
        [ipodPlayer setQueueWithItemCollection:collection];
    } 
    customMusicLoadingStatus = kCustomMusicFinishedLoading;
}

- (void) playCustomMusic {
    [ipodPlayer play];
}

- (void) setBackgroundMusicVolume:(float)volume {
    if (nil == ipodPlayer) {
        [super setBackgroundMusicVolume:volume];
    } else {
        // MPMusicPlayerController's volume changes the master volume also affecting the OpenAL volume. It's kind of useless for
        // finer grained control, where we need to have the sound fx at one volume and the bg at another. So just disable for now.
        //[ipodPlayer setVolume:volume];
    }
}

- (void) preloadBackgroundMusic:(NSString*)filePath {
#if GAMEPLAY == 0
	[am preloadBackgroundMusic:filePath];
#endif
}

- (void) playBackgroundMusic:(NSString*)filePath {
#if GAMEPLAY == 0
	[am playBackgroundMusic:filePath loop:TRUE];
#endif
}

- (void) playBackgroundMusic:(NSString*)filePath loop:(BOOL)loop {
#if GAMEPLAY == 0
	[am playBackgroundMusic:filePath loop:loop];
#endif
}

- (void) stopMenuMusic {
    [am stopBackgroundMusic];
}

- (void) stopBackgroundMusic {
    if ([[UserData sharedInstance] isCustomMusic]) {
        [ipodPlayer stop];
    } else {
        [am stopBackgroundMusic];
    }
}

- (void) pauseBackgroundMusic {
    if ([[UserData sharedInstance] isCustomMusic]) {
        [ipodPlayer pause];
    } else {
        [am pauseBackgroundMusic];
    }
}	

- (void) resumeBackgroundMusic {
#if GAMEPLAY == 0
    if ([[UserData sharedInstance] isCustomMusic]) {
        [ipodPlayer play];
    } else {
        [am resumeBackgroundMusic];
    }
#endif
}	

- (void) rewindBackgroundMusic {
#if GAMEPLAY == 0
    if ([[UserData sharedInstance] isCustomMusic]) {
        [ipodPlayer skipToBeginning];
    } else {
        [am rewindBackgroundMusic];
    }
#endif
}

- (BOOL) isBackgroundMusicPlaying {
    if ([[UserData sharedInstance] isCustomMusic]) {
        return (ipodPlayer.playbackState == MPMusicPlaybackStatePlaying);
    } else {
        return [am isBackgroundMusicPlaying];
    }
}	

-(BOOL) willPlayBackgroundMusic {
	return [am willPlayBackgroundMusic];
}

+ (void) end {
	am = nil;
	[CDAudioManager end];
	[bufferManager release];
	[sharedEngine release];
	sharedEngine = nil;    
}

- (void) dealloc {
    am = nil;
    soundEngine = nil;
    bufferManager = nil;
    [super dealloc];
}

#pragma mark Audio Interrupt Protocol
-(BOOL) mute {
	return mute_;
}

-(void) setMute:(BOOL) muteValue {
	if (mute_ != muteValue) {
		mute_ = muteValue;
		am.mute = mute_;
	}	
}

-(BOOL) enabled {
	return enabled_;
}

-(void) setEnabled:(BOOL) enabledValue {
	if (enabled_ != enabledValue) {
		enabled_ = enabledValue;
		am.enabled = enabled_;
	}	
}

@end
