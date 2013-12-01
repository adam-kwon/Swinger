//
//  Boulder.m - Represents a hamster Boulder the player runs on
//
//      Boulder Controls:
//      -----------------
//            Tap to build up the players momentum and touch to jump off the Boulder before the player gets tired.
//            *Be careful not to fall off the edge of the Boulder!*
//
//  Swinger
//
//  Created by Isonguyo Udoka on 6/18/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Boulder.h"
#import "Player.h"
#import "GamePlayLayer.h"
#import "CannonBlast.h"
#import "Macros.h"
#import "AudioEngine.h"
#import "Wind.h"
#import "MainGameScene.h"
#import "Notifications.h"
#import "AchievementManager.h"
#import "AudioEngine.h"

@implementation Boulder

@synthesize motorSpeed;

- (id) init {
	if ((self = [super init])) {
        screenSize = [CCDirector sharedDirector].winSize;
        [self initBoulder];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(playerFell) 
                                                     name:NOTIFICATION_PLAYER_FELL 
                                                   object:nil];
    }
    
    return self;
}


- (void) createPhysicsObject:(b2World*)theWorld {
    world = theWorld;
    
    //=================================================
    // Create the anchor that holds the boulder in place
    //=================================================
    b2BodyDef anchorBodyDef;
    anchorBodyDef.type = b2_staticBody;
    anchorBodyDef.userData = NULL; //self;
    anchorBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    anchor = world->CreateBody(&anchorBodyDef);
    anchor->SetSleepingAllowed(false);
    
    b2CircleShape anchorShape;
    anchorShape.m_radius = 0.1;
    b2FixtureDef anchorFixture;
    anchorFixture.shape = &anchorShape;
#ifdef USE_CONSISTENT_PTM_RATIO
    anchorFixture.density = 1.0f;
#else
    anchorFixture.density = 1.0f/ssipad(4.0, 1);
#endif
    anchorFixture.filter.categoryBits = CATEGORY_ANCHOR;
    anchorFixture.filter.maskBits = 0;
    anchor->CreateFixture(&anchorFixture);
    
    //===============================
    // Create the rotating Boulder
    //===============================
    boulderSprite = [CCSprite spriteWithSpriteFrameName:@"Wheel.png"];
    boulderSprite.position = self.position;
    boulderSprite.scale = 0.35;
    [[GamePlayLayer sharedLayer] addChild:boulderSprite z: 0];
    
    b2BodyDef boulderBodyDef;
    boulderBodyDef.type = b2_dynamicBody;
    boulderBodyDef.userData = self;
    boulderBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    //boulderBodyDef.fixedRotation = true;
    body = world->CreateBody(&boulderBodyDef);
    //body->SetSleepingAllowed(false);
    
    // Create the Boulder's fixture
    b2CircleShape shape;
    shape.m_radius = [boulderSprite boundingBox].size.width/PTM_RATIO/2;
    b2FixtureDef boulderFixtureDef;
    boulderFixtureDef.shape = &shape;
    boulderFixtureDef.friction = 4.0f;
    boulderFixtureDef.restitution = 0.4f; // make boulder bouncy
#ifdef USE_CONSISTENT_PTM_RATIO
    boulderFixtureDef.density =  10.0f;
#else
    boulderFixtureDef.density =  10.0f/ssipad(4.0, 1);
#endif
    
    collideWithPlayer.categoryBits = CATEGORY_ENEMY;
    collideWithPlayer.maskBits = CATEGORY_JUMPER | CATEGORY_FLOATING_PLATFORM | CATEGORY_MISSILE | CATEGORY_GROUND;
    noCollideWithPlayer.categoryBits = CATEGORY_ENEMY;
    noCollideWithPlayer.maskBits = CATEGORY_FLOATING_PLATFORM | CATEGORY_GROUND;
    collideWithNothing.categoryBits = 0;
    collideWithNothing.maskBits = 0;
    
    boulderFixtureDef.filter.categoryBits = collideWithPlayer.categoryBits;
    boulderFixtureDef.filter.maskBits = collideWithPlayer.maskBits;
    boulder = body->CreateFixture(&boulderFixtureDef);
    
    [self createStationaryJoint];
    playerJoint = nil;
    
    radius = ssipadauto(28)+[boulderSprite boundingBox].size.height/2;
}

- (CGPoint) getLeftEdge {
    return ccp((body->GetPosition().x * PTM_RATIO) - radius/*[boulderSprite boundingBox].size.width/2*/, body->GetPosition().y * PTM_RATIO);
}

- (void) createStationaryJoint {
    
    if (boulderJoint != nil) {
        world->DestroyJoint(boulderJoint);
        boulderJoint = nil;
    }
    
    // create a Boulder joint to hold it in place
    b2WeldJointDef revJointDef;
    revJointDef.bodyA = anchor;
    revJointDef.bodyB = body;
    revJointDef.collideConnected = false;
    
    // set the anchor for the body to be the bottom edge
    revJointDef.localAnchorA = b2Vec2(0,0);
    revJointDef.localAnchorB = b2Vec2(0,0);
    boulderJoint = (b2WeldJoint *)world->CreateJoint(&revJointDef);
    
}

- (BOOL) isVisible {
    return boulderSprite.visible;
}

- (void) updateObject:(ccTime)dt scale:(float)scale {
    
    // Hide if off screen and show if on screen. We should let each object control itself instead
    // of managing everything from GamePlayLayer. Convert to world coordinate first, and then compare.
    CGPoint gamePlayPosition = [[GamePlayLayer sharedLayer] getNode].position;
    
    CGPoint worldPos = ccp(normalizeToScreenCoord(gamePlayPosition.x, (body->GetPosition().x * PTM_RATIO) - [boulderSprite boundingBox].size.width/2, scale), 
                           gamePlayPosition.y + (body->GetPosition().y * PTM_RATIO));
    if (player == NULL && boulderSprite.visible && (worldPos.x < -([boulderSprite boundingBox].size.width) || worldPos.x > screenSize.width)) {
        [self hide];
    } else if (!boulderSprite.visible && worldPos.x >= -([boulderSprite boundingBox].size.width) && worldPos.x <= screenSize.width) {
        [self show];
    }
    
    // no need to do anything in this method if we are offscreen
    if (!boulderSprite.visible)
        return;
    
    CGPoint bodyPos = ccp((body->GetPosition().x * PTM_RATIO), (body->GetPosition().y * PTM_RATIO));
    
    // update the sprite positions
    boulderSprite.position = bodyPos;
    
    if (state == kEnemyStateDead) {
        [self fall];
        return;
    }
    
    if (state == kEnemyStateNone) {
        return;
    }
    
    [self checkPowerups];
    
    if (doUnload) {
        [self unload];
    }
    
    if (!startedRolling) {

        // if boulder is close enough to the player it starts rolling towards him
        if (boulderSprite.visible) {//distanceX <= startDistanceX) {// && fabsf(distanceY) <= startDistanceY) {
            [self roll];
        }
    }
    else {
        
        b2Vec2 pos = body->GetPosition();
        
        if (pos.y <= 0) {
            [self unload];
            [self stopSound];
            return;
        }
        
        float phase = (2*M_PI*(dtSum))*(motorSpeed);
        float currentAngle = CC_RADIANS_TO_DEGREES(phase);
        boulderSprite.rotation = -1 * currentAngle;
        
        dtSum += dt;
        
        body->ApplyLinearImpulse(b2Vec2(-1*fabsf(1*motorSpeed), 0), body->GetPosition());
        
        if (state != kEnemyStateDead && player != nil) {
            CGPoint origin = boulderSprite.position;
            float rotRadius = radius; // sprite's radius is not constant, wheel bobbles
            
            if (firstUpdate) {
                CGPoint centerPoint = boulderSprite.position;
                playerXPos = loadPosition.x - centerPoint.x;
                firstUpdate = NO;
            } else {
                float deltaXPos = rotRadius/motorSpeed*0.016f; // runs up to top of the boulder in half a minute
                
                playerXPos += deltaXPos;
                
                if (playerXPos >= 0) {
                    playerXPos = 0;
                }
            }
            
            float x = playerXPos + origin.x;
            float y = sqrtf(powf(rotRadius,2) - powf(playerXPos,2)) + origin.y;
            
            // calculate the players angle with respect to the boulder
            float angle = CC_RADIANS_TO_DEGREES(asinf((playerXPos+ssipadauto(10))/(rotRadius)));
            
            // Move player to proper location on the boulder
            [player getPhysicsBody]->SetTransform(b2Vec2(x/PTM_RATIO, y/PTM_RATIO), 0);
            
            player.rotation = angle;
        }
    }
}

- (void) roll {
    
    // break joint with static anchor
    if (boulderJoint != nil) {
        world->DestroyJoint(boulderJoint);
        boulderJoint = nil;
        sound = [[AudioEngine sharedEngine] playEffect:SND_BOULDER gain:32 loop:YES];
    }
    
    // start rolling backwards
    body->SetLinearVelocity(b2Vec2(-1*fabsf(2*motorSpeed), 0));
    startedRolling = YES;
}

- (void) fall {
    //[super die];
    state = kEnemyStateNone;
    boulder->SetFilterData(collideWithNothing);
    body->SetLinearVelocity(b2Vec2(2,-10));
    [self stopSound];
}

- (void) stopSound {

    [[AudioEngine sharedEngine] stopEffect:sound];
}

-(void) moveTo:(CGPoint)pos {
    self.position = pos;
    
    anchor->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0);
    //baseSprite.position = ccp(pos.x, pos.y - ([baseSprite boundingBox].size.height/2) + ssipad(27, 13.5));
    
    body->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0);
    boulderSprite.position = pos;
}

-(void) showAt:(CGPoint)pos {
    startLocation = pos;
    
    // Move the Boulder
    [self moveTo:pos];
    
    [self show];
}

- (void) attack: (Player *) thePlayer at:(CGPoint)location {
    NSAssert(thePlayer != NULL, @"Player being loaded should not be NULL!");
    
    BOOL canKill = [self canKill: thePlayer];
    
    if (canKill && state == kEnemyStateAlive) {
        
        [self setCollideWithPlayer: NO];
    
        loadPosition = location;
        player = thePlayer;
    
        firstUpdate = YES;
    
        if ([self willKill: thePlayer]) {
            // player crushed by boulder
            [self smash];
            [player fallingAnimation];
            [[AudioEngine sharedEngine] playEffect:SND_LAND gain:32];
            [[MainGameScene sharedScene] shake: ssipadauto(3) duration: 0.25];
            [[AchievementManager sharedInstance] killedByBoulder];
        } else {
            
            player.fallThrough = NO;
            if (player.state != kSwingerHovering) {
                [self createJointWithPlayer];
                [player boulderRunningAnimation: 1.f];
            }
        }
    } else {
        [player enemyKilled:self];
        [self die];
    }
}

- (BOOL) willKill: (Player *) thePlayer {
    
    if (state == kEnemyStateDead || state == kEnemyStateNone) {
        return NO;
    }
    
    BOOL kill = NO;
    
    float height = [thePlayer boundingBox].size.height/2;
    float playerYPos = ([thePlayer getPhysicsBody]->GetPosition().y*PTM_RATIO) - height;
    
    if (playerYPos <= (body->GetPosition().y*PTM_RATIO)) {
        kill = YES;
    } else {
        kill = NO;
    }
    
    return kill;
}

- (void) playerFell {
    
    [self stopSound];
    if (playerJoint != nil) {
        // boulder took the player down
        [self unloadPlayer: NO];
        state = kEnemyStateDead;
        body->SetLinearVelocity(b2Vec2(0,0));
        
        if (player != NULL) {
            [player getPhysicsBody]->SetLinearVelocity(b2Vec2(0,0));
        }
    }
}

- (void) destroyJointWithPlayer {
    
    if(playerJoint != nil) {
        CCLOG(@"Destroying joint with player");
        world->DestroyJoint(playerJoint);
        playerJoint = nil;
    }
}

- (void) createJointWithPlayer {
    NSAssert(player != NULL, @"Player should not be NULL!");
    CCLOG(@"Creating joint with player");
    
    [self destroyJointWithPlayer];
    
    b2Body *pBody = [player getPhysicsBody];
    
    // attach player to Boulder via joint with anchor    
    pBody->SetTransform(b2Vec2(body->GetPosition().x - (radius/PTM_RATIO), body->GetPosition().y), 0);
    pBody->SetGravityScale(0);
    
    b2DistanceJointDef jointDef;
    jointDef.Initialize(body, pBody, body->GetWorldCenter(), pBody->GetWorldCenter());
    playerJoint = (b2DistanceJoint *)world->CreateJoint(&jointDef);
}

- (void) doUnload {
    doUnload = YES;
}

- (void) unload {
    [self unloadPlayer: NO];
}

- (void) shakeScreen {
    
}

- (void) unloadPlayer: (BOOL) kill {
    //NSAssert(player != NULL, @"Player should not be NULL!");
    
    if (player == NULL) {
        // player was smashed and wasn't loaded
        return;
    }
    
    [self destroyJointWithPlayer];
    
    [player resetGravity];
    player.rotation = 0;
    [self setCollideWithPlayer: NO];
    
    if (kill) {
        /*b2Body * pBody = [player getPhysicsBody];
        pBody->SetLinearVelocity(b2Vec2(0,0));
        pBody->ApplyLinearImpulse(b2Vec2(-5*pBody->GetMass(), -1*pBody->GetMass()), pBody->GetWorldCenter());*/
        [player fallingAnimation];
    }
    
    player = nil;
}

- (void) smash {
    //[self setCollideWithPlayer:NO];
    [self unloadPlayer: YES];
}

- (GameObjectType) gameObjectType {
    return kGameObjectBoulder;
}

- (void) hide {
    [boulderSprite setVisible:NO];
    
    anchor->SetActive(NO);//startedRolling);
    body->SetActive(NO); //startedRolling);
    
    if (startedRolling) {
        [self stopSound];
    }
}

- (void) show {
    [boulderSprite setVisible:YES];
    
    anchor->SetActive(YES);
    body->SetActive(YES);
}

- (b2Body*) getPhysicsBody {
    //return anchor;
    return body;
}

- (void) destroyPhysicsObject {
    if (world != NULL) {
        if (boulderJoint != nil) {
            world->DestroyJoint(boulderJoint);
            boulderJoint = nil;
        }
        
        [self destroyJointWithPlayer];
        
        world->DestroyBody(anchor);
        world->DestroyBody(body);
    }
}

- (void) setCollideWithPlayer:(BOOL)doCollide {
    
    if (state == kEnemyStateAlive) {
        if (doCollide) {
            boulder->SetFilterData(collideWithPlayer);
        } else {
            boulder->SetFilterData(noCollideWithPlayer);        
        }
    }
}

- (CGPoint) getCatchPoint {
    return ccp(boulderSprite.position.x, boulderSprite.position.y + [boulderSprite boundingBox].size.height/2);
}

- (float) getHeight {
    // Return the height of object (used for zoom)
    return boulderSprite.position.y + [boulderSprite boundingBox].size.height/2 + [[[GamePlayLayer sharedLayer] getPlayer] boundingBox].size.height + ssipadauto(40);
}


- (void) setSwingerVisible:(BOOL)visible {
    
}

- (void) setMotorSpeed:(float)speed {
    motorSpeed = speed; // dont overwrite
}

- (void) initBoulder {
    playerXPos = 0;
    dtSum = 0;
    startedRolling = NO;
}

- (void) reset {
    
    if (player != nil) {
        [self unload];
    }
    
    [self stopSound];
    state = kEnemyStateAlive;
    doUnload = NO;
    [self destroyJointWithPlayer];
    
    [self initBoulder];
    [self setCollideWithPlayer:YES];
    [self createStationaryJoint];
    [self moveTo: startLocation];
}

- (CGRect) boundingBox {
    return [boulderSprite boundingBox];
}

- (void) dealloc {
    // DO NOT DESTROY PHYSICS OBJECTS HERE!
    // SOMETHING WILL CALL destroyPhysicsObject
    
    CCLOG(@"------------------------------ Boulder being deallocated");
    [self stopSound];
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    player = nil;
    //[baseSprite removeFromParentAndCleanup:YES];
    [boulderSprite removeFromParentAndCleanup:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PLAYER_FELL object:nil];
    
    [super dealloc];
}

@end
