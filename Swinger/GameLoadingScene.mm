//
//  GameLoadingScene.m
//  Swinger
//
//  Created by Isonguyo Udoka on 9/26/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "GameLoadingScene.h"
#import "MainGameScene.h"
#import "StoreScene.h"
#import "WorldSelectScene.h"
#import "LevelSelectScene.h"
#import "CCLayerColor+extension.h"
#import "GPUtil.h"
#import "TextureTypes.h"
#import "AudioEngine.h"

@implementation GameLoadingScene

+ (id) nodeWithDelay: (float) delay goTo: (GoToScene) theNextScene {
    return [[[self alloc] initWithDelay:delay goTo: theNextScene world:nil level: 0] autorelease];
}

+ (id) nodeWithDelay: (float) delay goTo: (GoToScene) theNextScene world: (NSString*) worldName {
    return [[[self alloc] initWithDelay:delay goTo: theNextScene world:worldName level: 0] autorelease];
}

+ (id) nodeWithDelay: (float) delay goTo: (GoToScene) theNextScene world: (NSString*) worldName level: (float) theLevel {
    return [[[self alloc] initWithDelay:delay goTo: theNextScene world:worldName level: theLevel] autorelease];
}

- (id) initWithDelay: (float) delay goTo: (GoToScene) theNextScene world: (NSString*) worldName level: (float) theLevel {
    
    if ((self = [super init])) {
        [self loadSpriteSheets];
        screenSize = [CCDirector sharedDirector].winSize;
        
        nextScene = theNextScene;
        world = worldName;
        level = theLevel;
        
        CCSprite * wallPaper = [CCSprite spriteWithSpriteFrameName:@"L1a_Background.png"];
        wallPaper.scale = 1.2f;
        wallPaper.anchorPoint = CGPointZero;
        wallPaper.position = CGPointZero;
        [self addChild: wallPaper z:-2];
        
        // shadow
        CCLayerColor * shadow = [CCLayerColor getFullScreenLayerWithColor:ccc3to4(CC3_COLOR_STEEL_BLUE, 50)];
        shadow.anchorPoint = CGPointZero;
        shadow.position = CGPointZero;
        [self addChild:shadow z:-1];
        
        CCSprite *logo = [CCSprite spriteWithFile:@"SwingStarLogo.png"];
        logo.anchorPoint = ccp(0,1);
        logo.scale = 0.5;
        logo.position = CGPointMake(ssipad(50, 25), screenSize.height - ssipad(20, 10));
        [self addChild:logo];
        
        [self initProgressBar];
        [self doProgress: delay];
    }
    
    return self;
}

- (void) initProgressBar {
    
    progressNode = [CCNode node];
    CCSprite *filled = [CCSprite spriteWithFile:@"empty.png"];
    filled.position = CGPointMake(0,0);
    
    [progressNode addChild:filled];
    
    progressDonut = [CCProgressTimer progressWithFile:@"filled.png"];
    progressDonut.type = kCCProgressTimerTypeRadialCW;
    progressDonut.position = filled.position;
    [progressNode addChild: progressDonut];
    
    progressDonut.percentage = 0.f;
    progressNode.position = ccp(screenSize.width - [filled boundingBox].size.width, [filled boundingBox].size.height);
    [self addChild: progressNode];
    
    loadingText = [CCLabelBMFont labelWithString:@"Loading" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    loadingText.anchorPoint = ccp(1,0.5);
    loadingText.position = ccp(progressNode.position.x - ssipadauto(30), progressNode.position.y);
    [self addChild: loadingText];
    
    [progressDonut stopAllActions];
    [progressNode stopAllActions];
}

- (void) doProgress:(float)interval {
    
    CCProgressTo *to = [CCProgressTo actionWithDuration:interval percent:100];
    id finishCallback = [CCCallFunc actionWithTarget:self selector:@selector(goToScene)];
    id seq = [CCSequence actions:to, finishCallback, nil];
    [progressDonut runAction:seq];
}

- (void) goToScene {
    //
    
    float duration = 0.5;
    switch (nextScene) {
        case kGoToSceneMain: {
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:duration scene:[MainGameScene node]]];
            break;
        }
        case kGoToSceneStore: {
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:duration scene:[StoreScene node]]];
            break;
        }
        case kGoToSceneWorldSelection: {
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:duration scene:[WorldSelectScene node]]];
            break;
        }
        case kGoToSceneLevelSelection: {
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:duration
                                                                                         scene:[LevelSelectScene nodeWithWorld:world]]];
            break;
        }
        case kGoToSceneGamePlay: {
            //
            break;
        }
        case kGoToSceneGameStart: {
            //
            progressNode.visible = NO;
            loadingText.visible = NO;
            
            GPImageButton *play = [GPImageButton controlOnTarget:self andSelector:@selector(startGame) imageFromFile:@"Button_Play.png"];
            CCLabelBMFont *playText = [CCLabelBMFont labelWithString:@"Lets Go!" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
            [play setText:playText];
            play.position = ccp(progressNode.position.x - ssipadauto(50), progressNode.position.y);
            [self addChild:play];
            
            break;
        }
        default:
            break;
    }
}

- (void) startGame {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.1
                                                                                 scene:[MainGameScene nodeWithWorld:world level:level]]];
}

- (void) onEnter {
    CCLOG(@"**** GameLoadingScene onEnter");
    
    if (![[AudioEngine sharedEngine] isBackgroundMusicPlaying]) {
        //[[AudioEngine sharedEngine] stopBackgroundMusic];
        [[AudioEngine sharedEngine] playBackgroundMusic:MENU_MUSIC loop:YES];
    }
    
    [super onEnter];
}

- (void) onExit {
    CCLOG(@"**** GameLoadingScene onExit");
    [self stopAllActions];
    [self unscheduleAllSelectors];
	[super onExit];
}

- (void) loadSpriteSheets {
    
    CCTexture2D *tex = [[CCTextureCache sharedTextureCache] addImage:[GPUtil getAtlasImageName:g_currentWorldAtlas]];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[GPUtil getAtlasPList:g_currentWorldAtlas] texture:tex];
    [tex setAliasTexParameters];
}

- (void) dealloc {
    
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [super dealloc];
}

@end
