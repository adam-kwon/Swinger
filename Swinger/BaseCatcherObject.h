//
//  BaseCatcherObject.h
//  Swinger
//
//  Created by Min Kwon on 6/15/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "GameObject.h"
#import "PhysicsObject.h"
#import "CatcherGameObject.h"

@class Wind;

@interface BaseCatcherObject : CCNode<GameObject, PhysicsObject, CatcherGameObject> {
    CGSize screenSize;
    
    int gameObjectId;
    int indexInLevelObjects;
    BOOL isSafeToDelete;
    NSArray *levelObjects;

    b2World *world;
    b2Body *body;
    b2Filter collideWithPlayer;
    b2Filter noCollideWithPlayer;

    b2Vec2 previousPosition;
    b2Vec2 smoothedPosition;
    float previousAngle;
    float smoothedAngle;
    
    Wind *wind;
}

- (void) showAt:(CGPoint)pos;

@property (nonatomic, readwrite, assign) Wind * wind;

@end
