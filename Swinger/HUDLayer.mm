//
//  HUDLayer.m
//  Swinger
//
//  Created by James Sandoz on 5/29/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "HUDLayer.h"

#import "Constants.h"
#import "Notifications.h"
#import "Wind.h"
#import "GPDialog.h"
#import "GPImageButton.h"
#import "GamePlayLayer.h"
#import "Coin.h"
#import "Star.h"
#import "BaseCatcherObject.h"
#import "AudioEngine.h"
#import "GPLabel.h"
#import "MainMenuScene.h"
#import "MainGameScene.h"
#import "StoreScene.h"
#import "LevelSelectScene.h"
#import "CCLayerColor+extension.h"
#import "Player.h"
#import "UserData.h"
#import "AudioManager.h"
#import "PowerUp.h"
#import "ObjectivesScreen.h"
#import "GameLoadingScene.h"

static const int navigationScreenTag = 600;
static const float screenTransitionTime = 0.5;
static const float scoreScale = 0.75;
static const int POWER_UP_TAG = 1234567;
static const int POWER_UP_DISPLAY_TAG = 1234568;

@interface HUDLayer(Private)
//- (void) updateGripBoxVertices;
- (void) initGripBar;
@end


@implementation HUDLayer

//@synthesize coinScore;
//@synthesize starScore;

static HUDLayer* instanceOfLayer;
static const float buttonScale = 1.f;
static const float levelScale = 1.5f;

CGPoint origGripPos = CGPointZero;
CGPoint origWindPos = CGPointZero;

+ (HUDLayer*) sharedLayer {
	NSAssert(instanceOfLayer != nil, @"HUDLayer instance not yet initialized!");
	return instanceOfLayer;
}


- (id) init {
    
    if ((self = [super init])) {
        instanceOfLayer = self;
        
        screenSize = [CCDirector sharedDirector].winSize;
        
        [self initPauseButton];
        //[self initGripBar];
        //[self initWindDisplay];
        [self initLevelDisplay];
        [self initScoreDisplays];
        [self initPowerUpDisplay];
        //[self initTapButton];
        [self initReviveButton];
        [self registerForNotifications];
        
        objectivesScreen = [ObjectivesScreen node];
        objectivesScreen.position = ccp(-screenSize.width, 0);
        [objectivesScreen setBackTarget:self action:@selector(hideObjectives)];
        [self addChild:objectivesScreen];
    }
    
    return self;
}

- (void) registerForNotifications {
    
    // Register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(gameStarted:) 
                                                 name:NOTIFICATION_GAME_STARTED 
                                               object:nil];
    
    /*[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerCaught:) 
                                                 name:NOTIFICATION_PLAYER_CAUGHT 
                                               object:nil];*/
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enemyKilled:)
                                                 name:NOTIFICATION_ENEMY_KILLED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerRevived:)
                                                 name:NOTIFICATION_PLAYER_REVIVED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(blockBroken:)
                                                 name:NOTIFICATION_BLOCK_BROKEN
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(playerInAir) 
                                                 name:NOTIFICATION_PLAYER_IN_AIR 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(showReviveButton) 
                                                 name:NOTIFICATION_PLAYER_FELL 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(gameOver) 
                                                 name:NOTIFICATION_GAME_OVER 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(levelFinished) 
                                                 name:NOTIFICATION_FINISHED_LEVEL 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(niceJump) 
                                                 name:NOTIFICATION_NICE_JUMP 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(windBlowing:) 
                                                 name:NOTIFICATION_WIND_BLOWING 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(activatedPowerUp:) 
                                                 name:NOTIFICATION_POWERUP_ACTIVATED 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(powerUpFading:) 
                                                 name:NOTIFICATION_POWERUP_FADING 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(deactivatedPowerUp:) 
                                                 name:NOTIFICATION_POWERUP_DEACTIVATED 
                                               object:nil];
}

- (void) levelFinished {
    pauseButton.visible = NO;
}

- (void) showReviveButton {
    
    //if ([UserData sharedInstance].totalLives > 0) {
    
        //float buttonScale = 1.f;
        
        //saveBtn.scale = 0.1f*buttonScale;
        
        pauseButton.visible = NO;
        saveBtn.position = ccp(screenSize.width/2, -[saveBtn size].height);
        [saveBtn setEnabled:YES];
        saveBtn.visible = YES;
        
        // Animate button to plop onto the screen
        CCMoveBy * moveUp = [CCMoveBy actionWithDuration: 0.1 position: ccp(0, [saveBtn size].height + ssipadauto(60))];
        CCMoveBy * moveDown = [CCMoveBy actionWithDuration: 0.1 position: ccp(0, -ssipadauto(10))];
        CCMoveBy * moveBackup = [CCMoveBy actionWithDuration: 0.1 position: ccp(0, ssipadauto(10))];
        CCSequence * seq = [CCSequence actions: moveUp, moveDown, moveBackup, nil];
        
        [saveBtn stopAllActions];
        [saveBtn runAction: seq];
    //}
}

- (void) hideReviveButton {
    
    [saveBtn setEnabled:NO];
    // Animate button to plop onto the screen
    CCMoveBy * moveUp = [CCMoveBy actionWithDuration: 0.1 position: ccp(0, ssipadauto(10))];
    CCMoveBy * moveDown = [CCMoveBy actionWithDuration: 0.1 position: ccp(0, -([saveBtn size].height + ssipadauto(60)))];
    CCSequence * seq = [CCSequence actions: moveUp, moveDown, nil];
    
    [saveBtn stopAllActions];
    [saveBtn runAction: seq];
    
    //saveBtn.visible = NO;
}

- (void) initReviveButton {
    
    CCNode * saveMe = [CCNode node];
    
    CCLabelBMFont * text = [CCLabelBMFont labelWithString:@"Use A Life Line" fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
    text.position = ccp(ssipadauto(10), 0);
    
    CCSprite * lifeLine = [CCSprite spriteWithSpriteFrameName:@"Star4.png"];
    lifeLine.position = ccp(-([lifeLine boundingBox].size.width) - ssipadauto(20), [lifeLine boundingBox].size.height/2 - ssipadauto(5));
    
    CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"starAnimation"] restoreOriginalFrame:NO];
    CCRepeatForever *animAction = [CCRepeatForever actionWithAction:action];
    [lifeLine runAction:animAction];
    
    [saveMe addChild: lifeLine];
    [saveMe addChild: text];
    
    saveBtn = [GPImageButton controlOnTarget:self andSelector:@selector(revivePlayer) imageFromFile: @"Button_Options.png"];
    saveBtn.scale = 1.25f;
    saveBtn.position = ccp(screenSize.width/2 - [saveBtn boundingBox].size.width/2, [saveBtn boundingBox].size.height + ssipadauto(30));
    
    [saveBtn addChild: saveMe];
    
    [self addChild: saveBtn];
    saveBtn.visible = NO;
}

- (void) revivePlayer {
    
    [saveBtn stopAllActions];
    
    if ([[GamePlayLayer sharedLayer] getPlayer].state != kSwingerDead) {
    
        saveBtn.visible = NO;
        
        if ([UserData sharedInstance].totalLives > 0) {
            [self doRevive];
        } else {
            // take user to the store to buy more lives
            [[[GamePlayLayer sharedLayer] getPlayer] waitForStore];
            reviveRequested = YES;
            [self gotoBuyLives];
        }
    }
}

- (void) doRevive {
    
    pauseButton.visible = YES;
    
    if([[[GamePlayLayer sharedLayer] getPlayer] revive]) {
        [UserData sharedInstance].totalLives--;
        [starScoreLabel setString:[NSString stringWithFormat:@"%d", [UserData sharedInstance].totalLives]];
    }
}

- (void) onEnter {
    CCLOG(@"**** HUDLAYER onEnter");
    
    if (reviveRequested) {
        reviveRequested = NO;
        
        if ([UserData sharedInstance].totalLives > 0) {
            [self doRevive];
        }/* else {
            [[GamePlayLayer sharedLayer] getPlayer].state = kSwingerDead;
        }*/
    }
    
    if (![[AudioEngine sharedEngine] isBackgroundMusicPlaying]) {
        [[AudioEngine sharedEngine] setBackgroundMusicVolume:[UserData sharedInstance].musicVolumeLevel];
        [[AudioEngine sharedEngine] playBackgroundMusic:GAME_MUSIC loop:YES];
    }
    
    if (starScoreLabel != nil) {
        [starScoreLabel setString:[NSString stringWithFormat:@"%d", [UserData sharedInstance].totalLives]];
    }
    
    [super onEnter];
}

- (void) initPauseButton {
    pauseButton = [CCSprite spriteWithFile:@"pause.png"];
    pauseButton.position = CGPointMake(screenSize.width - [pauseButton boundingBox].size.width/2 - 5,
                                       screenSize.height - [pauseButton boundingBox].size.height/2 - 5);
    [self addChild:pauseButton];
}

- (void) initTapButton {
    
    tapButton = [CCSprite spriteWithFile:@"pushButton.png"];
    tapButton.position = CGPointZero;
    tapButton.scale = buttonScale;
    tapButton.visible = NO;
    [self addChild:tapButton];
    
    CCLabelBMFont *tapText = [CCLabelBMFont labelWithString:@"TAP" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    tapText.position = ccp(ssipadauto(47), ssipadauto(46));
    
    CCFadeOut * fadeOut = [CCFadeOut actionWithDuration:0.1];
    CCFadeIn * fadeIn = [CCFadeIn actionWithDuration:0.1];
    CCDelayTime * wait = [CCDelayTime actionWithDuration:0.1];
    
    [tapText runAction: [CCRepeatForever actionWithAction:[CCSequence actions: fadeOut, wait, fadeIn, nil]]];
    [tapButton addChild: tapText];
}

- (void) activatedPowerUp: (NSNotification *) notification {
    
    [[CCScheduler sharedScheduler] unscheduleSelector: @selector(fadeOutPower) forTarget:self];
    CCSprite * sprite = [(PowerUp *) notification.object getSprite];
    sprite.tag = POWER_UP_TAG;
    [powerUpIcon removeChildByTag: POWER_UP_TAG cleanup:YES];
    [powerUpIcon addChild: sprite];
    powerUpIcon.visible = YES;
    sprite.opacity = 0;
    
    CCSprite *display = [(PowerUp *) notification.object getSprite];
    display.tag = POWER_UP_DISPLAY_TAG;
    [self removeChildByTag: POWER_UP_DISPLAY_TAG cleanup:YES];
    display.scale = 2;
    display.position = ccp(screenSize.width/2, screenSize.height/2);
    display.opacity = 0;
    [self addChild: display];
    
    // show off powerup
    CCFadeIn *fadeIn = [CCFadeIn actionWithDuration: 0.15];
    CCDelayTime *wait = [CCDelayTime actionWithDuration:0.25];
    CCScaleBy *scaleDown = [CCScaleBy actionWithDuration:0.15 scale:0.5];
    CCMoveTo *moveUp = [CCMoveTo actionWithDuration:0.15 position:powerUpIcon.position];
    CCFadeOut *fadeOut = [CCFadeOut actionWithDuration:0];
    CCFadeIn *fadeInIcon = [CCFadeIn actionWithDuration:0.75];
    CCSpawn *spawn = [CCSpawn actions: scaleDown, moveUp, nil];
    CCSequence *seq = [CCSequence actions: fadeIn, wait, spawn, fadeOut, nil];
    
    [display stopAllActions];
    [display runAction:seq];
    [sprite runAction:fadeInIcon];
    
    PowerUp * power = notification.object;
    
    if (power != [[GamePlayLayer sharedLayer] getPlayer].revivePowerUp) {
        
        int multiplier = 1;
        
        switch ([power getType]) {
            case kPowerUpTypeMedium: {
                multiplier = 2;
                break;
            }
            case kPowerUpTypeLong: {
                multiplier = 3;
                break;
            }
            case kPowerUpTypeExtended: {
                multiplier = 4;
                break;
            }
            default:
                break;
        }
        
        [self addScore: multiplier*250];
    }
}

- (void) deactivatedPowerUp: (NSNotification *) notification {
    
    PowerUp * currentPowerUp = [[[GamePlayLayer sharedLayer] getPlayer] currentPower];
    PowerUp * deactivated = (PowerUp *)notification.object;
    
    if (currentPowerUp == nil || deactivated == currentPowerUp) {
        
        if (deactivated == currentPowerUp && currentPowerUp.state == kPowerUpNone) {
            // power down
            [[AudioEngine sharedEngine] playEffect:SND_POWER_DOWN gain:2];
        }
        
        [powerUpIcon removeChildByTag: POWER_UP_TAG cleanup:YES];
        powerUpIcon.visible = NO;
    }
}

- (void) powerUpFading: (NSNotification *) notification {
    
    // XXX display something
    [[CCScheduler sharedScheduler] scheduleSelector : @selector(fadeOutPower) forTarget:self interval:1 paused:NO];
}

- (void) fadeOutPower {
    CCSprite * sprite = (CCSprite *)[powerUpIcon getChildByTag: POWER_UP_TAG];
    sprite.opacity -= 20;
    int scale = sprite.scale;
    
    CCScaleTo * scaleUp = [CCScaleTo actionWithDuration: 0.25 scale: scale+0.25];
    CCScaleTo * scaleDown = [CCScaleTo actionWithDuration: 0.25 scale: scale];
    
    [sprite stopAllActions];
    [sprite runAction: [CCSequence actions: scaleUp, scaleDown, nil]];
    [[AudioEngine sharedEngine] playEffect:SND_POWER_FADING];
    
    if (sprite.opacity <= 20) {
        [[CCScheduler sharedScheduler] unscheduleSelector : @selector(fadeOutPower) forTarget:self];
    }
}

- (void) gameStarted:(NSNotification *)notification {
    
    // reset the score counters
    [self resetScores];
    
    // notification should contain the initial catcher
    //[self playerCaught: notification];
}

- (void) niceJump {
    niceJump = YES;
}

- (void) playerInAir {
    [self hideButton];
    
    //[gripNode stopAllActions];
    //gripNode.position = origGripPos;
}

- (void) gameOver {
    [self hideButton];
    
    [gripNode stopAllActions];
    gripNode.position = origGripPos;
    
    [[CCScheduler sharedScheduler] unscheduleSelector : @selector(fadeOutPower) forTarget:self];
}

- (void) enemyKilled:(NSNotification *)notification {
    Enemy *enemy = notification.object;
    int multiplier = 1;
    
    if ([enemy gameObjectType] == kGameObjectSaw) {
        multiplier = 2;
    }
    
    [self addScore: multiplier*100];
}

- (void) playerRevived:(NSNotification *)notification {
    //
    int score = 2000;
    
    if (notification.object != nil && [notification.object boolValue]) {
        // don't give points for multiple revives
        score = 0;
    }
    
    [self addScore:score];
}

- (void) blockBroken:(NSNotification *)notification {
    //
    [self addScore:100];
}

- (void) playerCaught:(NSNotification *)notification {    
    
    int score = 50;
    BaseCatcherObject * catcher = (BaseCatcherObject *) notification.object;
    
    if([catcher gameObjectType] == kGameObjectWheel) {
        
        score = 100; // harder object
        tapButton.scale = 0.1f*buttonScale;
        tapButton.position = ccp(ssipadauto(65), ssipadauto(50));
        tapButton.visible = YES;
        
        // Animate button to plop onto the screen
        CCScaleTo * scale1 = [CCScaleTo actionWithDuration:0.2 scale:1.2f*buttonScale];
        CCCallFunc * blop = [CCCallFunc actionWithTarget:self selector:@selector(playBlop)];
        CCScaleTo * scale2 = [CCScaleTo actionWithDuration:0.1 scale:0.8f*buttonScale];
        CCScaleTo * scale3 = [CCScaleTo actionWithDuration:0.1 scale:1.1f*buttonScale];
        CCScaleTo * scale4 = [CCScaleTo actionWithDuration:0.1 scale:0.9f*buttonScale];
        CCScaleTo * scale5 = [CCScaleTo actionWithDuration:0.1 scale:1.f*buttonScale];
        CCSequence * seq = [CCSequence actions: scale1, blop, scale2, scale3, scale4, scale5, nil];
        
        [tapButton stopAllActions];
        [tapButton runAction: seq];
    } else {
        [self hideButton];
        
        if ([catcher gameObjectType] == kGameObjectCannon || 
            [catcher gameObjectType] == kGameObjectSpring ||
            [catcher gameObjectType] == kGameObjectElephant) {
            
            score = 75;
        }
    }
    
    if (!initialCatch) {
        [self addScore: score];
        
        if (niceJump) {
            // if player did a nice release and is caught then give him bonus points
            [self perfectRelease];
            niceJump = NO;
        } else if ([catcher gameObjectType] != kGameObjectSpring &&
                   [catcher gameObjectType] != kGameObjectElephant) {
            [self imperfectRelease];
        }
    }
    
    initialCatch = NO;
}

- (void) hideButton {
    [tapButton stopAllActions];
    tapButton.visible = NO;
    
    [self hideReviveButton];
}

- (void) playBlop {
    
    [[AudioEngine sharedEngine] playEffect:SND_BLOP];
}

- (BOOL) handleTouchEvent:(CGPoint)touchPoint {
    BOOL swallowed = NO;
    if (tapButton.visible) {
        if (touchPoint.x > 0 && touchPoint.x < [tapButton contentSize].width
            && touchPoint.y > 0 && touchPoint.y < [tapButton contentSize].height) 
        {            
            swallowed = YES;

            CCScaleTo * scale1 = [CCScaleTo actionWithDuration:0.05 scale:0.8f*buttonScale];
            CCScaleTo * scale2 = [CCScaleTo actionWithDuration:0.05 scale:1.f*buttonScale];
            CCSequence * seq = [CCSequence actions: scale1, scale2, nil];
            
            [tapButton stopAllActions];
            [tapButton runAction: seq];
            
            Player *player = [[GamePlayLayer sharedLayer] getPlayer];
            [player handleTapEvent];
        }
    }
    
    return swallowed;
}


- (void) resetGripBar {
    
    //if (gripDonut.percentage <= 95) {
    //    [self addScore: 25]; // jumped in the nick of time, bonus points
    //}
    
    [gripDonut stopAllActions];
    [[CCScheduler sharedScheduler] unscheduleSelector:@selector(gripRunningOut) forTarget:self];
    gripDonut.percentage = 0.f;
    
    [gripNode stopAllActions];
    gripNode.position = origGripPos;
}


- (void) gripRanOut {
    [[[GamePlayLayer sharedLayer] getPlayer] gripRanOut];
}

- (void) countDownGrip:(float)interval {
    CCProgressTo *to = [CCProgressTo actionWithDuration:interval percent:100];
    id finishCallback = [CCCallFunc actionWithTarget:self selector:@selector(gripRanOut)];
    id seq = [CCSequence actions:to, finishCallback, nil];
    [gripDonut runAction:seq];

    // grip running out
    [[CCScheduler sharedScheduler] scheduleSelector : @selector(gripRunningOut) forTarget:self interval:interval-10 paused:NO];
}

- (void) gripRunningOut {
    
    [[CCScheduler sharedScheduler] unscheduleSelector:@selector(gripRunningOut) forTarget:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIME_RUNNING_OUT object:nil];
    
    CCDelayTime * wait = [CCDelayTime actionWithDuration:0.25f];
    
    float duration = 0.25f;
    float xMove = ssipadauto(5);
    float yMove = ssipadauto(5);
    
    // Animate timer to warn player
    CCCallFunc * heartBeat = [CCCallFunc actionWithTarget:self selector:@selector(doHeartBeat)];
    CCMoveBy *move = [CCMoveBy actionWithDuration:duration position:ccp(-xMove, -yMove)];
    CCScaleTo *scale = [CCScaleTo actionWithDuration:duration scale:1.1f];
    CCSpawn *spawn = [CCSpawn actions:move, scale, nil];
    CCMoveBy *moveBack = [CCMoveBy actionWithDuration:duration position:ccp(xMove,yMove)];
    CCScaleTo *scaleBack = [CCScaleTo actionWithDuration:duration scale:1.f];
    CCSpawn *spawn2 = [CCSpawn actions:moveBack, scaleBack, nil];
    
    [gripNode stopAllActions];
    [gripNode runAction: heartBeat];
    [gripNode runAction: [CCRepeat actionWithAction: [CCSequence actions: spawn, spawn2, wait, wait, nil] times: 10]];
}

- (void) doHeartBeat {
    [[AudioManager sharedManager] playHeartBeat];
}

- (void) windBlowing: (NSNotification *) notification {
    Wind * wind = nil;
    
    if (notification.object != nil) {
        wind = (Wind *) notification.object;
    }
    
    [self displayWind: wind];
}

- (void) initLevelDisplay {
    
    levelDisplay = [CCLabelBMFont labelWithString:@"Level" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    levelDisplay.color = CC3_COLOR_ORANGE;
    levelDisplay.scale = levelScale;
    levelDisplay.visible = NO;
    
    [self addChild: levelDisplay z:100];
}

- (void) displayLevel {
    
    [levelDisplay setString: [NSString stringWithFormat:@"%@ - Level %d", [MainGameScene sharedScene].world, [MainGameScene sharedScene].level ]];
    
    levelDisplay.opacity = 240;
    [levelDisplay stopAllActions];
    
    int displayScale = levelScale;
    
    levelDisplay.scale = 0.1f*displayScale;
    levelDisplay.position = ccp(screenSize.width/2, screenSize.height - ssipadauto(70));
    levelDisplay.visible = YES;
    
    // Animate level display to plop onto the screen
    CCScaleTo * scale1 = [CCScaleTo actionWithDuration:0.2 scale:1.2f*displayScale];
    CCScaleTo * scale2 = [CCScaleTo actionWithDuration:0.1 scale:0.8f*displayScale];
    CCScaleTo * scale3 = [CCScaleTo actionWithDuration:0.1 scale:1.1f*displayScale];
    CCScaleTo * scale4 = [CCScaleTo actionWithDuration:0.1 scale:0.9f*displayScale];
    CCScaleTo * scale5 = [CCScaleTo actionWithDuration:0.1 scale:1.f*displayScale];
    CCDelayTime * wait = [CCDelayTime actionWithDuration: 0.1];
    CCFadeOut * fade = [CCFadeOut actionWithDuration:3];
    CCSequence * seq = [CCSequence actions: scale1, scale2, scale3, scale4, scale5, wait, fade, nil];
    
    [levelDisplay runAction: seq];
}

- (void) displayWind: (Wind*) wind {
    
    [windDisplay stopAllActions];
    
    // reposition wind display - in case we are stopping in the middle of the animation
    windDisplay.position = origWindPos;
    
    NSString * description = nil;
    
    if(wind != nil) {
        Direction direction = wind.direction;
        
        if(direction == kDirectionN) {
            windArrow.rotation = 0;
        } else if(direction == kDirectionS) {
            windArrow.rotation = 180;
        } else if(direction == kDirectionE) {
            windArrow.rotation = 90;
        } else if(direction == kDirectionW) {
            windArrow.rotation = -90;
        } else if(direction == kDirectionNE) {
            windArrow.rotation = 45;
        } else if(direction == kDirectionNW) {
            windArrow.rotation = -45;
        } else if(direction == kDirectionSE) {
            windArrow.rotation = 135;
        } else if(direction == kDirectionSW) {
            windArrow.rotation = -135;
        }
        
        description = [NSString stringWithFormat:@"%.0f mph", wind.speed ];
    }
    
    if(description != nil) {
        windLabel.visible = YES;
        [windSpeed setString:description];
        
        CCDelayTime * wait = [CCDelayTime actionWithDuration:0.5f];
        
        float duration = 0.5f;
        float xMove = ssipadauto(-25);//-screenSize.width/2);
        float yMove = ssipadauto(-25);//-screenSize.height/2);
        
        
        CCMoveBy *move = [CCMoveBy actionWithDuration:duration position:ccp(xMove,yMove)];
        CCScaleTo *scale = [CCScaleTo actionWithDuration:duration scale:2.f];
        CCSpawn *spawn = [CCSpawn actions:move, scale, nil];
        CCMoveBy *moveBack = [CCMoveBy actionWithDuration:duration position:ccp(-xMove,-yMove)];
        CCScaleTo *scaleBack = [CCScaleTo actionWithDuration:duration scale:1.f];
        CCSpawn *spawn2 = [CCSpawn actions:moveBack, scaleBack, nil];
        
        windDisplay.visible = YES;
        [self windArrowAnimation: wind.speed];
        [windDisplay runAction: [CCSequence actions:spawn, wait, spawn2, nil]];
    } else {
        windDisplay.visible = NO;
        [windArrow stopAllActions];
        [windDisplay stopAllActions];
    }
}

- (void) windArrowAnimation: (float) speed {
    
    id action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"windArrowAnimation"] restoreOriginalFrame:NO];
    id arrowAnim = [CCRepeatForever actionWithAction:action];
    id arrowSpeedAction = [CCSpeed actionWithAction:arrowAnim speed:speed*0.2];
    
    [windArrow stopAllActions];
    [windArrow runAction:arrowSpeedAction];
}

- (void) initWindDisplay {
    
    windDisplay = [CCNode node];
    
    CGPoint anchorPoint = ccp(0,0.5);
    float yPos = gripNode.position.y + ssipadauto(4);
    float xPos = gripNode.position.x - ([gripDonut boundingBox].size.width) - 20;
    
    windArrow = [CCSprite spriteWithSpriteFrameName:@"Wind_1.png"];
    windArrow.position = CGPointZero;
    windArrow.opacity = 150;
    [windDisplay addChild: windArrow];
    
    windLabel = [CCLabelBMFont labelWithString:@"WIND" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    windLabel.anchorPoint = anchorPoint;
    windLabel.position = ccp(0, ssipadauto(10));
    windLabel.scale = 0.25f;
    [windDisplay addChild: windLabel];
    
    windSpeed  = [CCLabelBMFont labelWithString:@"" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    windSpeed.anchorPoint = ccp(0.5, 0.5);//anchorPoint;
    windSpeed.position = CGPointZero;
    windSpeed.scale = 0.5f;
    [windDisplay addChild: windSpeed];
    
    windDisplay.position = ccp(xPos, yPos);
    origWindPos = windDisplay.position;
    [self addChild: windDisplay z:1];
}

- (void) initScoreDisplays {
    numTries = 0;
    
    coinScoreIcon = [CCSprite spriteWithSpriteFrameName:@"Coin1.png"];
    //coinScoreIcon.scale = 0.95;
    coinScoreIcon.position = ssipad(ccp(45,725),ccp(20,300)); //ssipad(ccp(260,725), ccp(135,300));
    [self addChild:coinScoreIcon];
    
    CCLabelBMFont * coinScoreXLabel = [CCLabelBMFont labelWithString:@"x" fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
    coinScoreXLabel.position = ssipad(ccp(66,22), ccp(33,11));
    coinScoreXLabel.color = FONT_COLOR_YELLOW;
    [coinScoreIcon addChild:coinScoreXLabel];
    
    coinScoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    coinScoreLabel.anchorPoint = ccp(0,0);
    coinScoreLabel.scale = scoreScale;
    coinScoreLabel.position = ssipad(ccp(74,-4), ccp(37,-2));
    coinScoreLabel.color = FONT_COLOR_YELLOW;
    [coinScoreIcon addChild:coinScoreLabel];

    starScoreIcon = [CCSprite spriteWithSpriteFrameName:@"Star1.png"];
    starScoreIcon.scale = 0.90;
    starScoreIcon.position = ssipad(ccp(260,725), ccp(135,300));//ssipad(ccp(45,725),ccp(20,300));
    [self addChild:starScoreIcon];
    
    CCLabelBMFont * starXLabel = [CCLabelBMFont labelWithString:@"x" fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
    starXLabel.position = ssipad(ccp(77,24), ccp(41,12));
    [starScoreIcon addChild:starXLabel];
    
    starScoreLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", [UserData sharedInstance].totalLives] fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    starScoreLabel.anchorPoint = ccp(0,0);
    starScoreLabel.scale = scoreScale;
    starScoreLabel.position = ssipad(ccp(85,0), ccp(45,0));
    [starScoreIcon addChild:starScoreLabel];
    
    scoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    scoreLabel.anchorPoint = ccp(0,1);
    scoreLabel.scale = scoreScale;
    scoreLabel.position = ssipad(ccp(595, 750), ccp(280, 312));
    [self addChild: scoreLabel];
    initialCatch = YES;
}

- (void) initPowerUpDisplay {
    
    powerUpIcon = [CCNode node];
    powerUpIcon.scale = 0.85;
    powerUpIcon.position = ssipad(ccp(490, 730), ccp(230, 300));
    [self addChild: powerUpIcon];
}

- (void) resetScores {
    [UserData sharedInstance].currentCoins = 0;
    [UserData sharedInstance].currentStars = 0;
    [UserData sharedInstance].currentScore = 0;
    [UserData sharedInstance].currentTime = 0;
    [UserData sharedInstance].landingBonus = 0;
    [UserData sharedInstance].perfectJumpCount = 0;
    [UserData sharedInstance].imperfectJumpCount = 0;
    [UserData sharedInstance].skipCount = 0;
    
    if (numTries == 0) {
        [UserData sharedInstance].restartCount = 0;
    }
    
    [coinScoreLabel setString:@"0"];
    [starScoreLabel setString:[NSString stringWithFormat:@"%d", [UserData sharedInstance].totalLives]];
    [scoreLabel setString:@"0"];
    
    // reset power up display
    powerUpIcon.visible = NO;
    
    // reset wind display
    //[self displayWind: nil];
    
    initialCatch = YES;
}


- (void) collectCoin:(Coin *)coin {
    
    // save the coin position
    CGPoint gamePlayPosition = [[GamePlayLayer sharedLayer] getNode].position;
    CGPoint currPos = ccp(normalizeToScreenCoord(gamePlayPosition.x, coin.position.x, [GamePlayLayer sharedLayer].scale), 
                          normalizeToScreenCoord(gamePlayPosition.y, coin.position.y, [GamePlayLayer sharedLayer].scale));
    
//    CCLOG(@"\n\n\n***    collectCoin: coin pos=(%f,%f), normalizedPos=(%f,%f), gameNode scale=%f, coin scale=%f, HUDLayer scale=%f    ***\n\n\n", coin.position.x, coin.position.y, currPos.x, currPos.y, [GamePlayLayer sharedLayer].scale, coin.scale, self.scale);
    
    // Move the coin from gameNode to HUDLayer.  This will allow us to move the coin to
    // the score without having to account for gameNode panning/scrolling/etc
    [[GamePlayLayer sharedLayer] collect:coin];
    [self addChild:coin];
    coin.position = currPos;
    
    // Set the scale of the coin if it's not 1 and then scale to 1 slightly faster than the move
    if ([GamePlayLayer sharedLayer].scale != 1) {
        coin.scale = [GamePlayLayer sharedLayer].scale;
        id scaleTo = [CCScaleTo actionWithDuration:.2f scale:1];
        [coin runAction:scaleTo];
    }
    
    // Now move the coin
    id move = [CCMoveTo actionWithDuration:0.25f position:coinScoreIcon.position];
    id destroy = [CCCallFunc actionWithTarget:coin selector:@selector(explode)];
    id seq = [CCSequence actions:move, destroy, nil];
    [coin runAction:seq];
}

- (void) collectStar:(Star *)star {
    
    // save the star position
    CGPoint gamePlayPosition = [[GamePlayLayer sharedLayer] getNode].position;
    CGPoint currPos = ccp(normalizeToScreenCoord(gamePlayPosition.x, star.position.x, [GamePlayLayer sharedLayer].scale), normalizeToScreenCoord(gamePlayPosition.y, star.position.y, [GamePlayLayer sharedLayer].scale));
    
    // Move the star from gameNode to HUDLayer.  This will allow us to move the star to
    // the score without having to account for gameNode panning/scrolling/etc
    [[GamePlayLayer sharedLayer] collect:star];
    star.position = currPos;
    [self addChild:star];

    // Set the scale of the star if it's not 1 and then scale to 1 slightly faster than the move
    if ([GamePlayLayer sharedLayer].scale != 1) {
        star.scale = [GamePlayLayer sharedLayer].scale;
        id scaleTo = [CCScaleTo actionWithDuration:.2f scale:1];
        [star runAction:scaleTo];
    }
    
    // Now move the star
    id move = [CCMoveTo actionWithDuration:0.25f position:starScoreIcon.position];
    id destroy = [CCCallFunc actionWithTarget:star selector:@selector(explode)];
    id seq = [CCSequence actions:move, destroy, nil];
    [star runAction:seq];
}

- (void) addScore: (int) amount {
    
    if (amount <= 0) {
        return;
    }
    
    [UserData sharedInstance].currentScore += amount;
    [scoreLabel setString:[NSString stringWithFormat:@"%d", [UserData sharedInstance].currentScore]];
    float scale = scoreScale;
    
    id bigger = [CCScaleTo actionWithDuration:0.07 scale:scale + 0.2];
    id normal = [CCScaleTo actionWithDuration:0.07 scale:scale];
    id seq = [CCSequence actions:bigger, normal, nil];
    [scoreLabel runAction:seq];
}

- (void) addCoin {
    [self addCoin: 1];
}

- (void) addCoin: (int) numCoins{
    numCoins *= [UserData sharedInstance].unlimitedCoinDoubler ? 2 : 1;
    [UserData sharedInstance].currentCoins += numCoins;
    [coinScoreLabel setString:[NSString stringWithFormat:@"%d", [UserData sharedInstance].currentCoins]];
    [UserData sharedInstance].totalCoins += numCoins;
    float scale = scoreScale;
    
    id bigger = [CCScaleTo actionWithDuration:0.07 scale:scale + 0.2];
    id normal = [CCScaleTo actionWithDuration:0.07 scale:scale];
    id seq = [CCSequence actions:bigger, normal, nil];
    [coinScoreLabel runAction:seq];
    
    [self addScore: 50*numCoins];
}

- (void) addBonusCoin: (int) numBonusCoins {
    [UserData sharedInstance].landingBonus += numBonusCoins;
    [self addCoin: numBonusCoins];
    [self addScore: (200*numBonusCoins) +  + (10*[[MainGameScene sharedScene] level])];
}

- (void) addLife {
    [self addLife: 1];
}

- (void) addLife: (int) numLives {
    
    [UserData sharedInstance].totalLives += numLives;
    [starScoreLabel setString:[NSString stringWithFormat:@"%d", [UserData sharedInstance].totalLives]];
    float scale = scoreScale;
    
    id bigger = [CCScaleTo actionWithDuration:0.07 scale:scale + 0.2];
    id normal = [CCScaleTo actionWithDuration:0.07 scale:scale];
    id seq = [CCSequence actions:bigger, normal, nil];
    [starScoreLabel runAction:seq];
    
    [self addScore:100*numLives];
}

- (void) skippedCatchers: (int) numCatchersSkipped {
    
    [UserData sharedInstance].skipCount += numCatchersSkipped;
    [self addScore: (500*numCatchersSkipped) + (10*[[MainGameScene sharedScene] level])];
}

- (void) cloudTouch {
    [self addScore: 1000];
}

// Called when player is released at the perfect moment from the catcher.
- (void) perfectRelease {
    
    [UserData sharedInstance].perfectJumpCount++;
    [self addScore: 150];
}

- (void) imperfectRelease {
    
    [UserData sharedInstance].imperfectJumpCount++;
}

- (void) initGripBar {
    
    /*gripNode = [CCNode node];
    CCSprite *filled = [CCSprite spriteWithFile:@"filled.png"];
//    filled.position = CGPointMake(pauseButton.position.x - [filled boundingBox].size.width * 2, 
//                                  screenSize.height - [filled boundingBox].size.height/2);
    filled.position = CGPointMake(0,0);

    [gripNode addChild:filled];
    
    gripDonut = [CCProgressTimer progressWithFile:@"empty.png"];
    gripDonut.type = kCCProgressTimerTypeRadialCW;
    gripDonut.position = filled.position;
    [gripNode addChild: gripDonut];
    
    CCSprite *stopWatch = [CCSprite spriteWithSpriteFrameName:@"ClockFilled.png"];
    stopWatch.scale = 0.5f;
    float stopWatchHeight = ssipadauto(8);//[stopWatch boundingBox].size.height - [filled boundingBox].size.height;
    stopWatch.position = ccp(0,stopWatchHeight);
    [gripNode addChild: stopWatch z:-1];
    
    gripNode.position = CGPointMake(screenSize.width - [filled boundingBox].size.width/2 - 5,
                                    screenSize.height - [filled boundingBox].size.height/2 - stopWatchHeight);
    origGripPos = gripNode.position;
    
    [self addChild:gripNode];*/
    
    pauseButton = [CCSprite spriteWithFile:@"pause.png"];
    pauseButton.position = CGPointMake(screenSize.width - [pauseButton boundingBox].size.width/2 - ssipadauto(5),
                                       screenSize.height - [pauseButton boundingBox].size.height/2 - ssipadauto(5));
    
    [self addChild:pauseButton];
}


#pragma - mark Game lifecycle
- (void) removePauseScreen {
    [self removeChildByTag:navigationScreenTag cleanup:YES];
    music = nil;
    soundFx = nil;
}

- (void) dismissScreen:(int)tagNumber action:(id)a {
    CCLayerColor *bg = (CCLayerColor*)[self getChildByTag:tagNumber];
    
    // Randomize disappearance to add some spice
    int chance = arc4random() % 4;
    CGPoint p;
    if (chance == 0) {
        p = CGPointMake(0, -screenSize.height);        
    }
    else if (chance == 1) {
        p = CGPointMake(0, screenSize.height);        
    }
    else if (chance == 2) {
        p = CGPointMake(-screenSize.width, 0);        
    }
    else if (chance == 3) {
        p = CGPointMake(screenSize.width, 0);                
    }
    
    id ease = [CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:screenTransitionTime
                                                                         position:p]];
    id removePausescreen = [CCCallFunc actionWithTarget:self selector:@selector(removePauseScreen)];
    id seq = [CCSequence actions:ease, a, removePausescreen, nil];
    [bg runAction:seq];    
}

- (void) resumeGameHelper {
    
    if (levelDisplay != nil) {
        levelDisplay.visible = YES;
    }
    
    id cb = [CCCallFuncO actionWithTarget:[GamePlayLayer sharedLayer] selector:@selector(resumeGame)];
    [self dismissScreen:navigationScreenTag action:cb];
}

- (void) gotoMainMenu {
    [[AudioEngine sharedEngine] stopBackgroundMusic];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 
                                                                                 scene:[MainMenuScene node]]];    

}

- (void) gotoLevelSelector {
    [[AudioEngine sharedEngine] stopBackgroundMusic];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5
                                                                                 scene:[LevelSelectScene nodeWithWorld: [MainGameScene sharedScene].world]]];
    
    //[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0
    //                                                                             scene:[GameLoadingScene nodeWithDelay:3 goTo:kGoToSceneLevelSelection world:[MainGameScene sharedScene].world level:-1]]];
}

- (void) gotoStore {
    //[[AudioEngine sharedEngine] stopBackgroundMusic];
    [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:0.5 scene:[StoreScene node]]];
    //[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0
    //                                                                             scene:[GameLoadingScene nodeWithDelay:3 goTo:kGoToSceneStore]]];
}

- (void) gotoBuyLives {
    //[[AudioEngine sharedEngine] stopBackgroundMusic];
    [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:0.5 scene:[StoreScene nodeWithScreen:kStoreLifeLineType]]];
    //[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0
    //                                                                             scene:[GameLoadingScene nodeWithDelay:3 goTo:kGoToSceneStore]]];
}

- (void) showObjectives {    
    // slide out the pause menu
    id easeOut = [CCEaseExponentialOut actionWithAction:[CCMoveBy actionWithDuration:screenTransitionTime position:ccp(screenSize.width, 0)]];
    
    id easeIn = [CCEaseExponentialIn actionWithAction:[CCMoveBy actionWithDuration:screenTransitionTime position:ccp(screenSize.width, 0)]];
    
    id pauseMenu = [self getChildByTag:navigationScreenTag];
    [pauseMenu runAction:easeOut];

    objectivesScreen.visible = YES;
    [objectivesScreen runAction:easeIn];
}

- (void) hideObjectives {
    id easeOut = [CCEaseExponentialOut actionWithAction:[CCMoveBy actionWithDuration:screenTransitionTime position:ccp(-screenSize.width, 0)]];
    
    id easeIn = [CCEaseExponentialIn actionWithAction:[CCMoveBy actionWithDuration:screenTransitionTime position:ccp(-screenSize.width, 0)]];
    
    id pauseMenu = [self getChildByTag:navigationScreenTag];
    
    
    [objectivesScreen runAction:easeOut];
    [pauseMenu runAction:easeIn];
}


- (void) restart {
    
    [UserData sharedInstance].restartCount++;
    numTries++;
    saveBtn.visible = NO;
    pauseButton.visible = YES;
    
    id resume = [CCCallFunc actionWithTarget:[GamePlayLayer sharedLayer] selector:@selector(resumeGame)];
    id cb = [CCCallFuncO actionWithTarget:[GamePlayLayer sharedLayer] 
                                 selector:@selector(restartGame:) 
                                   object:[NSNumber numberWithBool:NO]];
    id delay = [CCDelayTime actionWithDuration:0.1];
    id seq = [CCSequence actions:delay, resume, cb, nil];
    [self dismissScreen:navigationScreenTag action:seq];
}

- (BOOL) pauseAllowed {
    return pauseButton.visible;
}

- (void) pauseGame {
    
    [super pauseGame];
    
    if (levelDisplay != nil) {
        levelDisplay.visible = NO;
    }
    
    CCLayerColor *bg = [CCLayerColor getFullScreenLayerWithColor:ccc3to4(CC3_COLOR_BLUE, 100)];//ccc4(168, 213, 248, 200)];
    [self addChild:bg z:101 tag:navigationScreenTag];

    id ease;
    
    // Randomize where it comes from to add some spice
    int chance = arc4random() % 4;
    if (chance == 0) {
        bg.position = CGPointMake(0, -screenSize.height);        
    }
    else if (chance == 1) {
        bg.position = CGPointMake(0, screenSize.height);        
    }
    else if (chance == 2) {
        bg.position = CGPointMake(-screenSize.width, 0);        
    }
    else if (chance == 3) {
        bg.position = CGPointMake(screenSize.width, 0);                
    }
    
    /*CCSprite *logo = [CCSprite spriteWithFile:@"SwingStarLogo.png"];
    logo.anchorPoint = CGPointZero;
    logo.position = CGPointMake(screenSize.width/2 - [logo boundingBox].size.width/2, 
                                screenSize.height - [logo boundingBox].size.height - 10);
    [bg addChild:logo];*/
    
    // add music and sound buttons
    UserData *ud = [UserData sharedInstance];
    music = [CCSprite spriteWithFile:@"music.png"];
    music.scale = 0.75;
    GPImageButton *musicBtn = [GPImageButton controlOnTarget:self andSelector:@selector(toggleMusic) imageFromSprite: music];
    musicBtn.position = ccp(screenSize.width/2 - [music boundingBox].size.width, screenSize.height/2 + [music boundingBox].size.height + ssipad(200, 70));
    [bg addChild: musicBtn];
    music.opacity = ud.musicVolumeLevel > 0 ? 255 : 100;
    
    soundFx = [CCSprite spriteWithFile:@"sound.png"];
    soundFx.scale = 0.75;
    GPImageButton *soundFxBtn = [GPImageButton controlOnTarget:self andSelector:@selector(toggleSoundFx) imageFromSprite: soundFx];
    soundFxBtn.position = ccp(musicBtn.position.x + [music boundingBox].size.width/2 + ssipadauto(80), musicBtn.position.y);
    [bg addChild: soundFxBtn];
    soundFx.opacity = ud.fxVolumeLevel > 0 ? 255 : 100;
    
    [self initMusicAndSoundFx];
    
    GPImageButton *resume = [GPImageButton controlOnTarget:self andSelector:@selector(resumeGameHelper) imageFromFile:@"Button_Play.png"];
    resume.scaleX = 1.4;
    CCLabelBMFont *restartText = [CCLabelBMFont labelWithString:@"PLAY" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    restartText.scaleX = 0.8;
    [resume setText:restartText];
    resume.position = CGPointMake(screenSize.width/2, soundFxBtn.position.y - [soundFx boundingBox].size.height/2 - [resume size].height/2 -  ssipad(50, 10));
    [bg addChild:resume];

    GPImageButton *restart = [GPImageButton controlOnTarget:self andSelector:@selector(restart) imageFromFile:@"Button_Play.png"];
    restart.scaleX = 1.4;
    CCLabelBMFont *resumeText = [CCLabelBMFont labelWithString:@"RESTART" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    resumeText.scaleX = 0.8;
    [restart setText:resumeText];
    restart.position = CGPointMake(screenSize.width/2, resume.position.y - [resume size].height - ssipad(20, 0));
    [bg addChild:restart];

    GPImageButton *mainMenu = [GPImageButton controlOnTarget:self andSelector:@selector(gotoLevelSelector) imageFromFile:@"Button_Options.png"];
    mainMenu.scaleX = 1.4;
    CCLabelBMFont *mainMenuText = [CCLabelBMFont labelWithString:@"LEVELS" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    mainMenuText.scaleX = 0.8;
    [mainMenu setText:mainMenuText];
    mainMenu.position = CGPointMake(screenSize.width/2, restart.position.y - [restart size].height - ssipad(20, 0));
    [bg addChild:mainMenu];
    
    GPImageButton *objectives = [GPImageButton controlOnTarget:self andSelector:@selector(showObjectives) imageFromFile:@"Button_Store.png"];
    objectives.scaleX = 1.4;
    CCLabelBMFont *objectivesText = [CCLabelBMFont labelWithString:@"OBJECTIVES" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    objectivesText.scaleX = 0.8;
    [objectives setText:objectivesText];
    objectives.position = CGPointMake(screenSize.width/2, mainMenu.position.y - [mainMenu size].height - ssipad(20, 0));
    [bg addChild:objectives];
    
    GPImageButton *store = [GPImageButton controlOnTarget:self andSelector:@selector(gotoStore) imageFromFile:@"Button_Store.png"];
    store.scaleX = 1.4;
    CCLabelBMFont *storeText = [CCLabelBMFont labelWithString:@"STORE" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    storeText.scaleX = 0.8;
    [store setText:storeText];
    store.position = CGPointMake(screenSize.width/2, objectives.position.y - [objectives size].height - ssipad(20, 0));
    [bg addChild:store];
    
    //[store removeChildByTag:NEW_ITEM_TAG cleanup:YES];
    if ([StoreManager sharedInstance].newItemUnlocked) {
        
        CCSprite * newSprite = [CCSprite spriteWithFile:@"new.png"];
        newSprite.scale = 0.75;
        newSprite.position = ccp(ssipadauto(60),
                                 ssipadauto(20));
        [store addChild: newSprite z:2];// tag:NEW_ITEM_TAG];
    }

    ease = [CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:screenTransitionTime
                                                                      position:CGPointMake(0, 0)]];
    [bg runAction:ease];
}

- (void) initMusicAndSoundFx {
    
    //CCLOG(@"CURRENT MUSIC VOLUME %f, %f", [[AudioEngine sharedEngine] backgroundMusicVolume], [[AudioEngine sharedEngine] effectsVolume]);
    
    UserData * ud = [UserData sharedInstance];
    
    [self setMusicOn: ud.musicVolumeLevel > 0];
    [self setSoundOn: ud.fxVolumeLevel > 0];
}

- (void) toggleMusic {
    
    UserData * ud = [UserData sharedInstance];
    
    if (ud.musicVolumeLevel > 0) {
        ud.musicVolumeLevel = 0;
    } else {
        ud.musicVolumeLevel = 1;
    }
    
    [[AudioEngine sharedEngine] setBackgroundMusicVolume: ud.musicVolumeLevel];
    [self setMusicOn: ud.musicVolumeLevel > 0];
}

- (void) setMusicOn: (BOOL) on {
    
    float opacity = on ? 255 : 100;
    
    music.opacity = opacity;
}

- (void) toggleSoundFx {
    
    UserData * ud = [UserData sharedInstance];
    
    if (ud.fxVolumeLevel > 0) {
        ud.fxVolumeLevel = 0;
    } else {
        ud.fxVolumeLevel = 1;
    }
    
    [[AudioEngine sharedEngine] setEffectsVolume: ud.fxVolumeLevel];
    [self setSoundOn: ud.fxVolumeLevel > 0];
}

- (void) setSoundOn: (BOOL) on {
    
    float opacity = on ? 255 : 100;
    
    soundFx.opacity = opacity;
}


- (void) showLevelCompleteScreen {
    
    numTries = 0;
    [[MainGameScene sharedScene] levelComplete:[UserData sharedInstance]];
}

- (void) showGameOverDialogHelper {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GLOBAL_LOCK object:nil]; // block input to the button
    [saveBtn stopAllActions];
    [self stopAllActions];
    saveBtn.visible = NO;
    [super pauseGame];
    CCLayerColor *bg = [CCLayerColor getFullScreenLayerWithColor:ccc3to4(CC3_COLOR_BLUE, 200)]; //ccc4(168, 213, 248, 200)];
    [self addChild:bg z:300 tag:navigationScreenTag];
    
    id ease;
    
    // Randomize where it comes from to add some spice
    int chance = arc4random() % 4;
    if (chance == 0) {
        bg.position = CGPointMake(0, -screenSize.height);        
    }
    else if (chance == 1) {
        bg.position = CGPointMake(0, screenSize.height);        
    }
    else if (chance == 2) {
        bg.position = CGPointMake(-screenSize.width, 0);        
    }
    else if (chance == 3) {
        bg.position = CGPointMake(screenSize.width, 0);                
    }
    
    /*CCSprite *logo = [CCSprite spriteWithFile:@"SwingStarLogo.png"];
    logo.anchorPoint = CGPointZero;
    logo.position = CGPointMake(screenSize.width/2 - [logo boundingBox].size.width/2, 
                                screenSize.height - [logo boundingBox].size.height - 10);
    [bg addChild:logo];*/
    
    NSMutableString *level = [NSMutableString stringWithString: [MainGameScene sharedScene].world];
    [level appendFormat:@" - Level %d", [MainGameScene sharedScene].level];
    
    CCLabelBMFont *gameOverText = [CCLabelBMFont labelWithString:level fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    gameOverText.position = CGPointMake(screenSize.width/2, screenSize.height - [gameOverText boundingBox].size.height/2 - ssipad(90, 40));
    gameOverText.color = FONT_COLOR_YELLOW;
    [bg addChild:gameOverText];
    
    UserData * ud = [UserData sharedInstance];
    
    CCLabelBMFont *coins = [CCLabelBMFont labelWithString: [NSString stringWithFormat:@"Collected %d coins", ud.currentCoins] fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    coins.position = ccp(screenSize.width/2, gameOverText.position.y - [coins boundingBox].size.height - ssipad(20, 0));
    coins.color = FONT_COLOR_RED;
    coins.scale = 0.8;
    [bg addChild: coins];
    
    CCLabelBMFont *totalCoins = [CCLabelBMFont labelWithString: [NSString stringWithFormat:@"%d total coins", ud.totalCoins] fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    totalCoins.position = ccp(coins.position.x, coins.position.y - ssipadauto(20));
    totalCoins.scale = 0.6;
    [bg addChild: totalCoins];
    
    GPImageButton *restart = [GPImageButton controlOnTarget:self andSelector:@selector(restart) imageFromFile:@"Button_Play.png"];
    restart.scaleX = 1.4;
    CCLabelBMFont *restartText = [CCLabelBMFont labelWithString:@"PLAY" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    restartText.scaleX = 0.8;
    [restart setText:restartText];
    restart.position = CGPointMake(screenSize.width/2, totalCoins.position.y - [restart size].height - ssipad(100, 25));
    [bg addChild:restart];
    
    
    GPImageButton *mainMenu = [GPImageButton controlOnTarget:self andSelector:@selector(gotoLevelSelector) imageFromFile:@"Button_Options.png"];
    mainMenu.scaleX = 1.4;
    CCLabelBMFont *mainMenuText = [CCLabelBMFont labelWithString:@"LEVELS" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    mainMenuText.scaleX = 0.8;
    [mainMenu setText:mainMenuText];
    mainMenu.position = CGPointMake(screenSize.width/2, restart.position.y - [restart size].height - ssipad(20, 5));
    [bg addChild:mainMenu];
    
    GPImageButton *store = [GPImageButton controlOnTarget:self andSelector:@selector(gotoStore) imageFromFile:@"Button_Store.png"];
    store.scaleX = 1.4;
    CCLabelBMFont *storeText = [CCLabelBMFont labelWithString:@"STORE" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    storeText.scaleX = 0.8;
    [store setText:storeText];
    store.position = CGPointMake(screenSize.width/2, mainMenu.position.y - [mainMenu size].height - ssipad(20, 5));
    [bg addChild:store];
    
    //[store removeChildByTag:NEW_ITEM_TAG cleanup:YES];
    if ([StoreManager sharedInstance].newItemUnlocked) {
        
        CCSprite * newSprite = [CCSprite spriteWithFile:@"new.png"];
        newSprite.scale = 0.75;
        newSprite.position = ccp(ssipadauto(60),
                                 ssipadauto(20));
        [store addChild: newSprite z:2];// tag:NEW_ITEM_TAG];
    }
    
    ease = [CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:screenTransitionTime
                                                                      position:CGPointMake(0, 0)]];
    [bg stopAllActions];
    [bg runAction:ease];    
}

- (void) showGameOverDialog {
    
    g_block = YES;
    id delay = [CCDelayTime actionWithDuration:0.25];
    id func = [CCCallFunc actionWithTarget:self selector:@selector(showGameOverDialogHelper)];
    id seq = [CCSequence actions:delay, func, nil];
    [self stopAllActions];
    [self runAction:seq];
//    GPDialog *dialog = [GPDialog controlOnTarget:[GamePlayLayer sharedLayer]
//                                      okCallBack:@selector(restartGame:) 
//                                  cancelCallBack:nil 
//                                          okText:@"OK" 
//                                      cancelText:nil 
//                                      withObject:[NSNumber numberWithBool:NO]];
//    NSArray *texts = [NSArray arrayWithObjects:@"BOO HOO", nil];
//    dialog.title = @"YOU SUCK! TRY AGAIN!";
//    dialog.texts = texts;
//    [dialog buildScreen];
//    [self addChild:dialog];    
}

- (void) dealloc {
    CCLOG(@"----------------------------- HUDLayer dealloc");

    [self unscheduleAllSelectors];
    [self stopAllActions];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_GAME_STARTED object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PLAYER_CAUGHT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_ENEMY_KILLED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_BLOCK_BROKEN object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PLAYER_REVIVED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PLAYER_IN_AIR object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PLAYER_FELL object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NICE_JUMP object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_GAME_OVER object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_FINISHED_LEVEL object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_WIND_BLOWING object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_POWERUP_ACTIVATED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_POWERUP_FADING object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_POWERUP_DEACTIVATED object:nil];
    
    [super dealloc];
}


@end
