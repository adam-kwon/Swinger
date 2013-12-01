//
//  Barrel.h
//  Swinger
//
//  Created by Isonguyo Udoka on 11/12/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Enemy.h"

typedef enum {
    kBarrelStateNone,
    kBarrelStateExploded
} BarrelState;

@interface Barrel : Enemy {
    
    BarrelState barrelState;
    CCSprite * barrelSprite;
    
    BOOL doSkid;
    
    b2Fixture * barrelFixture;
    b2Fixture * spillFixture;
    b2Filter    onlyCollideWithPlatform;
    b2Filter    collideWithNothing;
}

+ (id) make;
- (void) collideWithNothing;
- (void) skid;

@end
