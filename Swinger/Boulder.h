//
//  Boulder.h
//  Swinger
//
//  Created by Isonguyo Udoka on 6/18/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CCSprite.h"
#import "Enemy.h"
#import "Player.h"

@interface Boulder : Enemy {
    
    Player    *player;
    
    b2Body     * anchor;
    b2Fixture  * boulder;
    
    b2WeldJoint * boulderJoint;
    b2Joint     * playerJoint;
    
    CCSprite    *boulderSprite;
    //CCSprite    *baseSprite;
    ALuint      sound;
    
    float       dtSum;
    float       playerXPos;
    BOOL        firstUpdate;
    
    float       motorSpeed; // spin rate
    float       radius; // need this because Boulder sprite is not a perfect circle, if I calculate radius on the fly i get different values over time
    
    CGPoint     startLocation;
    CGPoint     loadPosition;
    BOOL        startedRolling;
    BOOL        doUnload;
    
    b2Filter    collideWithNothing;
}

- (void) unload;
- (void) doUnload;
- (void) shakeScreen;

@property (nonatomic, readwrite, assign) float motorSpeed;

@end
