//
//  Coin.h
//  Swinger
//
//  Created by Min Kwon on 6/19/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "GameObject.h"
#import "PhysicsObject.h"

typedef enum {
    kCoinStateNone,
    kCoinStateCollecting,
    kCoinStateMagnetized,
    kCoinStateDoubled,
    kCoinStateExploding,
    kCoinStateHidden,
    kCoinStateDestroy
} CoinState;

@interface Coin : CCNode<GameObject, PhysicsObject> {
    int gameObjectId;

    BOOL isSafeToDelete;
    BOOL startedMoving;
    BOOL hitPlayer;
    CCSprite *coin;
    CoinState state;
    CGSize screenSize;
    GameObjectType type; // 1, 5, 10
    
    ARCH_OPTIMAL_PARTICLE_SYSTEM *explosion;
    b2World *world;
    b2Body *body;
    
    CGPoint startingPosition;
    b2Vec2 previousPosition;
    b2Vec2 smoothedPosition;
    float previousAngle;
    float smoothedAngle;
    
    float currentMagnetRange;
}

- (void) showAt:(CGPoint)pos;
- (int) getValue;
- (void) collect;
- (void) explode;

+ (id) make; // makes coin with value 1
+ (id) make: (GameObjectType) type;

@end
