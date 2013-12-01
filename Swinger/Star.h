//
//  Star.h
//  Swinger
//
//  Created by Min Kwon on 6/14/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "GameObject.h"
#import "PhysicsObject.h"

typedef enum {
    kStarStateNone,
    kStarStateCollecting,
    kStarStateExploding,
    kStarStateHidden,
    kStarStateDestroy
} StarState;

@interface Star : CCNode<GameObject, PhysicsObject> {
    int gameObjectId;

    BOOL isSafeToDelete;

    CCSprite *star;
    StarState state;
    ARCH_OPTIMAL_PARTICLE_SYSTEM *explosion;
    b2World *world;
    b2Body *body;
    
    CGSize screenSize;
    
    CGPoint startingPosition;
    b2Vec2 previousPosition;
    b2Vec2 smoothedPosition;
    float previousAngle;
    float smoothedAngle;
}

+ (id) make;
- (void) showAt:(CGPoint)pos;
- (void) collect;
- (void) explode;

@end
