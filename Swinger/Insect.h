//
//  Insect.h
//  Swinger
//
//  Created by Isonguyo Udoka on 8/16/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Enemy.h"
#import "AudioEngine.h"

typedef enum {
    kInsectMovingUp,
    kInsectMovingDown
} InsectMoveDirection;

@interface Insect : Enemy {
    
    CCSprite * insectSprite;
    float currStartPosY;
    float flyDistance;
    float flySpeed;
    CGPoint startPosition;
    BOOL startedFlying;
    BOOL killedByPlayer;
    
    b2Fixture * insectFixture;
    
    ALuint sound;
    CCParticleSystem *smoke;
}

+ (id) make: (float) theFlyDistance speed: (float) theSpeed;

@property (nonatomic, readwrite, assign) float flyDistance;
@property (nonatomic, readwrite, assign) float flySpeed;

@end
