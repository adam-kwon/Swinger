//
//  Cannon.m
//  Swinger
//
//  Created by Isonguyo Udoka on 6/2/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "MainGameScene.h"
#import "Cannon.h"
#import "Player.h"
#import "GamePlayLayer.h"
#import "CannonBlast.h"
#import "Macros.h"
#import "AudioEngine.h"
#import "Wind.h"
#import "Notifications.h"

#define CONTINUOUS_ROTATION 0

@implementation Cannon

static const float waitTime = 0.5f;

@synthesize barrelSprite;
//@synthesize anchorSprite;
@synthesize anchorPos;
@synthesize motorSpeed;
@synthesize shootingForce;
@synthesize rotationAngle;
@synthesize timeout;
@synthesize player;

- (id) init {
	if ((self = [super init])) {
        player = nil;
        
        screenSize = [CCDirector sharedDirector].winSize;
        trajectoryDrawn = NO;
    }
    
    return self;
}



- (void) createPhysicsObject:(b2World*)theWorld {
    world = theWorld;
    
    /*anchorSprite = [CCSprite spriteWithSpriteFrameName:@"CannonBase.png"];
    anchorSprite.position = self.position;
    [[GamePlayLayer sharedLayer] addChild:anchorSprite z: 2];*/
    
    //=================================================
    // Create the anchor at the bottom of the cannon
    //=================================================
    /*b2BodyDef anchorBodyDef;
    anchorBodyDef.type = b2_staticBody;
    anchorBodyDef.userData = NULL; //self;
    anchorBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    anchor = world->CreateBody(&anchorBodyDef);
    
    b2PolygonShape anchorShape;
    anchorShape.SetAsBox([anchorSprite boundingBox].size.width/PTM_RATIO/2, [anchorSprite boundingBox].size.height/PTM_RATIO/2);
    b2FixtureDef anchorFixture;
    anchorFixture.shape = &anchorShape;
#ifdef USE_CONSISTENT_PTM_RATIO
    anchorFixture.density = 100.0f;
#else
    anchorFixture.density = 100.0f/ssipad(4.0, 1);
#endif
    anchorFixture.filter.categoryBits = CATEGORY_ANCHOR;
    anchorFixture.filter.maskBits = 0;
    anchor->CreateFixture(&anchorFixture);*/
    
    //===============================
    // Create the rotating barrel
    //===============================
    barrelSprite = [CCSprite spriteWithSpriteFrameName:@"Cannon.png"];
    barrelSprite.position = self.position;
    [[GamePlayLayer sharedLayer] addChild:barrelSprite z: 0];
    
    b2BodyDef barrelBodyDef;
    barrelBodyDef.type = b2_staticBody;//b2_dynamicBody;
    barrelBodyDef.userData = self;
    barrelBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    //barrelBodyDef.fixedRotation = true;
    body = world->CreateBody(&barrelBodyDef);
    
    // Create the barrel's body
    b2PolygonShape shape;
    shape.SetAsBox([barrelSprite boundingBox].size.width/PTM_RATIO/2, [barrelSprite boundingBox].size.height/PTM_RATIO/2, b2Vec2(0,0), CC_DEGREES_TO_RADIANS(-90));
    b2FixtureDef barrelFixtureDef;
    barrelFixtureDef.shape = &shape;
#ifdef USE_CONSISTENT_PTM_RATIO
    barrelFixtureDef.density =  10000.0f;
#else
    barrelFixtureDef.density =  10000.0f/ssipad(4.0, 1);
#endif
    
    collideWithPlayer.categoryBits = CATEGORY_CANNON;
    collideWithPlayer.maskBits = CATEGORY_JUMPER;
    noCollideWithPlayer.categoryBits = 0;
    noCollideWithPlayer.maskBits = 0;
    
    barrelFixtureDef.filter.categoryBits = collideWithPlayer.categoryBits;
    barrelFixtureDef.filter.maskBits = collideWithPlayer.maskBits;
    barrelFixture = body->CreateFixture(&barrelFixtureDef);
    
    // create a revolute joint with a motor to oscillate between two points
    /*b2RevoluteJointDef revJointDef;
    revJointDef.bodyA = anchor;
    revJointDef.bodyB = body;
    revJointDef.collideConnected = false;
    
    // set the anchor for the body to be the bottom edge
    float xScale = 2*(screenSize.width/960);
    float yScale = 2*(screenSize.height/640);
    revJointDef.localAnchorA = b2Vec2(xScale*14/PTM_RATIO, yScale*29/PTM_RATIO);
    revJointDef.localAnchorB = b2Vec2(xScale*1/PTM_RATIO,0);
    revJointDef.motorSpeed = motorSpeed;
    
    // allow a small amount of overrun to account for rounding issues when converting to/from degrees
    revJointDef.lowerAngle = -(rotationAngle)*(M_PI/180.0) - 0.2f;
    revJointDef.upperAngle = (rotationAngle)*(M_PI/180.0) + 0.2f;
    revJointDef.enableLimit = YES;
    revJointDef.maxMotorTorque = 100000000;
    revJoint = (b2RevoluteJoint *)world->CreateJoint(&revJointDef);*/
    
    /*barrelLoadedSprite = [Player getInstanceOfCannonHead];
    barrelLoadedSprite.position = self.position;
    [[GamePlayLayer sharedLayer] addChild:barrelLoadedSprite z: -1];
    barrelLoadedSprite.visible = NO;*/
    
    //=========================
    // Set up Particle Effects
    //=========================
    blastEffect = [CannonBlast particleWithFile:@"cannonBlast.plist"]; // Need to create unique particle for cannon
    blastEffect.anchorPoint = ccp(0.5,0);
    blastEffect.position = self.position;
    [[GamePlayLayer sharedLayer] addChild:blastEffect z:-2];
    [blastEffect stopSystem];
    blastEffect.visible = NO;
    
    smoke = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:(@"puff.plist")];
    smoke.anchorPoint = ccp(0.5,0);
    smoke.position = self.position;
    smoke.positionType = kCCPositionTypeGrouped;
    [[GamePlayLayer sharedLayer] addChild:smoke z:-1];
    [smoke stopSystem];
    smoke.visible = NO;
    
    fuseEffect = [CannonFuse particleWithFile:@"fuseParticle.plist"];
    fuseEffect.scale = 1.f;
    fuseEffect.position = self.position;
    [[GamePlayLayer sharedLayer] addChild: fuseEffect z:1];
    fuseEffect.visible = NO;
    
    b2BodyDef fuseBodyDef;
    fuseBodyDef.type = b2_dynamicBody;
    fuseBodyDef.userData = NULL;
    fuseBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    fuse = world->CreateBody(&fuseBodyDef);
    
    b2PolygonShape fuseShape;
    fuseShape.SetAsBox(0.1,0.1);//[fuseEffect boundingBox].size.width,[fuseEffect boundingBox].size.height);
    b2FixtureDef fuseFixture;
    fuseFixture.shape = &fuseShape;
    fuseFixture.density = 1.f;
    fuseFixture.filter.categoryBits = CATEGORY_ANCHOR;
    fuseFixture.filter.maskBits = 0;
    fuse->CreateFixture(&fuseFixture);
    
    b2WeldJointDef fuseJointDef;
    fuseJointDef.Initialize(fuse, body, fuse->GetWorldCenter());
    fuseJointDef.collideConnected = NO;
    fuseJointDef.bodyA = fuse;
    fuseJointDef.bodyB = body;
    
    fuseJointDef.localAnchorA = b2Vec2(0,0);
    fuseJointDef.localAnchorB = b2Vec2(ssipadauto(-27.f)/self.scale/PTM_RATIO, ssipadauto(-30.f)/self.scale/PTM_RATIO);
    
    world->CreateJoint(&fuseJointDef);
    
    /*if (rotationAngle > -1 || rotationAngle < 1) {
        rotationAngle = 0; // doing this because level designer doesn't accept 0 for the angle
    }*/
    
    waitAngle = rotationAngle;//45;
    
    /*if ( rotationAngle < waitAngle) {
        waitAngle = rotationAngle;
    }*/
    
    // rotate barrel
    //body->SetTransform(body->GetPosition(), CC_DEGREES_TO_RADIANS(-rotationAngle));
    //barrelSprite.rotation = -1*(90-rotationAngle);
    
    [self reset];
}

- (float) getRotationRadius: (float) scale {
    
    // have to do this cuz of weird starting rotation of barrel
    CGSize size = [barrelSprite boundingBox].size;
    float height = size.height > size.width ? size.height : size.width;
    float rotationRadius = scale * ((height/2) + ssipad(3, -2));
    
    return rotationRadius;
}

- (void) updateObject:(ccTime)dt scale:(float)scale {
    
    //float phase = CC_DEGREES_TO_RADIANS(rotationAngle) * sinf((2*M_PI*(dtSum))*(0.10*motorSpeed));
    //float currentPhase = CC_RADIANS_TO_DEGREES(phase);
    //float currentAngle = revJoint->GetJointAngle();
    
    /*if (player == NULL && state != kCannonShotStraightUp) {
        // move cannon into starting position, even if off screen
        // wait facing the left for the player to jump into the barrel
        
        if (currentPhase - 0.5f > waitAngle) {
            dtSum += dt; // rotate until we come back to rest at the wait angle
        } else if (!initialized) {
            initialized = YES;
        }
    }*/
    
    // Hide if off screen and show if on screen. We should let each object control itself instead
    // of managing everything from GamePlayLayer. Convert to world coordinate first, and then compare.
    CGPoint gamePlayPosition = [[GamePlayLayer sharedLayer] getNode].position;
    
    CGPoint worldPos = ccp(normalizeToScreenCoord(gamePlayPosition.x, (body->GetPosition().x * PTM_RATIO) - [barrelSprite boundingBox].size.width/2, scale), 
                           gamePlayPosition.y + (body->GetPosition().y * PTM_RATIO));
    if (player == NULL && barrelSprite.visible && (worldPos.x < -([barrelSprite boundingBox].size.width) || worldPos.x > screenSize.width)) {
        [self hide];
    } else if (!barrelSprite.visible && worldPos.x >= -([barrelSprite boundingBox].size.width) && worldPos.x <= screenSize.width) {
        [self show];
    }
    
    // if we are offscreen, take no additional actions
    if (!barrelSprite.visible)
        return;
    
    /*if (player != NULL || state == kCannonShotStraightUp) {
        
        if(CONTINUOUS_ROTATION) {
            dtSum += dt;
        } else {
            if (state == kCannonShotStraightUp) {
                currentPhase = 0;
                currentAngle = 0;
                phase = 0;
            }
            else {
                if((currentPhase > 0 && prevPhase < 0) || (currentPhase < 0 && prevPhase > 0)) {
                    // sign flipped, just went past angle 0 so wait
                    deltaTime += dt;
                    
                    if(deltaTime > waitTime) {
                        deltaTime = 0;
                        dtSum += dt;
                    } else {
                        currentPhase = prevPhase;
                        phase = 0;
                    }
                } else if ([self isAtEdge: currentAngle]) {
                    // hit one of the edges, wait
                    deltaTime += dt;
                    
                    if(deltaTime > waitTime) {
                        deltaTime = 0;
                        dtSum += dt;
                        
                        if(rotationState == kCannonRotatingLeft) {
                            rotationState = kCannonRotatingRight;
                        } else {
                            rotationState = kCannonRotatingLeft;
                        }
                    } else {
                        currentPhase = prevPhase;
                        currentAngle = prevAngle;
                        phase = CC_DEGREES_TO_RADIANS(currentPhase);
                    }
                } else {
                    dtSum += dt;
                }
            }
        }
    }
    
    prevPhase = currentPhase;
    prevAngle = currentAngle;
    
    // Update barrel rotation angle
    body->SetTransform(body->GetPosition(), phase);*/
    
    // update the sprite positions
    //barrelSprite.position = ccp((body->GetPosition().x * PTM_RATIO), (body->GetPosition().y * PTM_RATIO));
    //barrelSprite.rotation = -1 * CC_RADIANS_TO_DEGREES(body->GetAngle()) - 90;
    //anchorSprite.position = ccp(anchor->GetPosition().x * PTM_RATIO, anchor->GetPosition().y * PTM_RATIO);
    //barrelLoadedSprite.scale = barrelSprite.scale; //scale;
    
    if (player != NULL) {
        [self scaleTrajectoryPoints: scale];
        [self setPlayerPosition];
        fuseEffect.position = ccp(fuse->GetPosition().x * PTM_RATIO, fuse->GetPosition().y * PTM_RATIO);
        
        if (shootImmediately) {
            [self shoot];
            shootImmediately = NO;
        }
    }
}

- (void) createJointWithPlayer: (b2Body*) pBody {
    
    b2WeldJointDef playerJointDef;
    playerJointDef.Initialize(body, pBody, body->GetWorldCenter());
    playerJointDef.collideConnected = NO;
    playerJointDef.bodyA = body;
    playerJointDef.bodyB = pBody;
    
    [self setPlayerPosition];
    
    //b2Vec2 weldPos = b2Vec2(barrelLoadedSprite.position.x/PTM_RATIO, barrelLoadedSprite.position.y/PTM_RATIO);
    float xPos = 0; //body->GetPosition().x - weldPos.x;
    float yPos = 0; //body->GetPosition().y - weldPos.y;
    
    playerJointDef.localAnchorA = b2Vec2(0,0);
    playerJointDef.localAnchorB = b2Vec2(xPos,yPos);
    
    jointWithPlayer = world->CreateJoint(&playerJointDef);
}

- (void) destroyJointWithPlayer {
    
    if (jointWithPlayer == NULL) {
        return;
    }
    
    world->DestroyJoint(jointWithPlayer);
    jointWithPlayer = NULL;
}

- (BOOL) isAtEdge: (float) currentAngle {
    //CCLOG(@"ROTATING %s current angle is %f, prev angle is %f", rotationState == kCannonRotatingLeft ? "Left" : "Right", currentAngle, prevAngle);
    return (rotationState == kCannonRotatingLeft && currentAngle > 0 && currentAngle < prevAngle) || 
           (rotationState == kCannonRotatingRight && currentAngle < 0 && currentAngle > prevAngle);
}

- (CGPoint) setPlayerPosition {
    NSAssert(player != NULL, @"Player should NOT be NULL");
    
    CGPoint origin = ccp(body->GetPosition().x * PTM_RATIO, body->GetPosition().y * PTM_RATIO);
    float angle = CC_DEGREES_TO_RADIANS(rotationAngle);//-1 * body->GetAngle();
    float angleDegs = rotationAngle; //CC_RADIANS_TO_DEGREES(angle);
    float x = origin.x + ([self getRotationRadius: barrelSprite.scale] * sinf(angle));
    float y = origin.y + ([self getRotationRadius: barrelSprite.scale] * cosf(angle));
    
    /*if(barrelLoadedSprite.visible) {
        barrelLoadedSprite.position = ccp(x,y - ssipadauto(4));//ccp(x,y - ssipadauto(4));
        barrelLoadedSprite.rotation = angleDegs - 90;
    }*/
    
    blastEffect.position = ccp(x,y);
    blastEffect.rotation = angleDegs;
    smoke.position = ccp(x,y);
    smoke.rotation = angleDegs;
    
    //player.rotation = angle;
    [player getPhysicsBody]->SetLinearVelocity(b2Vec2(0,0));
    return ccp(x,y - ssipadauto(4));
}

- (void) load: (Player *) thePlayer shoot: (BOOL) shoot {
    NSAssert(thePlayer != NULL, @"Player should NOT be NULL");
    
    [[AudioEngine sharedEngine] playEffect:SND_LOAD_CANNON];
    
    player = thePlayer;
    [self setPlayerPosition];
    [self startFuse];
    [self showLoaded];
    //[self showTrajectory:YES];
    initialized = YES;
    state = kCannonLoaded;
    shootImmediately = shoot;
    
    [self createJointWithPlayer: [player getPhysicsBody]];
}

- (void) showLoaded {
    
    /*CGPoint pos = barrelLoadedSprite.position;
    barrelLoadedSprite.position = ccp(pos.x - ssipadauto(5), pos.y - ssipadauto(5));
    barrelLoadedSprite.visible = YES;
    barrelLoadedSprite.opacity = 0; //visible = YES;
    CCMoveBy * move = [CCMoveBy actionWithDuration:0.20 position:ccp(ssipadauto(5),ssipadauto(5))];
    CCFadeIn * fadeIn = [CCFadeIn actionWithDuration:0.20];
    CCSpawn * spawn = [CCSpawn actions: move, fadeIn, nil];
    
    [barrelLoadedSprite stopAllActions];
    [barrelLoadedSprite runAction: spawn];*/
}

- (void) shoot {
    NSAssert(player != NULL, @"Player should NOT be NULL");
    
    [self setCollideWithPlayer:NO];
    
    b2Body * pBody = [player getPhysicsBody];
    pBody->SetGravityScale(0.80f);
    double angle = 0;
    double shootAngle = rotationAngle;
    
    if (shootAngle > 0 && shootAngle <= 1) {
        shootAngle = 0;
    }
    
    angle = -1 * CC_DEGREES_TO_RADIANS(-shootAngle);//body->GetAngle(); // shoot him off at the rotational angle
    double impulseMag = pBody->GetMass() * (angle == 0 ? 2*shootingForce : shootingForce);
    
    float x = impulseMag * sin(angle);
    float y = impulseMag * cos(angle);
    
    if(angle == 0.f) {
        state = kCannonShotStraightUp;
        x = 0;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NICE_JUMP object:self];
    } else {
        state = kCannonShot;
        
        float angleDegs = CC_RADIANS_TO_DEGREES(angle);
        
        if (fabsf(rotationAngle - angleDegs) <= 5) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NICE_JUMP object:self];
        }
    }
    
    //CCLOG(@"Angle: %f POSITION: (%f, %f) and mass=%f ANGLE IMPULSE (%f, %f)", angle, pBody->GetWorldCenter().x, pBody->GetWorldCenter().y, pBody->GetMass(),  x,y);
    
    [player flyingAnimation: CC_RADIANS_TO_DEGREES(angle)];
    [[AudioEngine sharedEngine] playEffect:SND_CANNON];
    //[self startblastEffect];
    [self stopFuse];
    
    [self setPlayerPosition];
    b2Vec2 impulseVec = b2Vec2(x, y);
    pBody->SetActive(YES);
    [self destroyJointWithPlayer];
    
    CGPoint pos = [self setPlayerPosition];
    
    pBody->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0);
    pBody->SetLinearVelocity(b2Vec2(0,0));
    pBody->ApplyLinearImpulse(impulseVec, pBody->GetWorldCenter());
    
    //barrelLoadedSprite.visible = NO;
    //[self showTrajectory:NO];
    
    player = NULL;
}

- (void) scaleTrajectoryPoints: (float) currentScale {
    
    if (currentScale > 1) {
        currentScale = 1;
    }
    
    for (CCSprite * dot in dashes) {
        if (!dot.visible) {
            break;
        }
        dot.scale = 1/currentScale;
    }
}

/**
 * Draw the cannons trajectory at the angle which it can shoot the player the furthest - usually 45 degrees
 * If the cannon does not sweep through angle 45 then we plot the trajectory at its largest angle
 * Refer to http://hyperphysics.phy-astr.gsu.edu/Hbase/traj.html for equations.
 */
- (void) drawTrajectory {
    
    if (trajectoryDrawn) {
        return;
    }
    
    double angleDegs = 45;
    
    if (rotationAngle < angleDegs) {
        angleDegs = rotationAngle;
    }
    
    b2Vec2 windForce = b2Vec2(0,0);
    
    if (wind != nil) {
        windForce = [wind getWindForce:1];
    }
    
    double angle = CC_DEGREES_TO_RADIANS(90-angleDegs);
    b2Vec2 origin = b2Vec2(body->GetPosition().x, body->GetPosition().y);
    float x0 = origin.x + ((([self getRotationRadius:1] + ssipad(80,0))/PTM_RATIO) * cosf(angle)); // starting x position in meters
    float y0 = origin.y + ((([self getRotationRadius:1] + ssipad(80,0))/PTM_RATIO) * sinf(angle)); // starting y position in meters
    float v01 = shootingForce + 4 + windForce.x; // initial x velocity in meters/sec + small buffer + wind force
    float v02 = shootingForce + 4 + windForce.y; // initial y velocity in meters/sec + small buffer + wind force
    
    float g = fabsf(world->GetGravity().y) + 6; // gravity in meters/sec + a small buffer
    
    float v0x = v01*cos(angle);
    float v0y = v02*sin(angle);
    
    float range = (2*(v0x*v0y))/g; // range of the cannon in meters
    
    float t = 0; // time in seconds
    float stepAmt = v01/(400 * (shootingForce > 20 ? 2 : 1));//0.05; // time step in fractions of a second

    dashes = [[CCArray alloc] init];
    while(true) 
    {
        float xPos = x0 + (cosf(angle)*v01*t); // x position over time
        float yPos = y0 + ((sinf(angle)*v02*t) - (g/2)*pow(t,2)); // y position over time taking gravity into consideration
        
        //CCLOG(@"DRAWING DASH AT %f,%f", xPos, yPos);
        
        CGPoint pos = ccp((xPos*PTM_RATIO), (yPos*PTM_RATIO));
        [dashes addObject:[[GamePlayLayer sharedLayer] addTrajectoryPoint: pos]];
        
        t += stepAmt;
        
        if (xPos > (x0 + range)) {
            break;
        }
    }
    
    trajectoryDrawn = YES;
}

- (void) startblastEffect {
    
    blastEffect.scaleX = ssipad(0.3, 0.2) * self.scale;
    blastEffect.scaleY = 0.5 * self.scale;
    blastEffect.visible = YES;
    [blastEffect resetSystem];
    
    smoke.scaleX = 1 * self.scale;
    smoke.scaleY = ssipad(0.4, 0.3) * self.scale;
    smoke.visible = YES;
    [smoke resetSystem];
    
    [[CCScheduler sharedScheduler] scheduleSelector : @selector(stopblastEffect) forTarget:self interval:0.4 paused:NO];
}

- (void) startFuse {
    
    fuseEffect.visible = YES;
    [fuseEffect resetSystem];
}

- (void) stopblastEffect {
    blastEffect.visible = NO;
    [blastEffect stopSystem];
    smoke.visible = NO;
    [smoke stopSystem];
    
    [[CCScheduler sharedScheduler] unscheduleSelector:@selector(stopblastEffect) forTarget:self];
}

- (void) stopFuse {
    
    fuseEffect.visible = NO;
    [fuseEffect stopSystem];
}

-(void) moveTo:(CGPoint)pos {
    self.position = pos;
    
    //anchor->SetTransform(b2Vec2(pos.x/PTM_RATIO, (pos.y + [anchorSprite boundingBox].size.height/2)/PTM_RATIO), 0);
    //anchorSprite.position = pos;
    
    body->SetTransform(b2Vec2(pos.x/PTM_RATIO, (pos.y /*+ [anchorSprite boundingBox].size.height/2*/)/PTM_RATIO), CC_DEGREES_TO_RADIANS(-rotationAngle));
    barrelSprite.rotation = -1*(90-rotationAngle);
    barrelSprite.position = pos;
}

-(void) showAt:(CGPoint)pos {
    
    // Move the cannon
    [self moveTo:pos];
    
    [self show];
}

- (GameObjectType) gameObjectType {
    return kGameObjectCannon;
}

- (void) hide {
    //[anchorSprite setVisible:NO];
    [barrelSprite setVisible:NO];
    
    //[self showTrajectory: NO];
    
    //anchor->SetActive(NO);
    body->SetActive(NO);
}

- (void) show {
    //[anchorSprite setVisible:YES];
    [barrelSprite setVisible:YES];
    
    /*if (player != NULL) {
        [self showTrajectory:YES];
    } else {
        [self showTrajectory:NO];
    }*/
    
    //anchor->SetActive(YES);
    body->SetActive(YES);
}

- (void) showTrajectory: (BOOL) show {
    
    if (dashes == nil) {
        [self drawTrajectory];
    }
    
    for (CCSprite * dash in dashes) {
        [dash setVisible:show];
    }
}

- (void) destroyPhysicsObject {
    if (world != NULL) {
        //world->DestroyBody(anchor);
        world->DestroyBody(body);
        world->DestroyBody(fuse);
    }
}

- (void) dealloc {
    // DO NOT DESTROY PHYSICS OBJECTS HERE!
    // SOMETHING WILL CALL destroyPhysicsObject
    
    CCLOG(@"------------------------------ Cannon being deallocated");  
    player = nil;
    //[anchorSprite removeFromParentAndCleanup:YES];
    [barrelSprite removeFromParentAndCleanup:YES];
    //[barrelLoadedSprite removeFromParentAndCleanup:YES];
    [blastEffect removeFromParentAndCleanup:YES];
    [smoke removeFromParentAndCleanup:YES];
    [fuseEffect removeFromParentAndCleanup:YES];
    
    if (dashes != nil) {
        // clean up trajectory dashes
        for (CCSprite * dash in dashes) {
            [dash removeFromParentAndCleanup:YES];
        }
        
        [dashes removeAllObjects];
        [dashes release];
        dashes = nil;
    }
    
    [super dealloc];
}

- (void) setMotorSpeed:(float)newSpeed {
    motorSpeed = newSpeed;
    minSpeed = motorSpeed*.5f;
}

#pragma mark - CatcherGameObject protocol
- (CCNode<GameObject, PhysicsObject, CatcherGameObject>*) getNextCatcherGameObject {
    if (indexInLevelObjects + 1 < [levelObjects count]) 
        return [levelObjects objectAtIndex:indexInLevelObjects+1];
    
    // Last object is the final platform
    return [levelObjects lastObject];
}

- (void) setCollideWithPlayer:(BOOL)doCollide {
    if (doCollide) {
        barrelFixture->SetFilterData(collideWithPlayer);
    } else {
        barrelFixture->SetFilterData(noCollideWithPlayer);        
    }
}

- (CGPoint) getCatchPoint {
    return /*barrelSprite.position;*/ ccp(barrelSprite.position.x, barrelSprite.position.y + [barrelSprite boundingBox].size.height/2);
}

- (float) getHeight {
   return barrelSprite.position.y + [barrelSprite boundingBox].size.height/2 + ssipadauto(40);
}


- (void) setSwingerVisible:(BOOL)visible {
    
}

- (void) reset {
    
    [self destroyJointWithPlayer];
    
    // Initially rotating left
    initialized = NO;
    shootImmediately = NO;
    rotationState = kCannonRotatingLeft;
    prevPhase = 0;
    dtSum = 0;
    
    player = nil;
    state = kCannonNone;
    [self stopFuse];
    //barrelLoadedSprite.visible = NO;
    [self setCollideWithPlayer:YES];
}

@end
