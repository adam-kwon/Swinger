//
//  Wheel.m - Represents a hamster wheel the player runs on
//
//      Wheel Controls:
//      -----------------
//            Tap to build up the players momentum and touch to jump off the wheel before the player gets tired.
//            *Be careful not to fall off the edge of the wheel!*
//
//  Swinger
//
//  Created by Isonguyo Udoka on 6/18/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Wheel.h"
#import "Player.h"
#import "GamePlayLayer.h"
#import "CannonBlast.h"
#import "Macros.h"
#import "AudioEngine.h"
#import "Wind.h"
#import "MainGameScene.h"
#import "Notifications.h"

@implementation Wheel

@synthesize motorSpeed;
@synthesize timeout;

- (id) init {
	if ((self = [super init])) {
        screenSize = [CCDirector sharedDirector].winSize;
        [self initWheel];
    }
    
    return self;
}


- (void) createPhysicsObject:(b2World*)theWorld {
    world = theWorld;
    
    baseSprite = [CCSprite spriteWithSpriteFrameName:@"WheelBase.png"];
    baseSprite.position = ccp(self.position.x, 0);
    [[GamePlayLayer sharedLayer] addChild:baseSprite z: 1];
    
    //=================================================
    // Create the anchor at the bottom of the cannon
    //=================================================
    b2BodyDef anchorBodyDef;
    anchorBodyDef.type = b2_staticBody;
    anchorBodyDef.userData = NULL; //self;
    anchorBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    anchor = world->CreateBody(&anchorBodyDef);
    
    b2CircleShape anchorShape;
    anchorShape.m_radius = 0.1;
    b2FixtureDef anchorFixture;
    anchorFixture.shape = &anchorShape;
#ifdef USE_CONSISTENT_PTM_RATIO
    anchorFixture.density = 100.0f;
#else
    anchorFixture.density = 100.0f/ssipad(4.0, 1);
#endif
    anchorFixture.filter.categoryBits = CATEGORY_ANCHOR;
    anchorFixture.filter.maskBits = 0;
    anchor->CreateFixture(&anchorFixture);
    
    //===============================
    // Create the rotating wheel
    //===============================
    wheelSprite = [CCSprite spriteWithSpriteFrameName:@"Wheel.png"];
    wheelSprite.position = self.position;
    [[GamePlayLayer sharedLayer] addChild:wheelSprite z: 0];
    
    b2BodyDef wheelBodyDef;
    wheelBodyDef.type = b2_dynamicBody;
    wheelBodyDef.userData = self;
    wheelBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    //wheelBodyDef.fixedRotation = true;
    body = world->CreateBody(&wheelBodyDef);
    
    // Create the wheel's body
    b2CircleShape shape;
    shape.m_radius = [wheelSprite boundingBox].size.width/PTM_RATIO/2;
    b2FixtureDef wheelFixtureDef;
    wheelFixtureDef.shape = &shape;
    wheelFixtureDef.friction = 0.0f;
#ifdef USE_CONSISTENT_PTM_RATIO
    wheelFixtureDef.density =  5.0f;
#else
    wheelFixtureDef.density =  5.0f/ssipad(4.0, 1);
#endif
    
    collideWithPlayer.categoryBits = CATEGORY_ENEMY;
    collideWithPlayer.maskBits = CATEGORY_JUMPER;
    noCollideWithPlayer.categoryBits = 0;
    noCollideWithPlayer.maskBits = 0;
    
    wheelFixtureDef.filter.categoryBits = collideWithPlayer.categoryBits;
    wheelFixtureDef.filter.maskBits = collideWithPlayer.maskBits;
    wheel = body->CreateFixture(&wheelFixtureDef);
    
    // create a wheel joint with a motor to oscillate between two points
    b2RevoluteJointDef revJointDef;
    revJointDef.bodyA = anchor;
    revJointDef.bodyB = body;
    revJointDef.collideConnected = false;
    
    // set the anchor for the body to be the bottom edge
    revJointDef.localAnchorA = b2Vec2(0,0);
    revJointDef.localAnchorB = b2Vec2(0,0);
    revJointDef.motorSpeed = motorSpeed;
    revJointDef.enableMotor = true;
    revJointDef.maxMotorTorque = 100000000;
    revJointDef.enableLimit = false;
    wheelJoint = (b2RevoluteJoint *)world->CreateJoint(&revJointDef);
    
    radius = ssipadauto(28)+[wheelSprite boundingBox].size.height/2;
}

- (void) updateObject:(ccTime)dt scale:(float)scale {
    
    // Hide if off screen and show if on screen. We should let each object control itself instead
    // of managing everything from GamePlayLayer. Convert to world coordinate first, and then compare.
    CGPoint gamePlayPosition = [[GamePlayLayer sharedLayer] getNode].position;
    
    CGPoint worldPos = ccp(normalizeToScreenCoord(gamePlayPosition.x, (body->GetPosition().x * PTM_RATIO) - [wheelSprite boundingBox].size.width/2, scale), 
                           gamePlayPosition.y + (body->GetPosition().y * PTM_RATIO));
    if (player == NULL && wheelSprite.visible && (worldPos.x < -([wheelSprite boundingBox].size.width) || worldPos.x > screenSize.width)) {
        [self hide];
    } else if (!wheelSprite.visible && worldPos.x >= -([wheelSprite boundingBox].size.width) && worldPos.x <= screenSize.width) {
        [self show];
    }
    
    // no need to do anything in this method if we are offscreen
    if (!wheelSprite.visible)
        return;

    float motorSpeedFactor = ssipad(1,2)*0.5*(currentSpeed - motorSpeed);
    float maxMotorSpeedFactor = 5;
    
    if (motorSpeedFactor > maxMotorSpeedFactor) {
        motorSpeedFactor = maxMotorSpeedFactor;
    }
    
    if (motorSpeedFactor > speedFactor) {
        speedFactor = motorSpeedFactor;
    }
    
    float phase = (2*M_PI*(dtSum))*(speedFactor*motorSpeed);
    float currentAngle = CC_RADIANS_TO_DEGREES(phase);
    
    // Update wheel rotation angle
    body->SetTransform(body->GetPosition(), phase);
    
    // update the sprite positions
    wheelSprite.position = ccp((body->GetPosition().x * PTM_RATIO), (body->GetPosition().y * PTM_RATIO));
    wheelSprite.rotation = -1 * currentAngle;
    
    dtSum += dt;
    
    if(player != nil) {
        CGPoint origin = ccp(anchor->GetPosition().x * PTM_RATIO, anchor->GetPosition().y * PTM_RATIO);
        float rotRadius = radius; // sprite's radius is not constant, wheel bobbles
        
        if (firstUpdate) {
            CGPoint centerPoint = wheelSprite.position;
            playerXPos = loadPosition.x - centerPoint.x;
            firstUpdate = NO;
        } else {
            float deltaXPos = (currentSpeed - motorSpeed) * (motorSpeed/rotRadius) * ssipadauto(20.f);
            
            playerXPos += deltaXPos;
            
            if(playerXPos < -(rotRadius)) {
                playerXPos = -rotRadius;
            } else if (playerXPos > rotRadius) {
                playerXPos = rotRadius;
            }
        }
        
        float x = playerXPos + origin.x;
        float y = sqrtf(powf(rotRadius,2) - powf(playerXPos,2)) + origin.y;
        
        // calculate the players angle with respect to the wheel
        float angle = CC_RADIANS_TO_DEGREES(asinf((playerXPos+ssipadauto(10))/(rotRadius)));
        
        // Move player to proper location on the wheel
        [player getPhysicsBody]->SetTransform(b2Vec2(x/PTM_RATIO, y/PTM_RATIO), 0);
        
        player.rotation = angle;
        
        [self scaleTrajectoryPoints: scale];
        
        if(playerXPos <= -(rotRadius - 20) || playerXPos >= (rotRadius - 20)) {
            // die
            body->SetLinearVelocity(b2Vec2(0, body->GetLinearVelocity().y));
            [player fallingAnimation];
            [self unloadPlayer: YES];
        }
    }
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
 */
- (void) drawTrajectory {
    
    if (trajectoryDrawn) {
        return;
    }
    
    double angleDegs = 45;
    
    b2Vec2 windForce = b2Vec2(0,0);
    
    if (wind != nil) {
        windForce = [wind getWindForce:1];
    }
    
    double angle = CC_DEGREES_TO_RADIANS(angleDegs);
    b2Vec2 origin = b2Vec2(body->GetPosition().x, body->GetPosition().y);
    float x0 = origin.x + (((radius + ssipad(0,0))/PTM_RATIO) * cosf(angle)); // starting x position in meters
    float y0 = origin.y + (((radius + ssipad(0,0))/PTM_RATIO) * sinf(angle)); // starting y position in meters
    float v01 = jumpForce + 4 + windForce.x; // initial x velocity in meters/sec + small buffer + wind force
    float v02 = jumpForce + 4 + windForce.y; // initial y velocity in meters/sec + small buffer + wind force
    
    float g = fabsf(world->GetGravity().y); // gravity in meters/sec
    
    float v0x = v01*cos(angle);
    float v0y = v02*sin(angle);
    
    float range = (2*(v0x*v0y))/g; // range of the wheel in meters
    
    float t = 0; // time in seconds
    float stepAmt = v01/400;//0.05; // time step in fractions of a second
    
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

- (void) handleTap {
    [self increasePlayerSpeed];
}

- (void) increasePlayerSpeed {
    [self updatePlayerSpeed: ssipadauto(1)*speedDelta];
}

- (void) updatePlayerSpeed: (float) amount {
    // capping the players momentum
    float cap = ssipadauto(3)*motorSpeed;
    
    if (amount > 0 && currentSpeed + amount > cap) {
        amount = 0;
    } else if (amount < 0 && currentSpeed + amount < -cap) {
        amount = 0;
    }
    
    if(amount != 0) {
        currentSpeed += amount;
        [self setPace];
    }
}

- (void) decreasePlayerSpeed {
    [self updatePlayerSpeed: ssipadauto(-1.5)*speedDelta];
}

- (void) setPace {
    
    float pace = (currentSpeed - motorSpeed);
    if(pace <= 0) {
        pace = 1;
    } else if (pace <= 2*motorSpeed) {
        pace = 2;  
    } else {
        pace = 15;
    }
    
    if(pace != currentPace) {
        [player boulderRunningAnimation: pace];
        currentPace = pace;
    }
}

-(void) moveTo:(CGPoint)pos {
    self.position = pos;
    
    anchor->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0);
    baseSprite.position = ccp(pos.x, pos.y - ([baseSprite boundingBox].size.height/2) + ssipad(27, 13.5));
    
    body->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0);
    wheelSprite.position = pos;
}

-(void) showAt:(CGPoint)pos {
    
    // Move the wheel
    [self moveTo:pos];
    
    [self show];
}

- (void) load: (Player *) thePlayer at:(CGPoint)location {
    NSAssert(thePlayer != NULL, @"Player being loaded should not be NULL!");
    
    [self setCollideWithPlayer: NO];
    lastTapTime = nil;
    
    loadPosition = location;
    player = thePlayer;
    
    [self setPace];
    
    firstUpdate = YES;
    [self showTrajectory: YES];
    
    [self createJointWithPlayer];
    
    // Decrease players speed at a rate that is a factor of the speed of the wheel
    [[CCScheduler sharedScheduler] scheduleSelector : @selector(decreasePlayerSpeed) forTarget:self interval:(ssipad(0.05f, 0.1f)*5) paused:NO];
    
    if (location.y < (body->GetPosition().y*PTM_RATIO)) {
        // player landed too low to be caught by wheel
        [self unloadPlayer: YES];
        return;
    }
}

- (void) createJointWithPlayer {
    NSAssert(player != NULL, @"Player should not be NULL!");
    
    b2Body *pBody = [player getPhysicsBody];
    
    // attach player to wheel via joint with anchor    
    pBody->SetTransform(b2Vec2(body->GetPosition().x - (radius/PTM_RATIO), body->GetPosition().y), 0);
    pBody->SetGravityScale(0);
    
    b2DistanceJointDef jointDef;
    jointDef.Initialize(body, pBody, body->GetWorldCenter(), pBody->GetWorldCenter());
    playerJoint = (b2DistanceJoint *)world->CreateJoint(&jointDef);
}

- (void) unload {
    [self unloadPlayer: NO];
}

- (void) unloadPlayer: (BOOL) kill {
    NSAssert(player != NULL, @"Player should not be NULL!");
    
    // stop updating player speed
    [[CCScheduler sharedScheduler] unscheduleSelector:@selector(decreasePlayerSpeed) forTarget:self];
    
    [player getPhysicsBody]->SetGravityScale(1);
    player.rotation = 0;
    [self setCollideWithPlayer: NO];
    [self showTrajectory: NO];
    
    if(playerJoint != nil)
        world->DestroyJoint(playerJoint);
    
    if (kill) {
        [player fallingAnimation];
    }
    
    player = nil;
}

- (void) fling {
    NSAssert(player != NULL, @"Player should not be NULL!");
    
    b2Body * pBody = [player getPhysicsBody];
    float playerPosX = player.position.x;
    
    if (playerPosX >= wheelSprite.position.x) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NICE_JUMP object:self];
    }
    
    // Constant jump force
    float jumpMag = jumpForce;
    
    float impulseMag =  pBody->GetMass() * jumpMag;
    float x = impulseMag;
    float y = impulseMag;
    
    pBody->SetLinearVelocity(b2Vec2(0,0));
    pBody->ApplyLinearImpulse(b2Vec2(x, y), pBody->GetWorldCenter());
    
    [self unload];
}

- (GameObjectType) gameObjectType {
    return kGameObjectWheel;
}

- (void) hide {
    [baseSprite setVisible:NO];
    [wheelSprite setVisible:NO];
    [self showTrajectory: NO];
    
    anchor->SetActive(NO);
    body->SetActive(NO);
}

- (void) show {
    [baseSprite setVisible:YES];
    [wheelSprite setVisible:YES];
    
    if (player != NULL) {
        [self showTrajectory: YES];
    } else {
        [self showTrajectory: NO];
    }
    
    anchor->SetActive(YES);
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

- (b2Body*) getPhysicsBody {
    return anchor;
}

- (void) destroyPhysicsObject {
    if (world != NULL) {
        world->DestroyJoint(wheelJoint);
        world->DestroyBody(anchor);
        world->DestroyBody(body);
    }
}

- (void) dealloc {
    // DO NOT DESTROY PHYSICS OBJECTS HERE!
    // SOMETHING WILL CALL destroyPhysicsObject
    
    CCLOG(@"------------------------------ Wheel being deallocated");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    player = nil;
    [baseSprite removeFromParentAndCleanup:YES];
    [wheelSprite removeFromParentAndCleanup:YES];
    
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

- (void) setCollideWithPlayer:(BOOL)doCollide {
    if (doCollide) {
        wheel->SetFilterData(collideWithPlayer);
    } else {
        wheel->SetFilterData(noCollideWithPlayer);        
    }
}

- (CGPoint) getCatchPoint {
    return ccp(wheelSprite.position.x, wheelSprite.position.y + [wheelSprite boundingBox].size.height/2);
}

- (float) getHeight {
    // Return the height of object (used for zoom)
    return wheelSprite.position.y + [wheelSprite boundingBox].size.height/2 + [[[GamePlayLayer sharedLayer] getPlayer] boundingBox].size.height + ssipadauto(40);
}


- (void) setSwingerVisible:(BOOL)visible {
    
}

- (void) setMotorSpeed:(float)speed {
    motorSpeed = speed; // dont overwrite
    jumpForce = 10*motorSpeed;
    speedDelta = motorSpeed;
    currentSpeed = motorSpeed; // player starts out going as fast as wheel, if you don't tap he loses pace
    
    speedUpdateAmount = 0;
}

- (void) initWheel {
    lastTapTime = nil;
    animRate = 0.098;
    playerXPos = 0;
    dtSum = 0;
    currentPace = 0;
    speedFactor = 1;
}

- (void) reset {
    [self setCollideWithPlayer:YES];
    currentSpeed = motorSpeed;
    
    [self initWheel];
}

- (CGRect) boundingBox {
    return [wheelSprite boundingBox];
}

@end
