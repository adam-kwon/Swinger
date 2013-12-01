//
//  AudioManager.m
//  Swinger
//
//  Created by Min Kwon on 6/10/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "AudioManager.h"
#import "Notifications.h"
#import "UserData.h"

@interface AudioManager(Private)
- (void)playerCaught:(NSNotification *)notification;
- (void)gameOver:(NSNotification *)notification;
@end

@implementation AudioManager

static AudioManager *sharedManager = nil;

+ (AudioManager *) sharedManager {
	@synchronized(self)     {
		if (!sharedManager) {
			sharedManager = [[AudioManager alloc] init];
        }
	}
	return sharedManager;
}

+ (id) alloc {
	@synchronized(self)     {
		NSAssert(sharedManager == nil, @"Attempted to allocate a second instance of a singleton.");
		return [super alloc];
	}
	return nil;
}

- (id) init {
	if((self=[super init])) {        
        coinObtainedPitch = 0.5f;
        lastPlayedCoinObtained = -1.0f;
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(playerCaught:) 
                                                     name:NOTIFICATION_PLAYER_CAUGHT 
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(gameOver:) 
                                                     name:NOTIFICATION_GAME_OVER 
                                                   object:nil];

        /*[[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(windBlowing:) 
                                                     name:NOTIFICATION_WIND_BLOWING 
                                                   object:nil];*/
	}
	return self;
}

- (void) startUp {
    isPlayerLaunched = NO;
}

- (void)playerCaught:(NSNotification *)notification {
    isPlayerLaunched = NO;
}

- (void)gameOver:(NSNotification *)notification {
    //[self stopWind];
    //isPlayerLaunched = NO;
    [self reset];
}

- (void) stopHeartBeat {
    if (heartBeatPlaying) {
        [[AudioEngine sharedEngine] stopEffect:heartBeatSnd];
        [[AudioEngine sharedEngine] setBackgroundMusicVolume:[[UserData sharedInstance] musicVolumeLevel]];
        heartBeatPlaying = NO;
    }    
}

- (void) playHeartBeat {
    if (!heartBeatPlaying) {
        heartBeatPlaying = YES;
        [[AudioEngine sharedEngine] setBackgroundMusicVolume:[[UserData sharedInstance] musicVolumeLevel]/2.f];            
        heartBeatSnd = [[AudioEngine sharedEngine] playEffect:SND_HEART_BEAT gain:30 loop:YES];
    }
}

- (void) windBlowing: (NSNotification *) notification {
    if (notification.object != nil) {
        [self stopWind];
        [self playWind];
    } else {
        [self stopWind];
    }
    
}

- (void) playCoinObtained {
    if (lastPlayedCoinObtained < 0 || (CFAbsoluteTimeGetCurrent() - lastPlayedCoinObtained) > 0.5) {
        coinObtainedPitch = 0.5f;
    } else {
        coinObtainedPitch = MIN(2.0, coinObtainedPitch + 0.1);
    }
    
    [[AudioEngine sharedEngine] playEffect:SND_BLOP pitch:coinObtainedPitch];
    
    lastPlayedCoinObtained = CFAbsoluteTimeGetCurrent();

}

- (void) playWind {
    if (!windPlaying) {
        windPlaying = YES;
        windSnd = [[AudioEngine sharedEngine] playEffect:SND_WIND gain:0.3 loop:YES];
    }
}

- (void) stopWind {
    if (windPlaying) {
        [[AudioEngine sharedEngine] stopEffect:windSnd];
        windPlaying = NO;
    }
}

- (void) playChildrenAah {
    if (!isPlayerLaunched) {
        isPlayerLaunched = YES;
        [[AudioEngine sharedEngine] playEffect:SND_CHILDREN_AAH];
    }
}

- (void) reset {
    [self stopHeartBeat];
    [self stopWind];
    heartBeatPlaying = NO;
    windPlaying = NO;
    isPlayerLaunched = NO;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_GAME_OVER object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PLAYER_CAUGHT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_WIND_BLOWING object:nil];
    
    [super dealloc];
}
@end
