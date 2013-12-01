//
//  Barrel.m - Gotcha when kills monkey, doh when monkey kills him
//  Swinger
//
//  Created by Isonguyo Udoka on 8/7/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Barrel.h"
#import "Constants.h"
#import "GamePlayLayer.h"
#import "MainGameScene.h"

@implementation Barrel

+ (id) make {
    return [[[self alloc] initBarrel] autorelease];
}

- (id) initBarrel  {
	if ((self = [super init])) {
        screenSize = [CCDirector sharedDirector].winSize;
        state = kEnemyStateAlive;
        barrelState = kBarrelStateNone;
    }
    
    return self;
}

#pragma mark - GameObject protocol

- (GameObjectType) gameObjectType {
    return kGameObjectOilBarrel;
}

- (void) attack: (Player *) player at: (CGPoint) location {
    // decide whether i bumped off the player or player killed me
    
    if (state == kEnemyStateAlive) {
        BOOL canKill = [self canKill: player];
        
        if (!canKill) {
            // blow up
            [self die];
            [player enemyKilled:self];
        } else {
            [self setCollideWithPlayer: NO];
            [[AudioEngine sharedEngine] playEffect:SND_LAND gain:32];
            [[MainGameScene sharedScene] shake: ssipadauto(3) duration: 0.25];
            //[[AchievementManager sharedInstance] killedByOilDrum];
            [player fallingAnimation];
            CCLOG(@"PLAYER KILLED BY OIL DRUM");
        }
        
        barrelState = kBarrelStateExploded;
        [[AudioEngine sharedEngine] playEffect:SND_EXPLOSION];
    }
}

- (void) fall {
    //state = kEnemyStateDead;
    [self setCollideWithPlayer: NO];
    [self blowUp]; // blow up animation needed
    //body->SetLinearVelocity(b2Vec2(0,-20));
    state = kEnemyStateNone;
}

- (void) blowUp {
    
    barrelSprite.visible = NO;
}

- (BOOL) willKill:(Player *)player {
    // always kills player unless player has an appropriate power up
    bool ret = (state == kEnemyStateAlive);
    
    if (ret) {
        //[[AchievementManager sharedInstance] killedByOilDrum];
    }
    
    return ret;
}

- (BOOL) isVisible {
    return barrelSprite.visible;
}

- (void) skid {
    
    if ([self canKill:[[GamePlayLayer sharedLayer] getPlayer]]) {
        doSkid = YES;
    }
}

- (void) updateObject:(ccTime)dt scale:(float)scale {
    
    if (state == kEnemyStateDead) {
        [self fall];
        return;
    } else if (barrelState == kBarrelStateExploded) {
        [self hide];
        return;
    }
    
    // Hide if off screen and show if on screen. We should let each object control itself instead
    // of managing everything from GamePlayLayer. Convert to world coordinate first, and then compare.
    CGPoint gamePlayPosition = [[GamePlayLayer sharedLayer] getNode].position;
    
    CGPoint worldPos = ccp(normalizeToScreenCoord(gamePlayPosition.x, (body->GetPosition().x * PTM_RATIO) - [barrelSprite boundingBox].size.width/2, scale),
                           gamePlayPosition.y + (body->GetPosition().y * PTM_RATIO));
    if (barrelSprite.visible && (worldPos.x < -([barrelSprite boundingBox].size.width) || worldPos.x > screenSize.width)) {
        [self hide];
    } else if (!barrelSprite.visible && worldPos.x >= -([barrelSprite boundingBox].size.width) && worldPos.x <= screenSize.width) {
        [self show];
    }
    
    if (!barrelSprite.visible) {
        return;
    }
    
    CGPoint pos = ccp(body->GetPosition().x*PTM_RATIO, body->GetPosition().y*PTM_RATIO);
    barrelSprite.position = pos;
    
    if (body->GetAngle() != 0) {
        body->SetTransform(body->GetPosition(), 0);
    }
    
    /*if (state == kEnemyStateDead) {
     [self fall];
     return;
     }*/
    
    if (state == kEnemyStateNone) {
        return;
    }
    
    [self checkPowerups];
    
    if (doSkid) {
        //
        Player * player = [[GamePlayLayer sharedLayer] getPlayer];
        [player skiddingAnimation];
        b2Body * pBody = [player getPhysicsBody];
        pBody->ApplyLinearImpulse(b2Vec2(g_gameRules.runSpeed*3,0), body->GetPosition());
        doSkid = NO;
    }
}

- (void) show {
    
    if (state == kEnemyStateAlive) {
        barrelSprite.visible = YES;
        body->SetActive(YES);
    } else {
        [self hide];
    }
}

- (void) hide {
    barrelSprite.visible = NO;
    //if (state != kEnemyStateDead) {
    body->SetActive(NO);
    //}
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

- (CGPoint) getLeftEdge {
    return ccp((body->GetPosition().x * PTM_RATIO) - [barrelSprite boundingBox].size.width/2, body->GetPosition().y * PTM_RATIO);
}

- (void) createPhysicsObject:(b2World *)theWorld {
    world = theWorld;
    
    //===============================
    // Create the Oil Drum
    //===============================
    barrelSprite = [CCSprite spriteWithFile:@"barrel.png"];
    barrelSprite.position = self.position;
    //barrelSprite.scale = 0.75f;
    [[GamePlayLayer sharedLayer] addChild:barrelSprite z: 0];
    
    b2BodyDef barrelBodyDef;
    barrelBodyDef.type = b2_staticBody;
    barrelBodyDef.userData = self;
    barrelBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    body = world->CreateBody(&barrelBodyDef);
    
    // Create the barrel's fixture
    b2PolygonShape shape;
    shape.SetAsBox(0.60*([barrelSprite boundingBox].size.width/PTM_RATIO/2), 0.85*([barrelSprite boundingBox].size.height/PTM_RATIO/2));
    b2FixtureDef barrelFixtureDef;
    barrelFixtureDef.shape = &shape;
    barrelFixtureDef.friction = 3.0f;
#ifdef USE_CONSISTENT_PTM_RATIO
    barrelFixtureDef.density =  1.0f;
#else
    barrelFixtureDef.density =  1.0f/ssipad(4.0, 1);
#endif
    
    collideWithPlayer.categoryBits = CATEGORY_ENEMY;
    collideWithPlayer.maskBits = CATEGORY_JUMPER | CATEGORY_MISSILE | CATEGORY_FLOATING_PLATFORM | CATEGORY_ENEMY | CATEGORY_GROUND;
    
    noCollideWithPlayer.categoryBits = CATEGORY_ENEMY;
    noCollideWithPlayer.maskBits = CATEGORY_ENEMY | CATEGORY_GROUND;
    
    onlyCollideWithPlatform.categoryBits = CATEGORY_ENEMY;
    onlyCollideWithPlatform.maskBits = CATEGORY_FLOATING_PLATFORM | CATEGORY_ENEMY | CATEGORY_GROUND;
    
    collideWithNothing.categoryBits = 0;
    collideWithNothing.maskBits =  CATEGORY_GROUND;
    
    barrelFixtureDef.filter.categoryBits = collideWithPlayer.categoryBits;
    barrelFixtureDef.filter.maskBits = collideWithPlayer.maskBits;
    barrelFixture = body->CreateFixture(&barrelFixtureDef);
    
    float spillLength = 4;
    
    shape.SetAsBox(spillLength, 0.1, b2Vec2(-spillLength,-0.85*([barrelSprite boundingBox].size.height/PTM_RATIO/2)), 0);
    b2FixtureDef spillFixtureDef;
    spillFixtureDef.shape = &shape;
    spillFixtureDef.friction = 1.0;
#ifdef USE_CONSISTENT_PTM_RATIO
    spillFixtureDef.density = 1.0;
#else
    spillFixtureDef.density = 1.0/ssipad(4.0, 1);
#endif
    
    spillFixtureDef.filter.categoryBits = collideWithPlayer.categoryBits;
    spillFixtureDef.filter.maskBits = collideWithPlayer.maskBits;
    spillFixtureDef.isSensor = YES;
    spillFixture = body->CreateFixture(&spillFixtureDef);
}

- (void) onlyCollideWithPlatform {
    // allow the player to fall through without further contacts that require presolves
    barrelFixture->SetFilterData(onlyCollideWithPlatform);
    spillFixture->SetFilterData(onlyCollideWithPlatform);
}

- (void) setCollideWithPlayer:(BOOL)doCollide {
    
    if (state == kEnemyStateAlive) {
        if (doCollide) {
            barrelFixture->SetFilterData(collideWithPlayer);
            spillFixture->SetFilterData(collideWithPlayer);
        } else {
            barrelFixture->SetFilterData(noCollideWithPlayer);
            spillFixture->SetFilterData(noCollideWithPlayer);
        }
    }
}

- (void) collideWithNothing {
    barrelFixture->SetFilterData(collideWithNothing);
    spillFixture->SetFilterData(collideWithNothing);
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

#pragma mark - Base methods

-(void) moveTo:(CGPoint)pos {
    self.position = pos;
    
    body->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0);
}

- (void) showAt:(CGPoint)pos {
    //
    [self moveTo:pos];
    [self show];
}

- (void) reset {
    state = kEnemyStateAlive;
    barrelState = kBarrelStateNone;
    doSkid = NO;
    body->SetActive(YES);
    [self setCollideWithPlayer: YES];
    [self show];
}

- (void) dealloc {
    // DO NOT DESTROY PHYSICS OBJECTS HERE!
    // SOMETHING WILL CALL destroyPhysicsObject
    
    CCLOG(@"------------------------------ Oil Barrel being deallocated");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [super dealloc];
}

@end
