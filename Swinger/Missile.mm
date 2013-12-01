//
//  Missile.m
//  Swinger
//
//  Created by Isonguyo Udoka on 8/30/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Missile.h"
#import "GamePlayLayer.h"
#import "Notifications.h"
#import "AudioEngine.h"

@implementation Missile

@synthesize gameObjectId;

- (id) initWithType: (ProjectileType) projType target: (Enemy *) theTarget pos: (CGPoint) startPos {
    self = [super init];
    if (self) {
        projectileType = projType;
        target = theTarget;
        startPosition = startPos;
        startedMoving = NO;
        speed = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(targetDestroyed) 
                                                     name:NOTIFICATION_PLAYER_FELL 
                                                   object:nil];
        
        [[AudioEngine sharedEngine] playEffect:SND_MISSILE gain:0.5];
    }
    return self;
}

+ (id) make: (Enemy *) theTarget {
    Player *player = [[GamePlayLayer sharedLayer] getPlayer];
    float offset = 4;
    CGPoint pos = ccp([player getPhysicsBody]->GetPosition().x * PTM_RATIO, ([player getPhysicsBody]->GetPosition().y * PTM_RATIO) + ssipadauto(offset));
    
    return [self make: kProjectileMissile target: theTarget pos: pos];
}

+ (id) make: (Enemy *) theTarget pos: (CGPoint) startPos {
    return [self make: kProjectileMissile target: theTarget pos: startPos];
}

+ (id) make: (ProjectileType) projectileType target: (Enemy *) theTarget pos: (CGPoint) startPos {
    return [[[self alloc] initWithType: projectileType target: theTarget pos: startPos] autorelease];
}

- (void) targetDestroyed {
    //CCLOG(@"TARGET %d has been destroyed", target.gameObjectId);
    [self hide];
    [self safeToDelete];
    [[GamePlayLayer sharedLayer] addToDeleteList: self];
}

- (BOOL) destroyTarget: (Enemy *) theTarget {
    
    if (target == theTarget) {
        // only destroy YOUR target!
        [target die];
        [self targetDestroyed];
        return YES;
    }
    
    return NO;
}

#pragma mark - PhysicsObject protocol
- (void) createPhysicsObject:(b2World *)theWorld {
    world = theWorld;
    
    if (projectileType == kProjectileMissile) {
        sprite = [CCSprite spriteWithFile:@"missile.png"];
    } else {
        sprite = [CCSprite spriteWithFile:@"grenade.png"];
        sprite.scale = 0.5f;
    }
    
    //Player *player = [[GamePlayLayer sharedLayer] getPlayer];
    //float offset = 4;
    CGPoint pos = startPosition; //ccp([player getPhysicsBody]->GetPosition().x * PTM_RATIO, ([player getPhysicsBody]->GetPosition().y * PTM_RATIO) + ssipadauto(offset));
    sprite.position = pos;
    [self addChild: sprite];
    [[GamePlayLayer sharedLayer] addChild: self];
    [self hide];
    
    b2BodyDef missileBodyDef;
    missileBodyDef.type = b2_dynamicBody;
    missileBodyDef.userData = self;
    missileBodyDef.position.Set(pos.x/PTM_RATIO, pos.y/PTM_RATIO);
    body = world->CreateBody(&missileBodyDef);
    body->SetGravityScale(0.1);
    
    // Create the missile's fixture
    b2PolygonShape shape;
    shape.SetAsBox(([sprite boundingBox].size.width/PTM_RATIO/2), ([sprite boundingBox].size.height/PTM_RATIO/2));
    b2FixtureDef missileFixtureDef;
    missileFixtureDef.shape = &shape;
    missileFixtureDef.friction = 0.0f;
#ifdef USE_CONSISTENT_PTM_RATIO
    missileFixtureDef.density =  1.0f;
#else
    missileFixtureDef.density =  1.0f/ssipad(4.0, 1);
#endif
    
    missileFixtureDef.filter.categoryBits = CATEGORY_MISSILE;
    missileFixtureDef.filter.maskBits = CATEGORY_ENEMY;
    missileFixture = body->CreateFixture(&missileFixtureDef);
}

- (void) destroyPhysicsObject {
    if (world != NULL) {
        world->DestroyBody(body);
    }
    body = NULL;
}

- (b2Body*) getPhysicsBody {
    return body;
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

- (void) trackTarget {
    
    if (target.state == kEnemyStateDead ||
        target.state == kEnemyStateNone) {
        [self targetDestroyed];
        return;
    }
    
    CGPoint pos = ccp(body->GetPosition().x * PTM_RATIO, body->GetPosition().y * PTM_RATIO);
    
    if (projectileType == kProjectileGrenade) {
        pos = ccp(pos.x, pos.y + ssipadauto(0));
    }
    
    CGPoint targetPos = ccp([target getPhysicsBody]->GetPosition().x * PTM_RATIO, [target getPhysicsBody]->GetPosition().y * PTM_RATIO);
    
    float xDiff = powf(fabs(pos.x - targetPos.x), 2);
    float yDiff = powf(fabs(pos.y - targetPos.y), 2);
    float distance = sqrtf(xDiff+yDiff);
    
    float angleRad = acosf((targetPos.x - pos.x)/(distance));
    float angle = CC_RADIANS_TO_DEGREES(angleRad);
    
    if (targetPos.y > pos.y) {
        angle *= -1;
    }
    
    sprite.position = pos;
    sprite.rotation = angle;
    body->SetTransform(b2Vec2(body->GetPosition().x, body->GetPosition().y), CC_DEGREES_TO_RADIANS(-angle));
    b2Vec2 flightVec = b2Vec2((targetPos.x - pos.x)/PTM_RATIO*2, (targetPos.y - pos.y)/PTM_RATIO*2);
    
    if (fabsf(flightVec.x) >= speed) {
        speed = flightVec.x;
        
        if (fabsf(speed) < 10) {
            speed *= 2;//ceil(10/speed);
        }
    } else {
        int factor = ceil(speed/flightVec.x);
        
        flightVec.x *= factor;
        flightVec.y *= factor;
    }
    
    body->SetLinearVelocity(flightVec);
}


#pragma mark - GameObject protocol
- (void) updateObject:(ccTime)dt scale:(float)scale {
    
    if (!startedMoving) {
        
        // Set missile starting point
        Player *player = [[GamePlayLayer sharedLayer] getPlayer];
        float offset = 0;//4;
        CGPoint pos = ccp([player getPhysicsBody]->GetPosition().x * PTM_RATIO, ([player getPhysicsBody]->GetPosition().y * PTM_RATIO) + ssipadauto(offset));
        body->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0);
        sprite.position = pos;
        
        // send missile towards target
        [self trackTarget];
        
        [self show];
        startedMoving = YES;
    } else {
        
        if (sprite.visible) {
            [self trackTarget];
        }
    }
}

- (GameObjectType) gameObjectType {
    return kGameObjectMissile;
}

- (BOOL) isSafeToDelete {
    return isSafeToDelete;
}

- (void) safeToDelete {
    isSafeToDelete = YES;
}

- (void) show {
    sprite.visible = YES;
}

- (void) hide {
    sprite.visible = NO;
}

- (void) reset {
    // get rid of missile
    [self targetDestroyed];
}

- (void) dealloc {
    CCLOG(@"------------------------------ Missile being dealloced----------------------------");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PLAYER_FELL object:nil];
    
    [super dealloc];
}

@end
