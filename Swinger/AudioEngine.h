//
//  AudioEngine.h
//  apocalypsemmxii
//
//  Created by Min Kwon on 4/6/11.
//  Copyright 2011 GAMEPEONS LLC. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "SimpleAudioEngine.h"
#import "Constants.h"
#import "AudioConstants.h"

/*
 * Channel group IDs. The channel groups define how voices will be shared. If you wish to simply have
 * a single channel group and all sounds will share all the voices.
 */
#define CGROUP0_1VOICE           0
#define CGROUP1_1VOICE           1
#define CGROUP2_4VOICE           2
#define CGROUP2A_1VOICE          3
#define CGROUP3_16VOICE          4
#define CGROUP4_2VOICE           5
#define CGROUP5_4VOICE           6


#define PLAYING_SIZE             10

typedef enum {
    kCustomMusicLoadingNone,
    kCustomMusicLoading,
    kCustomMusicFinishedLoading
} CustomMusicLoadingType;

@interface AudioEngine : SimpleAudioEngine {
    int                         counter;
    ALuint                      playingEffects[PLAYING_SIZE];
    MPMusicPlayerController     *ipodPlayer;
    CustomMusicLoadingType      customMusicLoadingStatus;
    id                          callBackObject;
    SEL                         callBackSelector;
    float                       customMusicVolume;
    BOOL                        isAlienPlaying;
}

+ (AudioEngine *) sharedEngine;
+ (void) end;

- (void) setNotificationCallBack:(id)cbo onSelector:(SEL)selector;
- (void) preloadEffect:(NSString*)filePath;
- (void) unloadEffect:(NSString*)filePath;
- (void) stopEffect:(ALuint)soundId;
- (void) stopAllEffects;
- (ALuint) playEffect:(NSString*)filePath;
- (ALuint) playEffect:(NSString*)filePath loop:(BOOL)loop;
- (ALuint) playEffect:(NSString*)filePath gain:(Float32)gain loop:(BOOL)loop;
- (ALuint) playEffect:(NSString*)filePath pitch:(Float32)pitch;
- (ALuint) playEffect:(NSString*)filePath gain:(Float32)gain;
- (ALuint) playEffect:(NSString*)filePath pitch:(Float32)pitch pan:(Float32)pan gain:(Float32)gain;
- (ALuint) playEffect:(NSString*)filePath sourceGroupId:(int)sourceGroupId;
- (ALuint) playEffect:(NSString*)filePath sourceGroupId:(int)sourceGroupId gain:(Float32)gain;
- (ALuint) playEffect:(NSString*)filePath sourceGroupId:(int)sourceGroupId pitch:(Float32)pitch pan:(Float32)pan gain:(Float32)gain loop:(BOOL)loop;
- (void) setBackgroundMusicVolume:(float)volume;
- (void) playBackgroundMusic:(NSString*)filePath;
- (void) playBackgroundMusic:(NSString*)filePath loop:(BOOL)loop;
- (void) stopBackgroundMusic;
- (void) stopMenuMusic;
- (void) pauseBackgroundMusic;
- (void) resumeBackgroundMusic;
- (void) rewindBackgroundMusic;
- (BOOL) isBackgroundMusicPlaying;
- (void) loadCustomMusic;
- (void) playCustomMusic;
- (void) setCustomMusicLibrary:(MPMediaItemCollection*)collection;

@property (nonatomic, readwrite, assign) CustomMusicLoadingType customMusicLoadingStatus;
@property (nonatomic, readwrite, assign) BOOL isAlienPlaying;

@end
