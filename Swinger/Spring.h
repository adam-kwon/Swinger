//
//  Spring.h
//  Swinger
//
//  Created by Isonguyo Udoka on 6/7/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CCSprite.h"
#import "GameObject.h"
#import "PhysicsObject.h"
#import "CatcherGameObject.h"
#import "BaseCatcherObject.h"

typedef enum {
    kSpringNone,
    kSpringLoaded,
    kSpringFellApart,
    kSpringDestroy,
    kSpringDestroyed
} SpringState;

@class Player;

// Object that bounces the player off in a line tangent to the angle the player impacted it at
@interface Spring : BaseCatcherObject {
    
    b2Body    *anchor;
    b2Fixture *topFixture;
    
    b2PrismaticJoint *springJoint;
    
    CCSprite  *topSprite;
    CCSprite  *springSprite;
    CCSprite  *anchorSprite;
    Player    *player;
    int       springCount;
    
    float     bounceFactor;
    BOOL      bounceRequested;
    
    float     deltaTime;
    
    SpringState state;
    float     timeout;
    
    BOOL      trajectoryDrawn;
    CCArray  *dashes;
}

- (void) showAt:(CGPoint)pos;
- (void) catchPlayer:(Player *) player;
- (void) bounce;
- (void) fallApart;
- (void) createSpring;
- (void) unloadPlayer;

@property (nonatomic, readonly) CCSprite *topSprite;
@property (nonatomic, readonly) CCSprite *springSprite;
@property (nonatomic, readonly) CCSprite *anchorSprite;
@property (nonatomic, readonly) SpringState state;
@property (nonatomic, readonly) BOOL bounceRequested;

@property (nonatomic, readwrite, assign) float timeout;
@property (nonatomic, readwrite, assign) float bounceFactor;

@end
