//
//  Hunter.h
//  Swinger
//
//  Created by Isonguyo Udoka on 8/7/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "GameObject.h"
#import "PhysicsObject.h"
#import "CCSprite.h"
#import "Enemy.h"
#import "Player.h"

@interface Hunter : Enemy {
    
    CCSprite * hunterSprite;
    float currStartPosX;
    float walkDistance;
    float walkSpeed;
    CGPoint startPosition;
    BOOL startedWalking;
    
    b2Fixture * hunterFixture;
    b2Filter    onlyCollideWithPlatform;
    b2Filter    collideWithNothing;
}

+ (id) make: (float) theWalkDistance speed: (float) theSpeed;
- (void) collideWithNothing;

@property (nonatomic, readwrite, assign) float walkDistance;
@property (nonatomic, readwrite, assign) float walkSpeed;

@end
