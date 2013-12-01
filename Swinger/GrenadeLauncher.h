//
//  GameChanger.h
//  Swinger
//
//  Created by Isonguyo Udoka on 11/2/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "PowerUp.h"
#import "Enemy.h"

typedef enum {
    kGrenadeNone,
    kGrenadeTriggered,
    kGrenadeDetonated,
    kGrenadeComplete
} GrenadeState;

@interface GrenadeLauncher : PowerUp {
    
    GrenadeState grenadeState;
    CCSprite * detonator;
    CGPoint detonationPoint;
}

+ make;

- (float) getRange;
- (void) trigger;
- (void) launchAt: (Enemy*) enemy;

@property (nonatomic, readonly) GrenadeState grenadeState;

@end
