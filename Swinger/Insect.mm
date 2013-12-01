//
//  Insect.m
//  Swinger
//
//  Created by Isonguyo Udoka on 8/16/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "GamePlayLayer.h"
#import "Insect.h"
#import "AchievementManager.h"
#import "MainGameScene.h"
#import "Notifications.h"

const float widthRatio = 1.0;
const float heightRatio = 1.0;

@implementation Insect

@synthesize flyDistance;
@synthesize flySpeed;

const float initialGravityScale = 0.01;

+ (id) make: (float) theflyDistance speed: (float) theSpeed {
    return [[[self alloc] initInsect: theflyDistance speed: theSpeed] autorelease];
}

- (id) initInsect: (float) theflyDistance speed: (float) theSpeed  {
	if ((self = [super init])) {
        screenSize = [CCDirector sharedDirector].winSize;
        flyDistance = theflyDistance;
        flySpeed = theSpeed;
        startedFlying = NO;
        state = kEnemyStateAlive;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerFell)
                                                     name:NOTIFICATION_PLAYER_FELL
                                                   object:nil];
    }
    
    return self;
}

- (void) playerFell {
    [self stopSound];
}

#pragma mark - GameObject protocol

- (GameObjectType) gameObjectType {   
    return kGameObjectInsect;
}
- (void) attack: (Player *) player at: (CGPoint) location {
    // decide whether i bumped off the player or player killed me
    
    if (state == kEnemyStateAlive) {
        
        b2Body * pBody = [player getPhysicsBody];
        float pHeight = ((pBody->GetPosition().y*PTM_RATIO) -  (player.bodyWidth/4*PTM_RATIO)) + ssipadauto(2);
        float myHeight = (body->GetPosition().y*PTM_RATIO) + heightRatio*([insectSprite boundingBox].size.height/2);
        float myBottom = (body->GetPosition().y*PTM_RATIO) - 0.85*([insectSprite boundingBox].size.height/2);
        float playerTop = ((pBody->GetPosition().y*PTM_RATIO) + ((player.bodyHeight/2*PTM_RATIO)));
        BOOL die = NO;
        //BOOL shake = NO;
        b2Vec2 fallVec = b2Vec2(0,-5*body->GetMass());
        b2Vec2 pBounce = b2Vec2(0,0);
        BOOL canKill = [self canKill: player];
        int extraJump = 0;
        float killFactor = player.scaleFactor;
        
        if (player.speedFactor > killFactor) {
            killFactor = player.speedFactor;
        }
        
        //if (canKill)  {
        if (pHeight >= myHeight /*&& (player.state == kSwingerJumping || player.state == kSwingerInAir)*/) {
            // player jumped on my head, I die
            die = YES;
            pBounce = b2Vec2(10*pBody->GetMass(),g_gameRules.floatForce*pBody->GetMass());
            extraJump = 1;
        } else if (pBody->GetLinearVelocity().y > 0 && (player.state == kSwingerJumping)) {
            // player hit me on the side while jumping, that equals a charge, I die
            die = YES;
            fallVec = b2Vec2(4*body->GetMass()*killFactor,3*body->GetMass()*killFactor);
            pBounce = b2Vec2(10*pBody->GetMass(), 15*pBody->GetMass());
        } else if (player.state == kSwingerInAir) {
            die = YES;
            fallVec = b2Vec2(5*body->GetMass()*killFactor,2*body->GetMass()*killFactor);
            pBounce = b2Vec2(7.5*pBody->GetMass(),15*pBody->GetMass());
        } else if (playerTop <= myBottom && (player.state == kSwingerJumping)) {
            // I got knocked out from under me
            die = YES;
            fallVec = b2Vec2(2.5*body->GetMass()*killFactor,2*body->GetMass()*killFactor);
            pBounce = b2Vec2(10*body->GetLinearVelocity().x, 15*pBody->GetMass());
            extraJump = 1;
            //killMomentum = NO;
        } else if (!canKill) {
            die = YES;
            fallVec = b2Vec2(3.0*body->GetMass()*killFactor,3*body->GetMass()*killFactor);
            pBounce = b2Vec2(1*pBody->GetMass(),0*pBody->GetMass());
            extraJump = 1;
        }
        
        killedByPlayer = die;
        
        if (die) {
            CCLOG(@"INSECT DIES!");
            player.fallThrough = NO;
            [self setCollideWithPlayer: NO];
            [self die];
            
            if (canKill && pBounce.y > 0) {
                [player bouncingUpAnimation];
            }
            
            [[MainGameScene sharedScene] shake: ssipadauto(4) duration: 0.25];
            
            [player enemyKilled:self];
            //body->SetLinearVelocity(fallVec);
            body->SetGravityScale(1);
            body->SetLinearVelocity(b2Vec2(0,0));
            body->ApplyLinearImpulse(b2Vec2(fallVec.x*body->GetMass(), fallVec.y*body->GetMass()), body->GetPosition());
            
            if (canKill && (pBounce.x != 0 || pBounce.y != 0)) {
                pBody->SetLinearVelocity(b2Vec2(0,0));
                pBody->ApplyLinearImpulse(pBounce, pBody->GetPosition());
                player.state = kSwingerJumping;
            }
            
            [[AchievementManager sharedInstance] killedInsect];
        } else {
            CCLOG(@"PLAYER DIES!");
            // Player gets bumped off
            [[AudioEngine sharedEngine] playEffect:SND_LAND gain:32];
            [[MainGameScene sharedScene] shake: ssipadauto(2) duration: 0.25];
            [player fallingAnimation];
            
            [[AchievementManager sharedInstance] killedByInsect];
        }
    }
}

- (void) fall {
    state = kEnemyStateNone;
    [self stopSound];
    [[AudioEngine sharedEngine] playEffect:SND_INSECT_DIES gain:4];
    [self setCollideWithPlayer: NO];
    //body->SetGravityScale(1);
    //body->SetLinearVelocity(b2Vec2(0,-10));
    //body->ApplyLinearImpulse(b2Vec2(0,-20), body->GetPosition());
    
    if (!killedByPlayer) {
        body->SetGravityScale(1);
        body->SetLinearVelocity(b2Vec2(0,0));//2,-20));
        smoke.visible = YES;
        [smoke resetSystem];
    }
    
    //[self hide];
}

- (BOOL) willKill:(Player *)player {
    
    if (state != kEnemyStateAlive) {
        return NO;
    }
    
    b2Body * pBody = [player getPhysicsBody];
    float pHeight = ((pBody->GetPosition().y*PTM_RATIO) -  (player.bodyWidth/2*PTM_RATIO)) + ssipadauto(2);
    float myHeight = (body->GetPosition().y*PTM_RATIO) + [insectSprite boundingBox].size.height/2; // small buffer to make it a little easier
    float myBottom = (body->GetPosition().y*PTM_RATIO) - heightRatio*([insectSprite boundingBox].size.height/2);
    BOOL die = NO;
    
    if (pHeight >= myHeight && (player.state == kSwingerJumping)) {
        // player jumped on my head, I die
        die = YES;
    } else if (pBody->GetLinearVelocity().y > 0 && (player.state == kSwingerJumping)) {
        die = YES;
    } else if (player.state == kSwingerInAir) {
        die = YES;
    } else if ((pHeight + [player boundingBox].size.height) <= myBottom && (player.state == kSwingerJumping)) {
        // I got knocked out from under me
        die = YES;
    }
    
    return !die;
}

- (BOOL) isVisible {
    return insectSprite.visible;
}

- (void) updateObject:(ccTime)dt scale:(float)scale {
    
    if (state == kEnemyStateDead) {
        [self fall];
        return;
    }
    
    // Hide if off screen and show if on screen. We should let each object control itself instead
    // of managing everything from GamePlayLayer. Convert to world coordinate first, and then compare.
    CGPoint gamePlayPosition = [[GamePlayLayer sharedLayer] getNode].position;
    
    CGPoint worldPos = ccp(normalizeToScreenCoord(gamePlayPosition.x, (body->GetPosition().x * PTM_RATIO) - [insectSprite boundingBox].size.width/2, scale), 
                           gamePlayPosition.y + (body->GetPosition().y * PTM_RATIO));
    if (insectSprite.visible && (worldPos.x < -([insectSprite boundingBox].size.width) || worldPos.x > screenSize.width)) {
        [self hide];
    } else if (!insectSprite.visible && worldPos.x >= -([insectSprite boundingBox].size.width) && worldPos.x <= screenSize.width) {
        [self show];
    }
    
    if (!insectSprite.visible) {
        return;
    }
    
    CGPoint pos = ccp(body->GetPosition().x*PTM_RATIO, body->GetPosition().y*PTM_RATIO);
    insectSprite.position = pos;
    
    if (smoke.visible) {
        smoke.position = pos;
    }
    
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
    
    if (flyDistance != 0 && flySpeed > 0) {
        if (!startedFlying) {
            int sign = flyDistance < 0 ? -1 : 1;
            float speed = flySpeed * sign;
            
            body->SetLinearVelocity(b2Vec2(0, speed));
            startedFlying = YES;
            currStartPosY = startPosition.y;
        }
        else if (state != kEnemyStateDead) {
            
            float distanceTravelled = currStartPosY - (body->GetPosition().y*PTM_RATIO);
            
            if (fabsf(distanceTravelled) > fabsf(flyDistance)) {
                // fly other direction
                currStartPosY = body->GetPosition().y*PTM_RATIO;
                int sign = body->GetLinearVelocity().y < 0 ? 1 : -1;
                float speed = flySpeed * sign;
                
                body->SetLinearVelocity(b2Vec2(0, speed));
            }
        } else if (state == kEnemyStateDead) {
            //body->SetLinearVelocity(b2Vec2(0, -fabsf(flySpeed)));
        }
    }
}

- (void) show {
    
    insectSprite.visible = YES;
    body->SetActive(YES);
    [self startSound];
}

- (void) hide {
    insectSprite.visible = NO;
    if (state != kEnemyStateDead) {
        body->SetActive(NO);
    }
    
    if (smoke.visible) {
        smoke.visible = NO;
        [smoke stopSystem];
    }
    
    [self stopSound];
}

- (void) startSound {
    
    if (sound == 0 && state != kEnemyStateNone && state != kEnemyStateDead) {
        sound = [[AudioEngine sharedEngine] playEffect:SND_INSECT loop:YES];
    } else if (state == kEnemyStateNone || state == kEnemyStateDead) {
        [self stopSound];
    }
}

- (void) stopSound {
    
    if (sound > 0) {
        [[AudioEngine sharedEngine] stopEffect:sound];
        sound = 0;
    }
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
    return ccp((body->GetPosition().x * PTM_RATIO) - [insectSprite boundingBox].size.width/2, body->GetPosition().y * PTM_RATIO);
}

- (void) createPhysicsObject:(b2World *)theWorld {
    world = theWorld;
    
    //===============================
    // Create the Insect
    //===============================
    insectSprite = [CCSprite spriteWithFile:@"insect.png"];
    insectSprite.position = self.position;
    insectSprite.flipX = YES;
    //insectSprite.scale = 0.75f;
    [[GamePlayLayer sharedLayer] addChild:insectSprite z: 0];
    
    b2BodyDef insectBodyDef;
    insectBodyDef.type = b2_dynamicBody;
    insectBodyDef.userData = self;
    insectBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    body = world->CreateBody(&insectBodyDef);
    body->SetGravityScale(initialGravityScale);
    
    // Create the Boulder's fixture
    //b2CircleShape shape;
    //shape.SetAsBox([insectSprite boundingBox].size.width/PTM_RATIO/2, [insectSprite boundingBox].size.height/PTM_RATIO/2);
    //shape.m_radius = heightRatio*([insectSprite boundingBox].size.width/PTM_RATIO/2);
    b2PolygonShape shape;
    shape.SetAsBox(widthRatio*([insectSprite boundingBox].size.width/PTM_RATIO/2), heightRatio*([insectSprite boundingBox].size.height/PTM_RATIO/2));
    b2FixtureDef insectFixtureDef;
    insectFixtureDef.shape = &shape;
    insectFixtureDef.friction = 0.0f;
#ifdef USE_CONSISTENT_PTM_RATIO
    insectFixtureDef.density =  1.0f;
#else
    insectFixtureDef.density =  1.0f/ssipad(4.0, 1);
#endif
    
    collideWithPlayer.categoryBits = CATEGORY_ENEMY;
    collideWithPlayer.maskBits = CATEGORY_JUMPER | CATEGORY_MISSILE | CATEGORY_GROUND;
    noCollideWithPlayer.categoryBits = 0;
    noCollideWithPlayer.maskBits = 0;
    
    insectFixtureDef.filter.categoryBits = collideWithPlayer.categoryBits;
    insectFixtureDef.filter.maskBits = collideWithPlayer.maskBits;
    insectFixture = body->CreateFixture(&insectFixtureDef);
    
    // Particle Effects
    smoke = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:(@"smoke.plist")];
    smoke.anchorPoint = ccp(0.5,0);
    smoke.position = self.position;
    smoke.positionType = kCCPositionTypeGrouped;
    [[GamePlayLayer sharedLayer] addChild:smoke z:-1];
    [smoke stopSystem];
    smoke.visible = NO;
}

- (void) setCollideWithPlayer:(BOOL)doCollide {
    
    if (state == kEnemyStateAlive) {
        if (doCollide) {
            insectFixture->SetFilterData(collideWithPlayer);
        } else {
            insectFixture->SetFilterData(noCollideWithPlayer);        
        }
    }
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
    startPosition = pos;
    
    [self moveTo:pos];
    //[self show];
}

- (void) reset {
    state = kEnemyStateAlive;
    [self stopSound];
    [self setCollideWithPlayer: YES];
    body->SetLinearVelocity(b2Vec2(0,0));
    body->SetGravityScale(initialGravityScale);
    [self moveTo: startPosition];
    startedFlying = NO;
    killedByPlayer = NO;
}

- (void) dealloc {
    // DO NOT DESTROY PHYSICS OBJECTS HERE!
    // SOMETHING WILL CALL destroyPhysicsObject
    
    CCLOG(@"------------------------------ Insect being deallocated");
    [self stopSound];
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PLAYER_FELL object:nil];
    
    [super dealloc];
}

@end
