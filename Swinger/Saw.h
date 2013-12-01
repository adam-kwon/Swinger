//
//  Saw.h
//  Swinger
//
//  Created by Isonguyo Udoka on 8/27/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Enemy.h"
#import "AudioEngine.h"

@interface Saw : Enemy {
    
    CCSprite * saw1;
    CCSprite * saw2;
    CCSprite * sawCenter;
    ALuint     sawSound;
    
    float flyDistance;
    float flySpeed;
    float currStartPosY;
    CGPoint startPosition;
    BOOL startedMoving;
    
    float dtSum;
    
    b2Body * anchor;
    b2Fixture * sawBodyFixture;
    b2Body * saw1Body;
    b2Fixture * saw1BodyFixture;
    b2Body * saw2Body;
    b2Fixture * saw2BodyFixture;
    
    b2Joint * pivotJoint;
    b2Joint * saw1Joint;
    b2Joint * saw2Joint;
}

+ (id) make: (float) theFlyDistance speed: (float) theSpeed;

@property (nonatomic, readwrite, assign) float flyDistance;
@property (nonatomic, readwrite, assign) float flySpeed;

@end
