//
//  BaseCatcherObject.m
//  Swinger
//
//  Created by Min Kwon on 6/15/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "BaseCatcherObject.h"

@implementation BaseCatcherObject

@synthesize wind;
@synthesize gameObjectId;

#pragma mark - GameObject protocol

- (int) getId {
    return gameObjectId;
}

- (GameObjectType) gameObjectType {
    NSAssert(NO, @"This is an abstract method and should be overridden");    
    return kGameObjectNone;
}

- (void) updateObject:(ccTime)dt scale:(float)scale {
    NSAssert(NO, @"This is an abstract method and should be overridden");
}


- (void) show {
    self.visible = YES;
    body->SetActive(YES);
}

- (void) hide {
    self.visible = NO;
    body->SetActive(NO);
}

#pragma mark - PhysicsObject protocol
// Do not override unless absolutely necessary
- (BOOL) isSafeToDelete {
    return isSafeToDelete;
}

// Do not override unless absolutely necessary
- (void) safeToDelete {
    isSafeToDelete = YES;
}

- (b2Body*) getPhysicsBody {
    return body;
}

- (void) destroyPhysicsObject {
    if (world != NULL) {
        world->DestroyBody(body);
    }
}

- (void) createPhysicsObject:(b2World *)theWorld {
    NSAssert(NO, @"This is an abstract method and should be overridden");    
}

// Do not override unless absolutely necessary
- (b2Vec2) previousPosition {
    return previousPosition;
}

// Do not override unless absolutely necessary
- (b2Vec2) smoothedPosition {
    return smoothedPosition;
}

// Do not override unless absolutely necessary
- (void) setPreviousPosition:(b2Vec2)p {
    previousPosition = p;
}

// Do not override unless absolutely necessary
- (void) setSmoothedPosition:(b2Vec2)p {
    smoothedPosition = p;
}

// Do not override unless absolutely necessary
- (float) previousAngle {
    return previousAngle;
}

// Do not override unless absolutely necessary
- (float) smoothedAngle {
    return smoothedAngle;
}

// Do not override unless absolutely necessary
- (void) setPreviousAngle:(float)a {
    previousAngle = a;
}

// Do not override unless absolutely necessary
- (void) setSmoothedAngle:(float)a {
    smoothedAngle = a;
}

#pragma mark - CatcherGameObject protocol

// Do not override unless absolutely necessary
- (int) getIndexInLevelObjects {
    return indexInLevelObjects;
}

// Do not override unless absolutely necessary
- (void) setIndexInLevelObjects:(int)index {
    indexInLevelObjects = index;
}

// Do not override unless absolutely necessary
- (void) setLevelObjects:(NSArray*)currentLevelObjects {
    levelObjects = currentLevelObjects;
}

// Do not override unless absolutely necessary
- (CCNode<GameObject, PhysicsObject, CatcherGameObject>*) getNextCatcherGameObject {
    if (indexInLevelObjects + 1 < [levelObjects count]) 
        return [levelObjects objectAtIndex:indexInLevelObjects+1];
    
    // Last object is the final platform
    return [levelObjects lastObject];
}

// Do not override unless absolutely necessary
- (float) distanceToNextCatcher {
    CCNode<GameObject> *nextObject = [self getNextCatcherGameObject];
    float distanceToNextCatcher = nextObject.position.x - self.position.x; 
    return distanceToNextCatcher;
}

// Do not override unless absolutely necessary
- (NSArray*) getLevelObjects {
    return levelObjects;
}


- (void) setCollideWithPlayer:(BOOL)doCollide {
    NSAssert(NO, @"This is an abstract method and should be overridden");
}

- (void) setSwingerVisible:(BOOL)visible {
    NSAssert(NO, @"This is an abstract method and should be overridden");
}

- (CGPoint) getCatchPoint {
    NSAssert(NO, @"This is an abstract method and should be overridden");
    return CGPointZero;
}

- (float) getHeight {
    NSAssert(NO, @"This is an abstract method and should be overridden");
    return 0;
}

#pragma mark - Base methods

-(void) moveTo:(CGPoint)pos {
    self.position = pos;

    body->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0);
}

- (void) showAt:(CGPoint)pos {
    [self moveTo:pos];
    [self show];
}

- (void) reset{
    [self setCollideWithPlayer:YES];
}

@end
