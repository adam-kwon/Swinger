//
//  Missile.h
//  Swinger
//
//  Created by Isonguyo Udoka on 8/30/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Enemy.h"

typedef enum {
    kProjectileMissile,
    kProjectileGrenade
} ProjectileType;

@interface Missile : CCNode<GameObject, PhysicsObject>
{
    int gameObjectId;
    
    ProjectileType projectileType;
    Enemy * target;
    BOOL isSafeToDelete;
    b2Body *body;
    b2World *world;
    CGSize screenSize;
    
    CCSprite *sprite;
    b2Fixture *missileFixture;
    CGPoint startPosition;
    BOOL startedMoving;
    float speed;
    
    b2Vec2 previousPosition;
    b2Vec2 smoothedPosition;
    float previousAngle;
    float smoothedAngle;
}

+ (id) make: (Enemy *) theTarget;
+ (id) make: (Enemy *) theTarget pos: (CGPoint) startPos;
+ (id) make: (ProjectileType) projectileType target: (Enemy *) theTarget pos: (CGPoint) startPos;
- (BOOL) destroyTarget: (Enemy *) theTarget;

@end
