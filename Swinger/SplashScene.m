//
//  SplashScene.m
//  Swinger
//
//  Created by Min Kwon on 7/2/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "SplashScene.h"
#import "TextureTypes.h"
#import "MainGameScene.h"
#import "MainMenuScene.h"
#import "AudioEngine.h"
#import "AudioManager.h"
#import "GPUtil.h"

@implementation SplashScene

- (id) init {
    self = [super init];
    if (self) {
        //CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        [self loadSpriteSheets];
        [self loadAudio];        
    }
    
    return self;
}

- (void) onEnter {
//    [[CCDirector sharedDirector] replaceScene:[MainGameScene node]];
    [[CCDirector sharedDirector] replaceScene:[MainMenuScene node]];
}

- (void) loadSpriteSheets {    
    g_currentWorldAtlas = nil;
    
    CCTexture2D *tex = [[CCTextureCache sharedTextureCache] addImage:[GPUtil getAtlasImageName:CHARACTER_ATLAS]];        
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[GPUtil getAtlasPList:CHARACTER_ATLAS] texture:tex];
    [tex setAliasTexParameters];
}

- (void) loadAudio {
    [[AudioManager sharedManager] startUp];
    [[AudioEngine sharedEngine] preloadBackgroundMusic:GAME_MUSIC];
    [[AudioEngine sharedEngine] preloadBackgroundMusic:MENU_MUSIC];
    [[AudioEngine sharedEngine] preloadEffect:SND_SWOOSH];
    [[AudioEngine sharedEngine] preloadEffect:SND_CHEER];
    [[AudioEngine sharedEngine] preloadEffect:SND_CHILDREN_AAH];
    [[AudioEngine sharedEngine] preloadEffect:SND_BLOP];
    [[AudioEngine sharedEngine] preloadEffect:SND_DIZZY];
    [[AudioEngine sharedEngine] preloadEffect:SND_FOLLY];
    [[AudioEngine sharedEngine] preloadEffect:SND_CANNON];
    [[AudioEngine sharedEngine] preloadEffect:SND_LOAD_CANNON];
    [[AudioEngine sharedEngine] preloadEffect:SND_HEART_BEAT];
    [[AudioEngine sharedEngine] preloadEffect:SND_WIND];
}

@end
