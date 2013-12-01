/*
 *  PhysicsObject.h
 *  Scroller
 *
 *  Created by min on 3/1/11.
 *  Copyright 2011 GAMEPEONS LLC. All rights reserved.
 *
 */

#import "Box2D.h"

@protocol PhysicsObject

- (void) createPhysicsObject:(b2World *)theWorld;
- (void) destroyPhysicsObject;
- (b2Vec2) previousPosition;
- (b2Vec2) smoothedPosition;
- (void) setPreviousPosition:(b2Vec2)p;
- (void) setSmoothedPosition:(b2Vec2)p;
- (float) previousAngle;
- (float) smoothedAngle;
- (void) setPreviousAngle:(float)a;
- (void) setSmoothedAngle:(float)a;
- (b2Body*) getPhysicsBody;

@end