//
//  StrongMan.h
//  Swinger
//
//  Created by Isonguyo Udoka on 7/4/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CCNode.h"
#import "GameObject.h"
#import "PhysicsObject.h"

typedef enum {
    kStrongManNone,
    kStrongManStanding,
    kStrongManRunning,
    kStrongManJumping,
    kStrongManSmashing,
    kStrongManDone
} StrongManState;

@interface StrongMan : CCNode<GameObject, PhysicsObject> {

    int gameObjectId;

    CGSize     screenSize;
    
    CCNode    *parent;
    CCSprite  *strongMan;
    CCNode    *trailNode;
    
    CCSprite  *jumpTrailFrames[4];
    CCSprite  *smashTrailFrames[4];
    ccTime    jumpDelta;
    int       jumpCount;
    
    CCAction * currentAnim;
    BOOL       isSafeToDelete;
    
    StrongManState state;
    b2World *world;
    b2Body *body;
    
    b2Vec2 previousPosition;
    b2Vec2 smoothedPosition;
    float previousAngle;
    float smoothedAngle;
    
    ccTime dtSum;
    
    CGPoint finalPosition;
    float startingPosX;
    float jumpPosX;
    float maxJumpHeight;
    float currentJumpHeight;
    int   currentJumpCount;
    
    float runSpeed;
    int   numJumps;
    float jumpForce;
    
    BOOL  animationsLoaded;
    BOOL  started;
}

- (void) showAt:(CGPoint)pos;
- (void) begin;
- (void) reset;

@end
