//
//  Crow.h
//  Scroller
//
//  Created by min on 3/14/11.
//  Copyright 2011 GAMEPEONS LLC. All rights reserved.
//

#import "GameObject.h"
#import "Constants.h"
#import "PhysicsObject.h"

typedef enum {
    kBirdStateNone,
    kBirdSitting,
    kBirdFlying,
    kBirdDestroy,
    kBirdDestroyed
} BirdState;


@interface Crow : CCSprite<GameObject, PhysicsObject> {
    int gameObjectId;

    BirdState state; 
    BOOL      safeToDelete;
    
    b2World   *world;
    b2Body    *body;
    
    b2Vec2 previousPosition;
    b2Vec2 smoothedPosition;
    float previousAngle;
    float smoothedAngle;

}

+ (void) resetAnimations;

- (void) fly;
- (void) updateObjectOnParallax;

@property (nonatomic, readwrite) BirdState state;

@end
