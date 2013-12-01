//
//  Hunter.m - Gotcha when kills monkey, doh when monkey kills him
//  Swinger
//
//  Created by Isonguyo Udoka on 8/7/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Hunter.h"
#import "Constants.h"
#import "GamePlayLayer.h"
#import "MainGameScene.h"
#import "AudioEngine.h"

const float widthRatio = 1.0;
const float heightRatio = 1.0;

@implementation Hunter

@synthesize walkDistance;
@synthesize walkSpeed;

+ (id) make: (float) theWalkDistance speed: (float) theSpeed {
    return [[[self alloc] initHunter: theWalkDistance speed: theSpeed] autorelease];
}

- (id) initHunter: (float) theWalkDistance speed: (float) theSpeed  {
	if ((self = [super init])) {
        screenSize = [CCDirector sharedDirector].winSize;
        walkDistance = theWalkDistance;
        walkSpeed = theSpeed;
        startedWalking = NO;
        state = kEnemyStateAlive;
    }
    
    return self;
}

#pragma mark - GameObject protocol

- (GameObjectType) gameObjectType {   
    return kGameObjectHunter;
}

- (void) attack: (Player *) player at: (CGPoint) location {
    // decide whether i bumped off the player or player killed me
    
    if (state == kEnemyStateAlive) {
        
        b2Body * pBody = [player getPhysicsBody];
        float pHeight = ((pBody->GetPosition().y*PTM_RATIO) -  (player.bodyWidth/2*PTM_RATIO)) + ssipadauto(2);
        float myHeight = (body->GetPosition().y*PTM_RATIO) + heightRatio*([hunterSprite boundingBox].size.height/2); // small buffer to make it a little easier
        float myBottom = (body->GetPosition().y*PTM_RATIO) - heightRatio*([hunterSprite boundingBox].size.height/2);
        float playerTop = ((pBody->GetPosition().y*PTM_RATIO) + ((player.bodyHeight/2*PTM_RATIO)));
        BOOL die = NO;
        //BOOL shake = NO;
        BOOL killMomentum = YES;
        b2Vec2 pBounce = b2Vec2(0,0);
        BOOL canKill = [self canKill: player];
        int extraJump = 0;
        float killFactor = player.scaleFactor;
        
        if (player.speedFactor > killFactor) {
            killFactor = player.speedFactor;
        }
        
        b2Vec2 fallVec = b2Vec2(0,0*body->GetMass()*killFactor);
        
        if (pHeight >= myHeight /*&& (player.state == kSwingerJumping || player.state == kSwingerInAir)*/) {
            // player jumped on my head, I die
            die = YES;
            pBounce = b2Vec2(10*pBody->GetMass(),g_gameRules.floatForce*pBody->GetMass());
            extraJump = 1;
        } else if (pBody->GetLinearVelocity().y > 0  && (player.state == kSwingerJumping)) {
            // player hit me on the side while jumping, that equals a charge, I die
            die = YES;
            fallVec = b2Vec2(20*body->GetMass()*killFactor,-20*body->GetMass()*killFactor);
            pBounce = b2Vec2(10*pBody->GetMass(), 15*pBody->GetMass());
            //shake = YES;
            extraJump = 1;
        } else if (player.state == kSwingerInAir) {
            die = YES;
            fallVec = b2Vec2(20*body->GetMass()*killFactor,-20*body->GetMass()*killFactor);
            pBounce = b2Vec2(10*pBody->GetMass(),15*pBody->GetMass());
        } else if (playerTop <= myBottom && (player.state == kSwingerJumping)) {
            // I got knocked out from under me
            die = YES;
            fallVec = b2Vec2(2*body->GetMass()*killFactor,10*body->GetMass()*killFactor);
            pBounce = b2Vec2(10*body->GetLinearVelocity().x,15*pBody->GetMass());
            extraJump = 1;
            killMomentum = NO;
        } else if (!canKill) {
            die = YES;
            fallVec = b2Vec2(10*body->GetMass()*killFactor,5*body->GetMass()*killFactor);
            pBounce = b2Vec2(1*pBody->GetMass(),0*pBody->GetMass());
            extraJump = 1;
        }
        
        if (die) {
            CCLOG(@"HUNTER DIES!");
            player.fallThrough = NO;
            [self setCollideWithPlayer: NO];
            [self die];
            
            if (pBounce.y > 0) {
                [player bouncingUpAnimation];
            }
            
            [[MainGameScene sharedScene] shake: ssipadauto(4) duration: 0.25];
            
            [player enemyKilled:self];
            //body->SetLinearVelocity(b2Vec2(0,0));
            //body->ApplyLinearImpulse(fallVec, body->GetPosition());
            
            if (canKill && (pBounce.x != 0 || pBounce.y != 0)) {
                //
                if (killMomentum) {
                    pBody->SetLinearVelocity(b2Vec2(0,0));
                }
                
                pBody->ApplyLinearImpulse(pBounce, pBody->GetPosition());
                player.state = kSwingerJumping;
            } else if (!canKill) {
                pBounce = b2Vec2(1*pBody->GetMass(),0*pBody->GetMass());
                pBody->ApplyLinearImpulse(pBounce, pBody->GetPosition());
            }
        } else {
            CCLOG(@"PLAYER DIES!");
            // Player gets bumped off
            [[AudioEngine sharedEngine] playEffect:SND_LAND gain:32];
            [[MainGameScene sharedScene] shake: ssipadauto(2) duration: 0.25];
            //[self onlyCollideWithPlatform];
            [player fallingAnimation];
        }
    }
}

- (void) fall {
    //[super die];
    //[self collideWithNothing];
    //body->ApplyLinearImpulse(b2Vec2(5*body->GetMass(),-5*body->GetMass()), body->GetPosition());
    
    // play some kind of 'doh' audio
    NSString * fx = SND_HURT_2;
    
    int chance = arc4random() % 100;
    
    if (chance < 33) {
        fx = SND_HURT_1;
    } else if (chance < 66) {
        fx = SND_HURT_3;
    }
    
    [[AudioEngine sharedEngine] playEffect:fx gain:32];
    
    [self setCollideWithPlayer: NO];
    [self hide];
    state = kEnemyStateNone;
}

- (BOOL) willKill:(Player *)player {
    
    if (state != kEnemyStateAlive) {
        return NO;
    }
    
    b2Body * pBody = [player getPhysicsBody];
    float pHeight = (pBody->GetPosition().y*PTM_RATIO) - [player boundingBox].size.height/2;
    float myHeight = (body->GetPosition().y*PTM_RATIO) + [hunterSprite boundingBox].size.height/2 - (ssipadauto(4)); // small buffer to make it a little easier
    float myBottom = (body->GetPosition().y*PTM_RATIO) - heightRatio*([hunterSprite boundingBox].size.height/2);
    BOOL die = NO;
    
    if (pHeight >= myHeight && (player.state == kSwingerJumping)) {
        // player jumped on my head, I die
        die = YES;
    } else if (pBody->GetLinearVelocity().y > 0  && (player.state == kSwingerJumping)) {
        // player hit me on the side while jumping, that equals a charge, I die
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
    return hunterSprite.visible;
}

- (void) updateObject:(ccTime)dt scale:(float)scale {
    
    if (state == kEnemyStateDead) {
        [self fall];
        return;
    }
    
    // Hide if off screen and show if on screen. We should let each object control itself instead
    // of managing everything from GamePlayLayer. Convert to world coordinate first, and then compare.
    CGPoint gamePlayPosition = [[GamePlayLayer sharedLayer] getNode].position;
    
    CGPoint worldPos = ccp(normalizeToScreenCoord(gamePlayPosition.x, (body->GetPosition().x * PTM_RATIO) - [hunterSprite boundingBox].size.width/2, scale), 
                           gamePlayPosition.y + (body->GetPosition().y * PTM_RATIO));
    if (hunterSprite.visible && (worldPos.x < -([hunterSprite boundingBox].size.width) || worldPos.x > screenSize.width)) {
        [self hide];
    } else if (!hunterSprite.visible && worldPos.x >= -([hunterSprite boundingBox].size.width) && worldPos.x <= screenSize.width) {
        [self show];
    }
    
    if (!hunterSprite.visible) {
        return;
    }
    
    CGPoint pos = ccp(body->GetPosition().x*PTM_RATIO, body->GetPosition().y*PTM_RATIO);
    hunterSprite.position = pos;
    
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
    
    if (walkDistance != 0.0f && walkSpeed > 0.0f) {
        if (!startedWalking) {
            int sign = walkDistance < 0 ? -1 : 1;
            float speed = walkSpeed * sign;
            
            body->SetLinearVelocity(b2Vec2(speed, 0));
            startedWalking = YES;
            currStartPosX = startPosition.x;
        }
        else if (state != kEnemyStateDead) {
            
            float distanceWalked = currStartPosX - (body->GetPosition().x*PTM_RATIO);
            
            if (fabsf(distanceWalked) > fabsf(walkDistance)) {
                // flip and walk other direction
                currStartPosX = body->GetPosition().x*PTM_RATIO;
                hunterSprite.flipX = !hunterSprite.flipX;
                int sign = body->GetLinearVelocity().x < 0 ? 1 : -1;
                float speed = walkSpeed * sign;
                
                body->SetLinearVelocity(b2Vec2(speed,0));
            }
        }
    }
}

- (void) show {
    
    if (state == kEnemyStateAlive) {
        hunterSprite.visible = YES;
        body->SetActive(YES);
    } else {
        [self hide];
    }
}

- (void) hide {
    hunterSprite.visible = NO;
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
    return ccp((body->GetPosition().x * PTM_RATIO) - [hunterSprite boundingBox].size.width/2, body->GetPosition().y * PTM_RATIO);
}

- (void) createPhysicsObject:(b2World *)theWorld {
    world = theWorld;
    
    //===============================
    // Create the Hunter
    //===============================
    hunterSprite = [CCSprite spriteWithFile:@"hunter.png"];
    hunterSprite.position = self.position;
    //hunterSprite.scale = 0.75f;
    [[GamePlayLayer sharedLayer] addChild:hunterSprite z: 0];
    
    b2BodyDef hunterBodyDef;
    hunterBodyDef.type = b2_kinematicBody; //b2_dynamicBody;
    hunterBodyDef.userData = self;
    hunterBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    body = world->CreateBody(&hunterBodyDef);
    body->SetSleepingAllowed(false);
    //body->SetGravityScale(3.5);
    
    // Create the hunter's fixture
    b2PolygonShape shape;
    shape.SetAsBox(widthRatio*([hunterSprite boundingBox].size.width/PTM_RATIO/2), heightRatio*([hunterSprite boundingBox].size.height/PTM_RATIO/2));
    b2FixtureDef hunterFixtureDef;
    hunterFixtureDef.shape = &shape;
    hunterFixtureDef.friction = 3.0f;
#ifdef USE_CONSISTENT_PTM_RATIO
    hunterFixtureDef.density =  1.0f;
#else
    hunterFixtureDef.density =  1.0f/ssipad(4.0, 1);
#endif
    
    collideWithPlayer.categoryBits = CATEGORY_ENEMY;
    collideWithPlayer.maskBits = CATEGORY_JUMPER | CATEGORY_MISSILE | CATEGORY_FLOATING_PLATFORM | CATEGORY_ENEMY | CATEGORY_GROUND;
    
    noCollideWithPlayer.categoryBits = CATEGORY_ENEMY;
    noCollideWithPlayer.maskBits = CATEGORY_ENEMY | CATEGORY_GROUND;
    
    onlyCollideWithPlatform.categoryBits = CATEGORY_ENEMY;
    onlyCollideWithPlatform.maskBits = CATEGORY_FLOATING_PLATFORM | CATEGORY_ENEMY | CATEGORY_GROUND;
    
    collideWithNothing.categoryBits = 0;
    collideWithNothing.maskBits =  CATEGORY_GROUND;
    
    hunterFixtureDef.filter.categoryBits = collideWithPlayer.categoryBits;
    hunterFixtureDef.filter.maskBits = collideWithPlayer.maskBits;
    hunterFixture = body->CreateFixture(&hunterFixtureDef); 
}

- (void) onlyCollideWithPlatform {
    // allow the player to fall through without further contacts that require presolves
    hunterFixture->SetFilterData(onlyCollideWithPlatform);
}

- (void) setCollideWithPlayer:(BOOL)doCollide {
    
    if (state == kEnemyStateAlive) {
        if (doCollide) {
            hunterFixture->SetFilterData(collideWithPlayer);
        } else {
            hunterFixture->SetFilterData(noCollideWithPlayer);        
        }
    }
}

- (void) collideWithNothing {
    hunterFixture->SetFilterData(collideWithNothing);
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
    [self show];
}

- (void) reset {
    state = kEnemyStateAlive;
    body->SetActive(YES);
    //body->SetGravityScale(1);
    body->SetLinearVelocity(b2Vec2(0, 0));
    [self setCollideWithPlayer: YES];
    [self moveTo: startPosition];
    startedWalking = NO;
    [self show];
}

- (void) dealloc {
    // DO NOT DESTROY PHYSICS OBJECTS HERE!
    // SOMETHING WILL CALL destroyPhysicsObject
    
    CCLOG(@"------------------------------ Hunter being deallocated");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [super dealloc];
}

@end
