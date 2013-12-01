//
//  DummyCatcherObject.h
//  Swinger
//
//  Created by Min Kwon on 6/14/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CCSprite.h"
#import "GameObject.h"
#import "PhysicsObject.h"
#import "CatcherGameObject.h"

@interface DummyCatcherObject : CCNode<GameObject, PhysicsObject, CatcherGameObject> {
    int gameObjectId;
    
    b2World *world;
    b2Body *body;

    BOOL isSafeToDelete;
    NSArray *levelObjects;
    int indexInLevelObjects;

    b2Vec2 previousPosition;
    b2Vec2 smoothedPosition;
    float previousAngle;
    float smoothedAngle;

}

- (void) showAt:(CGPoint)pos;

@end
