//
//  DummyCatcherObject.m
//  Swinger
//
//  Created by Min Kwon on 6/14/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "DummyCatcherObject.h"

@implementation DummyCatcherObject

@synthesize gameObjectId;

- (id) init {
	if ((self = [super init])) {
    }
    
    return self;
}


- (void) createPhysicsObject:(b2World*)theWorld {
    world = theWorld;
        
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.fixedRotation = YES;
    bodyDef.userData = self;
    bodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    body = world->CreateBody(&bodyDef);
    
    b2PolygonShape box;
    box.SetAsBox(10.f/PTM_RATIO/2, 10.f/PTM_RATIO/2);
    
    b2FixtureDef catcherFixtureDef;
    catcherFixtureDef.shape = &box;
    catcherFixtureDef.isSensor = YES;
    
    body->CreateFixture(&catcherFixtureDef);       
}


- (void) setCollideWithPlayer:(BOOL)doCollide {
}

- (void) updateObject:(ccTime)dt scale:(float)scale {
}


-(void) moveTo:(CGPoint)pos {
    self.position = pos;
    
    //XXX necessary?  Will the weld joint automatically move him with the rope?
    body->SetTransform(b2Vec2(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO), 0);    
}

-(void) showAt:(CGPoint)pos {
    
    // Move the building
    [self moveTo:pos];
    [self show];
}

- (GameObjectType) gameObjectType {
    return kGameObjectDummy;
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

- (void) hide {
    self.visible = NO;
    body->SetActive(NO);
}

- (void) show {
    self.visible = YES;    
}

#pragma mark - CatcherGameObject protocl

- (int) getIndexInLevelObjects {
    return indexInLevelObjects;
}

- (void) setIndexInLevelObjects:(int)index {
    indexInLevelObjects = index;
}

- (void) setLevelObjects:(NSArray*)currentLevelObjects {
    levelObjects = currentLevelObjects;
}

- (NSArray*) getLevelObjects {
    return levelObjects;
}

- (CCNode<GameObject, PhysicsObject, CatcherGameObject>*) getNextCatcherGameObject {
    if (indexInLevelObjects + 1 < [levelObjects count]) 
        return [levelObjects objectAtIndex:indexInLevelObjects+1];
    
    // Last object is the final platform
    return [levelObjects lastObject];
}

- (float) distanceToNextCatcher {
    CCNode<GameObject> *nextObject = [self getNextCatcherGameObject];
    float distanceToNextCatcher = nextObject.position.x - self.position.x; 
    return distanceToNextCatcher;
}

- (void) setSwingerVisible:(BOOL)visible {
}

- (void) reset {
    //
}

- (CGPoint) getCatchPoint {
    return CGPointZero;
}

- (float) getHeight {
    return 0;
}

- (b2Body*) getPhysicsBody {
    return body;
}

- (void) destroyPhysicsObject {
    if (world != NULL) {
        world->DestroyBody(body);
    }
}

- (void) dealloc {
    CCLOG(@"------------------------------ Dummy being deallocated");
    [super dealloc];
}

- (BOOL) isSafeToDelete {
    return isSafeToDelete;
}

- (void) safeToDelete {
    isSafeToDelete = YES;
}


@end
