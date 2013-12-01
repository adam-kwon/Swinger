//
//  Cannon.h
//  Swinger
//
//  Created by Isonguyo Udoka on 6/2/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CCSprite.h"
#import "GameObject.h"
#import "PhysicsObject.h"
#import "CatcherGameObject.h"
#import "BaseCatcherObject.h"
#import "CannonBlast.h"
#import "CannonFuse.h"

typedef enum {
    kCannonNone,
    kCannonLoaded,
    kCannonShot,
    kCannonShotStraightUp,
    kCannonDestroy,
    kCannonDestroyed
} CannonState;

typedef enum {
    
    kCannonRotatingLeft,
    kCannonRotatingRight,
    
} CannonRotationState;

@class Player;

@interface Cannon : BaseCatcherObject {
    
    CannonState state;
    CannonRotationState rotationState;
    
    //b2Body    *anchor;
    b2Body    *fuse;
    b2Fixture *barrelFixture;
    
    Player    *player;
    
    b2RevoluteJoint *revJoint;
    
    //CCSprite  *anchorSprite;
    CCSprite  *barrelSprite;
    CCSprite  *barrelLoadedSprite;
    
    // cannon blast and smoke particles
    CannonBlast *blastEffect;
    CCParticleSystem *smoke;
    CannonFuse *fuseEffect;
    
    float rotationAngle;
    float prevAngle;
    float prevPhase;
    float motorSpeed;
    
    float waitAngle;
    BOOL  initialized;
    
    float minSpeed; // rotation speed
    float shootingForce;
    
    double deltaTime;
    double dtSum;
    
    float timeout; // Cannon's 'grip'
    BOOL trajectoryDrawn;
    CCArray *dashes; // storing dashes for cleanup
    
    BOOL shootImmediately;
    b2Joint * jointWithPlayer;
}

- (void) showAt:(CGPoint)pos;
- (void) load: (Player *) player shoot: (BOOL) shoot;
- (void) shoot;

@property (nonatomic, readonly) CCSprite *barrelSprite;
//@property (nonatomic, readonly) CCSprite *anchorSprite;
@property (nonatomic, readonly) CGPoint  anchorPos;
@property (nonatomic, readonly) Player   *player;

@property (nonatomic, readwrite, assign) float motorSpeed;
@property (nonatomic, readwrite, assign) float shootingForce;
@property (nonatomic, readwrite, assign) float rotationAngle;
@property (nonatomic, readwrite, assign) float timeout;

@end
