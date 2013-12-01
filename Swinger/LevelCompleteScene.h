//
//  LevelCompleteScene.h
//  Swinger
//
//  Created by Isonguyo Udoka on 7/18/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CCScene.h"
#import "PlayerTrail.h"
#import "HappyStars.h"
#import "GPImageButton.h"
#import "UserData.h"

@interface LevelCompleteScene : CCScene<CCTargetedTouchDelegate> {
    
    CGSize        screenSize;
    CCNode        *content;
    CCNode        *scoreSheet;
    CCLabelBMFont *scoreCardMessage;
    
    CCLabelBMFont *world;
    CCLabelBMFont *level;
    
    CCLabelBMFont *time;
    CCLabelBMFont *bestTime;
    CCLabelBMFont *score;
    CCLabelBMFont *high;
    
    CCLabelBMFont *coins;
    CCLabelBMFont *totalCoins;
    CCLabelBMFont *stars;
    CCLabelBMFont *totalStars;
    
    GPImageButton *store;
    GPImageButton *play;
    
    CCNode        *scoreCards;
    CCArray       *scores;
    
    // anim
    CCSprite      *background;
    CCLayerColor  *shadow;
    CCLayerColor  *rope;
    CCLayerColor  *separator;
    CCSprite      *cap;
    CCSprite      *handle;
    CCSprite      *pole;
    CCSprite      *logo;
    PlayerTrail   *logoTrail;
    HappyStars    *msgEffects;
    
    double        highScore;
}

+ (id) nodeWithStats:(UserData *) stats world: (NSString *) world level: (int) level;

@end
