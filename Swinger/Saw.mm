//
//  Saw.m
//  Swinger
//
//  Created by Isonguyo Udoka on 8/27/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Saw.h"
#import "Player.h"
#import "GamePlayLayer.h"
#import "AchievementManager.h"
#import "MainGameScene.h"
#import "AudioEngine.h"

//const float bodyWidth = 0.1;
//const float bodyHeight = 1;
const float spinRate = 5;

@implementation Saw

@synthesize flyDistance;
@synthesize flySpeed;

+ (id) make: (float) theflyDistance speed: (float) theSpeed {
    return [[[self alloc] initSaw: theflyDistance speed: theSpeed] autorelease];
}

- (id) initSaw: (float) theflyDistance speed: (float) theSpeed  {
	if ((self = [super init])) {
        screenSize = [CCDirector sharedDirector].winSize;
        flyDistance = theflyDistance;
        flySpeed = theSpeed;
        startedMoving = NO;
        state = kEnemyStateAlive;
    }
    
    return self;
}

#pragma mark - GameObject protocol

- (GameObjectType) gameObjectType {   
    return kGameObjectSaw;
}

- (void) attack: (Player *) player at: (CGPoint) location {
    // decide whether i bumped off the player or player killed me
    
    if (state == kEnemyStateAlive) {
        BOOL canKill = [self canKill: player];
        
        if (!canKill) {
            // blow up and fall apart
            [self die];
            [player enemyKilled:self];
        } else {
            [[AudioEngine sharedEngine] playEffect:SND_SAW gain:0.25];
            [[AudioEngine sharedEngine] playEffect:SND_LAND gain:32];
            //[self setCollideWithPlayer: NO];
            [[MainGameScene sharedScene] shake: ssipadauto(3) duration: 0.25];
            [[AchievementManager sharedInstance] killedBySaw];
            [player fallingAnimation];
            //CCLOG(@"PLAYER KILLED BY SAW");
            
        }
    }
}

- (void) fall {
    //state = kEnemyStateDead;
    [self setCollideWithPlayer: NO];
    [self fallApart]; // blow up animation needed
    body->SetLinearVelocity(b2Vec2(0,-20));
    state = kEnemyStateNone;
}

- (void) fallApart {
    
    [[AudioEngine sharedEngine] playEffect:SND_SAW_DESTROYED];
    
    if (pivotJoint != nil) {
        world->DestroyJoint(pivotJoint);
        pivotJoint = nil;
    }
    
    if (saw1Joint != nil) {
        world->DestroyJoint(saw1Joint);
        saw1Joint = nil;
    }
    
    if (saw2Joint != nil) {
        world->DestroyJoint(saw2Joint);
        saw2Joint = nil;
    }
}

- (BOOL) willKill:(Player *)player {
    // always kills player unless player has an appropriate power up
    bool ret = (state == kEnemyStateAlive);
    
    if (ret) {
        //[[AchievementManager sharedInstance] killedBySaw];
    }
    
    return ret;
}

- (void) die {
    [super die];
    [self stopSound];
}

- (void) startSound {
    
    if (state != kEnemyStateDead) {
        sawSound = [[AudioEngine sharedEngine] playEffect:SND_SAW gain:0.8 loop:YES];
    } else {
        [self stopSound];
    }
}

- (void) stopSound {
    if (sawSound > 0)
        [[AudioEngine sharedEngine] stopEffect:sawSound];
}

- (BOOL) isVisible {
    return saw1.visible;
}

- (void) updateObject:(ccTime)dt scale:(float)scale {
    
    if (state == kEnemyStateDead) {
        [self fall];
        return;
    }
    
    // Hide if off screen and show if on screen. We should let each object control itself instead
    // of managing everything from GamePlayLayer. Convert to world coordinate first, and then compare.
    CGPoint gamePlayPosition = [[GamePlayLayer sharedLayer] getNode].position;
    
    CGPoint worldPos = ccp(normalizeToScreenCoord(gamePlayPosition.x, (body->GetPosition().x * PTM_RATIO) - [saw1 boundingBox].size.width/2, scale), 
                           gamePlayPosition.y + (body->GetPosition().y * PTM_RATIO));
    if (saw1.visible && (worldPos.x < -([saw1 boundingBox].size.width) || worldPos.x > screenSize.width)) {
        [self hide];
    } else if (!saw1.visible && worldPos.x >= -([saw1 boundingBox].size.width) && worldPos.x <= screenSize.width) {
        [self show];
    }
    
    if (!saw1.visible) {
        return;
    }
    
    CGPoint pos = ccp(body->GetPosition().x*PTM_RATIO, body->GetPosition().y*PTM_RATIO);
    sawCenter.position = pos;
    
    CGPoint saw1Pos = ccp(saw1Body->GetPosition().x*PTM_RATIO, saw1Body->GetPosition().y*PTM_RATIO);
    saw1.position = saw1Pos;
    
    CGPoint saw2Pos = ccp(saw2Body->GetPosition().x*PTM_RATIO, saw2Body->GetPosition().y*PTM_RATIO);
    saw2.position = saw2Pos;
    
    /*if (state == kEnemyStateDead) {
        [self fall];
        return;
    }*/
    
    if (state == kEnemyStateNone) {
        return;
    }
    
    [self checkPowerups];
    
    float phase = (2*M_PI*(dtSum))*(spinRate/4);
    float currentAngle = CC_RADIANS_TO_DEGREES(phase);
    saw1.rotation = -1*currentAngle;
    saw2.rotation = -1*currentAngle;
    sawCenter.rotation = CC_RADIANS_TO_DEGREES(-1*((b2RevoluteJoint *)pivotJoint)->GetJointAngle());
    
    dtSum += dt;
    
    if (flyDistance != 0 && flySpeed > 0) {
        if (!startedMoving) {
            int sign = flyDistance < 0 ? -1 : 1;
            float speed = flySpeed * sign;
            
            anchor->SetLinearVelocity(b2Vec2(0, speed));
            startedMoving = YES;
            currStartPosY = startPosition.y;
        }
        else if (state != kEnemyStateDead) {
            
            float distanceTravelled = currStartPosY - (anchor->GetPosition().y*PTM_RATIO);
            
            if (fabsf(distanceTravelled) > fabsf(flyDistance)) {
                // flip and move other direction
                currStartPosY = body->GetPosition().y*PTM_RATIO;
                int sign = anchor->GetLinearVelocity().y < 0 ? 1 : -1;
                float speed = flySpeed * sign;
                //CCLOG(@"----saw new speed %f", speed);
                anchor->SetLinearVelocity(b2Vec2(0, speed));
            }
        } else if (state == kEnemyStateDead) {
            //anchor->SetLinearVelocity(b2Vec2(0, -fabsf(flySpeed)));
        }
    }
}

- (void) show {
    
    saw1.visible = YES;
    saw2.visible = YES;
    sawCenter.visible = YES;
    body->SetActive(YES);
    saw1Body->SetActive(YES);
    saw2Body->SetActive(YES);
    anchor->SetActive(YES);
    
    //[self startSound];
}

- (void) hide {
    saw1.visible = NO;
    saw2.visible = NO;
    sawCenter.visible = NO;
    body->SetActive(NO);
    //saw1Body->SetActive(NO);
    //saw2Body->SetActive(NO);
    anchor->SetActive(NO);
    
    //[self stopSound];
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
        world->DestroyBody(saw1Body);
        world->DestroyBody(saw2Body);
        world->DestroyBody(body);
        world->DestroyBody(anchor);
        
        world = NULL;
    }
}

- (CGPoint) getLeftEdge {
    return ccp((body->GetPosition().x * PTM_RATIO) - [sawCenter boundingBox].size.height/2 - [saw1 boundingBox].size.width/2, body->GetPosition().y * PTM_RATIO);
}

- (void) createPhysicsObject:(b2World *)theWorld {
    world = theWorld;
    
    //===============================
    // Create the Saw
    //===============================
    saw1 = [CCSprite spriteWithFile:@"sawBlade.png"];
    saw2 = [CCSprite spriteWithFile:@"sawBlade.png"];
    sawCenter = [CCSprite spriteWithFile:@"sawCenter.png"];
    
    saw1.position = self.position;
    [[GamePlayLayer sharedLayer] addChild:saw1 z:0];
    saw2.position = self.position;
    [[GamePlayLayer sharedLayer] addChild:saw2 z:0];
    sawCenter.position = self.position;
    [[GamePlayLayer sharedLayer] addChild:sawCenter z:-1];
    
    //=================================================
    // Create the anchor at the center of the Saw
    //=================================================
    b2BodyDef anchorBodyDef;
    anchorBodyDef.type = b2_kinematicBody;
    anchorBodyDef.userData = NULL;
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
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.userData = self;
    bodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    body = world->CreateBody(&bodyDef);

    b2PolygonShape bodyShape;
    bodyShape.SetAsBox(0.8*[sawCenter boundingBox].size.width/PTM_RATIO/2, [sawCenter boundingBox].size.height/PTM_RATIO/2);
    b2FixtureDef bodyFixtureDef;
    bodyFixtureDef.shape = &bodyShape;
    bodyFixtureDef.friction = 0.0f;
#ifdef USE_CONSISTENT_PTM_RATIO
    bodyFixtureDef.density =  5.0f;
#else
    bodyFixtureDef.density =  5.0f/ssipad(4.0, 1);
#endif
    
    collideWithPlayer.categoryBits = CATEGORY_ENEMY;
    collideWithPlayer.maskBits = CATEGORY_JUMPER | CATEGORY_MISSILE;
    noCollideWithPlayer.categoryBits = 0;
    noCollideWithPlayer.maskBits = 0;
    
    bodyFixtureDef.filter.categoryBits = collideWithPlayer.categoryBits;
    bodyFixtureDef.filter.maskBits = collideWithPlayer.maskBits;
    sawBodyFixture = body->CreateFixture(&bodyFixtureDef);
    
    //======================================================
    // Create the Saws at the top and bottom of the shaft
    //======================================================
    b2BodyDef sawBodyDef;
    sawBodyDef.type = b2_dynamicBody;
    sawBodyDef.userData = self;
    sawBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    saw1Body = world->CreateBody(&sawBodyDef);
    
    b2CircleShape shape;
    shape.m_radius = [saw1 boundingBox].size.width/PTM_RATIO/2;
    b2FixtureDef saw1Def;
    saw1Def.shape = &shape;
    saw1Def.friction = 0;
#ifdef USE_CONSISTENT_PTM_RATIO
    saw1Def.density =  1.f;
#else
    saw1Def.density =  1.f/ssipad(4.0, 1);
#endif
    saw1Def.filter.categoryBits = collideWithPlayer.categoryBits;
    saw1Def.filter.maskBits = collideWithPlayer.maskBits;
    saw1BodyFixture = saw1Body->CreateFixture(&saw1Def);
    
    saw2Body = world->CreateBody(&sawBodyDef);
    saw2BodyFixture = saw2Body->CreateFixture(&saw1Def);
    
    [self createJoints];
}

- (void) createJoints {
    
    // create revolute joint with the pivot point
    if (pivotJoint == nil) {
    
        b2RevoluteJointDef pivotJointDef;
        pivotJointDef.bodyA = anchor;
        pivotJointDef.bodyB = body;
        pivotJointDef.collideConnected = NO;
        pivotJointDef.localAnchorA = b2Vec2(0,0);
        pivotJointDef.localAnchorB = b2Vec2(0,0);
        pivotJointDef.motorSpeed = spinRate;
        pivotJointDef.enableMotor = true;
        pivotJointDef.maxMotorTorque = 100000000;
        pivotJointDef.enableLimit = false;
        pivotJoint = world->CreateJoint(&pivotJointDef);
    }
    
    // create saw joints
    b2RevoluteJointDef jointDef;
    jointDef.bodyA = body;
    jointDef.collideConnected = NO;
    jointDef.motorSpeed = spinRate;
    jointDef.enableMotor = true;
    jointDef.maxMotorTorque = 100000000;
    jointDef.enableLimit = false;
    
    float height = [sawCenter boundingBox].size.height;
    
    if ([sawCenter boundingBox].size.width > height) {
        height = [sawCenter boundingBox].size.width;
    }
    
    float bodyHeight = height/PTM_RATIO/2;
    
    if (saw1Joint == nil) {
    
        jointDef.bodyB = saw1Body;
        jointDef.localAnchorA = b2Vec2(0,bodyHeight);
        jointDef.localAnchorB = b2Vec2(0,0);
        
        saw1Joint = world->CreateJoint(&jointDef);
    }
    
    if (saw2Joint == nil) {
    
        jointDef.bodyB = saw2Body;
        jointDef.localAnchorA = b2Vec2(0, -bodyHeight);
        jointDef.localAnchorB = b2Vec2(0,0);
        
        saw2Joint = world->CreateJoint(&jointDef);
    }
}

- (void) setCollideWithPlayer:(BOOL)doCollide {
    
    if (doCollide) {
        sawBodyFixture->SetFilterData(collideWithPlayer);
        saw1BodyFixture->SetFilterData(collideWithPlayer);
        saw2BodyFixture->SetFilterData(collideWithPlayer);
    } else {
        sawBodyFixture->SetFilterData(noCollideWithPlayer); 
        saw1BodyFixture->SetFilterData(noCollideWithPlayer);
        saw2BodyFixture->SetFilterData(noCollideWithPlayer);
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
    
    anchor->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0); // this should pull whole contraption into given position
    //body->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0);
}

- (void) showAt:(CGPoint)pos {
    startPosition = pos;
    
    [self moveTo:pos];
    //[self show];
}

- (void) reset {
    state = kEnemyStateAlive;
    [self setCollideWithPlayer: YES];
    body->SetLinearVelocity(b2Vec2(0, 0));
    [self createJoints]; // put saw object back together
    [self moveTo: startPosition];
    startedMoving = NO;
}

- (void) dealloc {
    // DO NOT DESTROY PHYSICS OBJECTS HERE!
    // SOMETHING WILL CALL destroyPhysicsObject
    
    CCLOG(@"------------------------------ Saw being deallocated");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [super dealloc];
}

@end
