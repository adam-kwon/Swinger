//
//  Ground.h
//  Swinger
//
//  Created by James Sandoz on 4/22/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//


#import "Box2d.h"
#import "GameObject.h"
#import "PhysicsObject.h"

@interface Ground : CCNode<GameObject, PhysicsObject> {
    int gameObjectId;
    
    b2World *world;
    b2Body *groundBody;
    b2Fixture *groundFixture;

    b2Vec2 previousPosition;
    b2Vec2 smoothedPosition;
    float previousAngle;
    float smoothedAngle;

    BOOL isSafeToDelete;
}

- (id) initWithParent:(CCNode *)parent;
- (void) moveTo:(CGPoint)pos;

@property (nonatomic,readonly) b2Body *groundBody;

@end
