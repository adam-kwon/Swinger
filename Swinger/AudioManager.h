//
//  AudioManager.h
//  Swinger
//
//  Created by Min Kwon on 6/10/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "AudioEngine.h"

@interface AudioManager : CCNode {
    BOOL            isPlayerLaunched;
    BOOL            heartBeatPlaying;
    BOOL            windPlaying;
    ALuint          windSnd;
    ALuint          heartBeatSnd;
    float           coinObtainedPitch;
    CFTimeInterval  lastPlayedCoinObtained;
}

+ (AudioManager *) sharedManager;
- (void) playChildrenAah;
- (void) startUp;
- (void) playHeartBeat;
- (void) stopHeartBeat;
- (void) playCoinObtained;
- (void) playWind;
- (void) stopWind;
- (void) reset;

@end
