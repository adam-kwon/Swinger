//
//  HUDLayer.h
//  Swinger
//
//  Created by James Sandoz on 5/29/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Wind.h"

@class Coin;
@class Star;
@class GPImageButton;
@class ObjectivesScreen;

@interface HUDLayer : CCLayer {
    
    CGSize          screenSize;
    CCNode          *gripNode;
    CCProgressTimer *gripDonut;    
    
    CCSprite        *pauseButton;

    CCNode          *windDisplay;
    CCLabelTTF      *windLabel;
    CCSprite        *windArrow;
    CCLabelBMFont   *windSpeed;
    CCLabelBMFont   *levelDisplay;
    
    //int             starScore;
    CCSprite        *starScoreIcon;
    CCLabelBMFont   *starScoreLabel;
    
    //int             coinScore;
    CCSprite        *coinScoreIcon;
    CCLabelBMFont   *coinScoreLabel;
    
    CCNode          *powerUpIcon;
    
    CCLabelBMFont   *scoreLabel;

    CCSprite        *tapButton;
    CCSprite        *music;
    CCSprite        *soundFx;
    GPImageButton   *saveBtn;
    
    BOOL             initialCatch;
    BOOL             niceJump;
    int              numTries;
    
    BOOL             reviveRequested;
    
    ObjectivesScreen *objectivesScreen;
}

+ (HUDLayer*) sharedLayer;

- (void) resetGripBar;
- (void) countDownGrip:(float)interval;
- (void) displayWind: (Wind *) wind;
- (void) displayLevel;
- (void) gotoBuyLives;

- (void) showLevelCompleteScreen;
- (void) showGameOverDialog;

- (void) addCoin;
- (void) addCoin: (int) amount;
- (void) addBonusCoin: (int) amount;
- (void) addLife;
- (void) addLife: (int) amount;

- (void) skippedCatchers: (int) numCathersSkipped;
- (void) cloudTouch;

- (void) collectCoin:(Coin *)coin;
- (void) collectStar:(Star *)star;

- (void) resetScores;
- (BOOL) pauseAllowed;

- (BOOL) handleTouchEvent:(CGPoint)touchPoint;

@end
