//
//  Ground.m
//  Swinger
//
//  Created by James Sandoz on 4/22/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Ground.h"
#import "Constants.h"
#import "GamePlayLayer.h"

@implementation Ground

@synthesize groundBody;
@synthesize gameObjectId;

- (id) initWithParent:(CCNode *)parent {
    
    if ((self = [super init])) {
        [[GamePlayLayer sharedLayer] addChild:self];
    }
    
    return self;
}


- (void) createPhysicsObject:(b2World*)theWorld {    
    world = theWorld;
    
    b2BodyDef groundDef;
    groundDef.type = b2_staticBody;
    groundDef.position = b2Vec2(0,-4);
    groundDef.userData = self;
    groundBody = world->CreateBody(&groundDef);
    CCLOG(@"ground body=%p\n", groundBody);
    
    b2EdgeShape platformShape;
    platformShape.Set(b2Vec2(-10000/PTM_RATIO, 0),
                      b2Vec2(100000/PTM_RATIO, 0));

    //b2PolygonShape groundBox;
    //groundBox.SetAsBox(100000/PTM_RATIO, 5/PTM_RATIO);
    
    b2FixtureDef groundFixtureDef;
    groundFixtureDef.shape = &platformShape;
    groundFixtureDef.friction = 10.f;
    groundFixtureDef.density = 100.0f;
    //groundFixtureDef.isSensor = true;
    groundFixtureDef.filter.categoryBits = CATEGORY_GROUND;
    groundFixtureDef.filter.maskBits = CATEGORY_JUMPER | CATEGORY_ENEMY;// | CATEGORY_ELEPHANT;
    groundFixture = groundBody->CreateFixture(&groundFixtureDef);
}


- (void) moveTo:(CGPoint)pos {
    
}


- (GameObjectType) gameObjectType {
    return kGameObjectGround;
}

- (b2Vec2) previousPosition {
    return previousPosition;
}

- (b2Vec2) smoothedPosition {
    return smoothedPosition;
}

- (void) setPreviousPosition:(b2Vec2)p {
    previousPosition = p;
}

- (void) setSmoothedPosition:(b2Vec2)p {
    smoothedPosition = p;
}

- (float) previousAngle {
    return previousAngle;
}

- (float) smoothedAngle {
    return smoothedAngle;
}

- (void) setPreviousAngle:(float)a {
    previousAngle = a;
}

- (void) setSmoothedAngle:(float)a {
    smoothedAngle = a;
}

- (void) show {
    
}

- (void) hide {
    
}

- (void) reset {
    //
}

- (void) updateObject:(ccTime)dt scale:(float)scale {
    
    CCLOG(@"ground.updateObject(), userData=%@\n", groundFixture->GetUserData());
    
}

- (b2Body*) getPhysicsBody {
    return groundBody;
}

- (void) destroyPhysicsObject {
    
    if (world != NULL) {
        world->DestroyBody(groundBody);
    }
}


- (BOOL) isSafeToDelete {
    return isSafeToDelete;
}

- (void) safeToDelete {
    isSafeToDelete = YES;
}

@end
