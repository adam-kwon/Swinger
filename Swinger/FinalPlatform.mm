//
//  FinalPlatform.m
//  Swinger
//
//  Created by James Sandoz on 5/2/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "FinalPlatform.h"
#import "Constants.h"
#import "GamePlayLayer.h"

@implementation FinalPlatform

/*- (id) init {
    
    if ((self = [super init])) {
        self.anchorPoint = ccp(0, 0);
        sprite = [CCSprite spriteWithFile:@"finalPlatform.png"];
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite];
    }
    
    return self;
}


- (GameObjectType) gameObjectType {
    return kGameObjectFinalPlatform;
}


- (void) createPhysicsObject:(b2World *)theWorld {
    
    CGPoint p = ccp(0,0);
    
    world = theWorld;
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
    bodyDef.userData = self;
    body = world->CreateBody(&bodyDef);
 
    // make the shape smaller than the sprite so that when the player touches the edge
    // of the physics object they will always be over the sprite
    float xmod = ssipad(49,24.5);
    b2EdgeShape platformShape;
    platformShape.Set(b2Vec2(xmod/PTM_RATIO, [sprite boundingBox].size.height/PTM_RATIO),
                      b2Vec2(([sprite boundingBox].size.width-xmod)/PTM_RATIO, [sprite boundingBox].size.height/PTM_RATIO));
    
//    b2PolygonShape shape;
//    shape.SetAsBox(self.contentSize.width*self.scale/PTM_RATIO/2, self.contentSize.height*self.scale/PTM_RATIO/2, 
//                   b2Vec2(self.contentSize.width*self.scale/PTM_RATIO/2, self.contentSize.height*self.scale/PTM_RATIO/2), 0);
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &platformShape;
    fixtureDef.density = 2.0f;
    fixtureDef.friction = 10.3f;
    
    collideWithPlayer.categoryBits = CATEGORY_FINAL_PLATFORM;
    collideWithPlayer.maskBits = CATEGORY_JUMPER;
    noCollideWithPlayer.categoryBits = 0;
    noCollideWithPlayer.maskBits = 0;
    
    fixtureDef.filter.categoryBits = collideWithPlayer.categoryBits;
    fixtureDef.filter.maskBits = collideWithPlayer.maskBits;
    fixture = body->CreateFixture(&fixtureDef);
}

- (CGRect) boundingBox {
    return [sprite boundingBox];
}

#pragma mark - CatcherGameObject protocol
- (float) getHeight {
    // return height 
    return self.position.y + [self boundingBox].size.height + [[[GamePlayLayer sharedLayer] getPlayer] boundingBox].size.height + 20;
}

- (void) setSwingerVisible:(BOOL)visible {
    // noop
}

- (float) distanceToNextCatcher {
    return 0;
}

- (void) setCollideWithPlayer:(BOOL)doCollide {
    if (doCollide) {
        fixture->SetFilterData(collideWithPlayer);
    } else {
        fixture->SetFilterData(noCollideWithPlayer);        
    }
}

- (CGPoint) getCatchPoint{
    return [self position];
}


- (void) dealloc {
    CCLOG(@"------------------------------ FinalPlatform being deallocated");
    // DO NOT DESTROY PHYSICS OBJECTS HERE!
    // SOMETHING WILL CALL destroyPhysicsObject
    [self removeAllChildrenWithCleanup:YES];
    [super dealloc];
}*/

+ (id) node {
 
    return [super make: ssipadauto(1000)];
}

- (void) initPlatform {
    //
    
    CCSprite * finish = [CCSprite spriteWithFile:@"finish.png"];
    
    finish.position = ccp([finish boundingBox].size.width/2 + ssipadauto(50), ssipadauto(60));
    
    [self addChild: finish z:-1];
}

- (void) moveTo:(CGPoint)pos {
    self.position = pos;
    
    body->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0);
}

- (void) showAt:(CGPoint)pos {
    [self moveTo:pos];
    [self show];
}

- (void) reset {
    [super reset];
}

- (BOOL) isOneSided {
    return YES;
}

#pragma mark - GameObject protocol
- (GameObjectType) gameObjectType {
    return kGameObjectFinalPlatform;
}

@end
