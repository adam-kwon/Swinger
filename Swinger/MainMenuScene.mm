//
//  MainMenuScene.m
//  Swinger
//
//  Created by Min Kwon on 6/29/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "MainMenuScene.h"
#import "GPLabel.h"
#import "CCLayerColor+extension.h"
#import "WorldSelectScene.h"
#import "LevelCompleteScene.h"
#import "OptionsScene.h"
#import "GPImageButton.h"
#import "AudioEngine.h"
#import "StoreScene.h"
#import "GPGameCenter.h"
#import "AppDelegate.h"
#import "GameLoadingScene.h"

const int NEW_ITEM_TAG = 223455;

@implementation MainMenuScene

- (id) init {
    self = [super init];
    if (self) {
        
        screenSize = [CCDirector sharedDirector].winSize;
        
        CCSprite *background = [CCSprite spriteWithFile:ssipad(@"TempTitleBGiPad.png", @"TempTitleBG.png")];
        background.scaleX = screenSize.width/[background boundingBox].size.width + 0.1;
        background.scaleY = screenSize.height/[background boundingBox].size.height + 0.1;
        //background.scale = 1.1f;
        background.anchorPoint = CGPointZero;
        background.position = CGPointZero;
        [self addChild:background];
                
        const int gap = ssipadauto(55);
        
        CCSprite *logo = [CCSprite spriteWithFile:@"SwingStarLogo.png"];
        logo.position = CGPointMake(ssipad(330, 153), ssipad(480, 218));
        [self addChild:logo];
        
        //
        // Main Menu buttons
        //
        NSMutableArray *tmpMainMenuButtons = [NSMutableArray arrayWithCapacity:3];
        
        GPImageButton *play = [GPImageButton controlOnTarget:self andSelector:@selector(play) imageFromFile:@"Button_Play.png"];
        CCLabelBMFont *playText = [CCLabelBMFont labelWithString:@"PLAY" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        [play setText:playText];
        play.position = CGPointMake(ssipad(820, screenSize.width - 90), ssipad(473.5, 219.5));
        [self addChild:play];
        [tmpMainMenuButtons addObject:play];

        GPImageButton *options = [GPImageButton controlOnTarget:self andSelector:@selector(options) imageFromFile:@"Button_Options.png"];
        CCLabelBMFont *optionsText = [CCLabelBMFont labelWithString:@"EXTRAS" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        [options setText:optionsText];
        options.position = CGPointMake(play.position.x, play.position.y - gap);
        [self addChild:options];
        [tmpMainMenuButtons addObject:options];

        GPImageButton *store = [GPImageButton controlOnTarget:self andSelector:@selector(store) imageFromFile:@"Button_Store.png"];
        CCLabelBMFont *storeText = [CCLabelBMFont labelWithString:@"STORE" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        [store setText:storeText];
        store.position = CGPointMake(options.position.x, options.position.y - gap);
        [self addChild:store];
        [tmpMainMenuButtons addObject:store];
        
        //[StoreManager sharedInstance].newItemUnlocked = YES;
        [store removeChildByTag:NEW_ITEM_TAG cleanup:YES];
        if ([StoreManager sharedInstance].newItemUnlocked) {
            
            CCSprite * newSprite = [CCSprite spriteWithFile:@"new.png"];
            newSprite.scale = 0.75;
            newSprite.position = ccp(ssipadauto(60),
                                     ssipadauto(20));
            [store addChild: newSprite z:2 tag:NEW_ITEM_TAG];
        }
        
        mainMenuButtons = [[NSArray arrayWithArray:tmpMainMenuButtons] retain];
    
        
        //
        // GameCenter buttons, initially hidden
        //
        NSMutableArray *tmpGameCenterButtons = [NSMutableArray arrayWithCapacity:3];
        
        GPImageButton *highScores = [GPImageButton controlOnTarget:self andSelector:@selector(openGameCenterLeaderBoards) imageFromFile:@"Button_Play.png"];
        CCLabelBMFont *highScoresText = [CCLabelBMFont labelWithString:@"SCORES" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        [highScores setText:highScoresText];
        highScores.position = CGPointMake(play.position.x + screenSize.width, play.position.y);
        [self addChild:highScores];
        [tmpGameCenterButtons addObject:highScores];
        
        GPImageButton *achievements = [GPImageButton controlOnTarget:self andSelector:@selector(openGameCenterAchievements) imageFromFile:@"Button_Options.png"];
        CCLabelBMFont *achievementsText = [CCLabelBMFont labelWithString:@"ACHIEVES" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        [achievements setText:achievementsText];
        achievements.position = CGPointMake(options.position.x + screenSize.width, options.position.y);
        [self addChild:achievements];
        [tmpGameCenterButtons addObject:achievements];
        
        GPImageButton *back = [GPImageButton controlOnTarget:self andSelector:@selector(hideGameCenterMenu) imageFromFile:@"Button_Store.png"];
        CCLabelBMFont *backText = [CCLabelBMFont labelWithString:@"BACK" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        [back setText:backText];
        back.position = CGPointMake(store.position.x + screenSize.width, store.position.y);
        [self addChild:back];
        [tmpGameCenterButtons addObject:back];
        
        gameCenterMenuButtons = [[NSArray arrayWithArray:tmpGameCenterButtons] retain];
        
        //
        // GameCenter sprite
        //
        CCSprite *gameCenterSprite = [CCSprite spriteWithFile:@"gamecenter.png"];
//        gameCenterSprite.opacity = 225;
        gameCenter = [GPImageButton controlOnTarget:self andSelector:@selector(showGameCenterMenu) imageFromSprite:gameCenterSprite];
        gameCenter.position = ccp(ssipadauto(433), ssipadauto(43));
        [self addChild:gameCenter];
        
        // move the background
        [self moveWallpaper:background];
        
        [[GPGameCenter sharedInstance] authenticateLocalUser];
    }
    
    return self;
}

- (void) moveWallpaper: (CCSprite *) theWallpaper {
        
    float duration = 20;
    float moveAmt = [theWallpaper boundingBox].size.width - screenSize.width;
    
    theWallpaper.position = ccp(0,0);
    
    if (moveAmt > 0) {
        
        CCDelayTime * wait = [CCDelayTime actionWithDuration: 5.f];
        CCMoveBy * scrollRight = [CCMoveBy actionWithDuration:duration position: ccp(theWallpaper.position.x - moveAmt, 0)];
        CCScaleTo * scaleUp = [CCScaleBy actionWithDuration:duration scale:1.25f];
        CCSpawn * spawn1 = [CCSpawn actionOne:scrollRight two:scaleUp];
        CCSequence * seq1 = [CCSequence actions:wait, spawn1, [spawn1 reverse], nil];
        CCRepeatForever * runForever = [CCRepeatForever actionWithAction: seq1];
        
        [theWallpaper stopAllActions];
        [theWallpaper runAction: runForever];
    }
}

- (void) onEnter {
    if (![[AudioEngine sharedEngine] isBackgroundMusicPlaying]) {
        [[AudioEngine sharedEngine] setBackgroundMusicVolume:[UserData sharedInstance].musicVolumeLevel];
        [[AudioEngine sharedEngine] playBackgroundMusic:MENU_MUSIC loop:YES];
    }
    [super onEnter];
}

- (void) play {
    //[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[LevelCompleteScene nodeWithStats:nil world:@"TEST" level:1]]];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[WorldSelectScene node]]];
}

- (void) store {
    [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:0.5 scene:[StoreScene node]]];
    //[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameLoadingScene nodeWithDelay:3 goTo:kGoToSceneStore]]];
}

- (void) showGameCenterMenu {
    
    // Hide the main menu buttons
    float delayTime = 0;
    for (GPImageButton *button in mainMenuButtons) {
        CCMoveBy *moveRight = [CCMoveBy actionWithDuration:0.5f position:ccp(screenSize.width, 0)];
        CCDelayTime *delay = [CCDelayTime actionWithDuration:delayTime];
        CCSequence *seq = [CCSequence actions:delay, moveRight, nil];
        [button runAction:seq];
        delayTime += .05f;
    }

    // show the gamecenter buttons
    for (GPImageButton *button in gameCenterMenuButtons) {
        CCMoveBy *moveLeft = [CCMoveBy actionWithDuration:0.5f position:ccp(-screenSize.width, 0)];
        CCDelayTime *delay = [CCDelayTime actionWithDuration:delayTime];
        CCSequence *seq = [CCSequence actions:delay, moveLeft, nil];
        [button runAction:seq];
        delayTime += .05f;
    }
    
    gameCenter.enabled = NO;
    [gameCenter setOpacity:128];
}

- (void) hideGameCenterMenu {
    
    // Hide the gamecenter buttons
    float delayTime = 0;
    for (GPImageButton *button in gameCenterMenuButtons) {        
        CCMoveBy *moveRight = [CCMoveBy actionWithDuration:0.5f position:ccp(screenSize.width, 0)];
        CCDelayTime *delay = [CCDelayTime actionWithDuration:delayTime];
        CCSequence *seq = [CCSequence actions:delay, moveRight, nil];
        [button runAction:seq];
        delayTime += .05f;
    }
    
    // show the main menu buttons
    for (GPImageButton *button in mainMenuButtons) {
        CCMoveBy *moveLeft = [CCMoveBy actionWithDuration:0.5f position:ccp(-screenSize.width, 0)];
        CCDelayTime *delay = [CCDelayTime actionWithDuration:delayTime];
        CCSequence *seq = [CCSequence actions:delay, moveLeft, nil];
        [button runAction:seq];
        delayTime += .05f;
    }
    
    gameCenter.enabled = YES;
    [gameCenter setOpacity:255];
}

- (void) openGameCenterLeaderBoards {
    if ([GPGameCenter sharedInstance].isGameCenterAvailable == NO) {
        return;
    }
    
    
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController) {
        //leaderboardController.category = ... some name
        //leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
        leaderboardController.leaderboardDelegate = self;
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate.viewController presentModalViewController:leaderboardController animated:NO];
        
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        
        if (orientation == UIDeviceOrientationLandscapeRight) {
            leaderboardController.view.transform = CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(-90.0f));            
        } else if (orientation == UIDeviceOrientationLandscapeLeft) {
            leaderboardController.view.transform = CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(90.0f));
        }
        
        [leaderboardController.view setCenter:ccp(screenSize.height/2, screenSize.width/2)];
    }
    [leaderboardController release];
    
}

- (void) openGameCenterAchievements {
    if ([GPGameCenter sharedInstance].isGameCenterAvailable == NO) {
        return;
    }
    
    GKAchievementViewController *achievementController = [[GKAchievementViewController alloc] init];
    if (achievementController) {
        //leaderboardController.category = ... some name
        achievementController.achievementDelegate = self;
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate.viewController presentModalViewController:achievementController animated:NO];
        
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        
        if (orientation == UIDeviceOrientationLandscapeRight) {
            achievementController.view.transform = CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(-90.0f));            
        } else if (orientation == UIDeviceOrientationLandscapeLeft) {
            achievementController.view.transform = CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(90.0f));
        }
        
        [achievementController.view setCenter:ccp(screenSize.height/2, screenSize.width/2)];
    }
    [achievementController release];
    
}

- (void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController {
    AppDelegate *appDelegate = (AppDelegate  *)[[UIApplication sharedApplication] delegate];
    RootViewController *vCont = appDelegate.viewController;
    [vCont dismissModalViewControllerAnimated:YES];    
}

- (void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
    AppDelegate *appDelegate = (AppDelegate  *)[[UIApplication sharedApplication] delegate];
    RootViewController *vCont = appDelegate.viewController;
    [vCont dismissModalViewControllerAnimated:YES];
}

- (void) options {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[OptionsScene node]]];
}

- (void) dealloc {
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [self removeAllChildrenWithCleanup:YES];
    
    [mainMenuButtons release];
    [gameCenterMenuButtons release];
    
    [super dealloc];
}

@end
