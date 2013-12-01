//
//  RopeSwinger.m
//  SwingProto
//
//  Created by James Sandoz on 3/16/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "RopeSwinger.h"
#import "Constants.h"
#import "GamePlayLayer.h"
#import "Ground.h"
#import "AudioEngine.h"
#import "Player.h"
#import "Macros.h"
#import "MainGameScene.h"
#import "Notifications.h"
#import "Globals.h"

#define USE_ESTIMATED_FORCE 1

#define BASE_JUMP_X 3.5
#define BASE_JUMP_Y 2.5
#define BASE_LENGTH ssipadauto(100)
#define BASE_RATIO 30

// struct used to hold physics body data for a single rope segment
typedef struct {
    b2Body *body;
    b2Fixture *fixture;
} RopeSegment;

// number of segments into which a rope should be divided
static const int numSegments = 10;


@implementation RopeSwinger

@synthesize catcherSprite;
@synthesize anchorPos;
@synthesize swingAngle;
@synthesize period;
@synthesize swingScale;
@synthesize ropeSwivelPosition;
@synthesize treeSprite;
@synthesize grip;
@synthesize poleScale;
@synthesize jumpForce;


- (id) init {
	if ((self = [super init])) {
        screenSize = [[CCDirector sharedDirector] winSize];
        scrollBufferZone = screenSize.width/5;
        
        swingAngle = CC_DEGREES_TO_RADIANS(80);
        gravity = 9.8f;
        ropeLength = 2.0f;
        
        dtSum = 0;
        period = 2 * M_PI * sqrtf(ropeLength / gravity);
        CCLOG(@"************ period = %f", period);
        rope = nil;
        doDetach = NO;
        doDrop = NO;
        
        ropeSegments = [NSMutableArray arrayWithCapacity:numSegments];
        [ropeSegments retain];
    }
    
    return self;
}

- (void) createPhysicsObject:(b2World*)theWorld {
    world = theWorld;
    
    // select tree sprite based on the world
    NSString * treeName = @"L1a_Tree1.png";
    
    if ([[[MainGameScene sharedScene] world] isEqualToString: WORLD_FOREST_RETREAT]) {
        treeName = @"L2a_Tree1.png";
    }
    
    treeSprite = [CCSprite spriteWithSpriteFrameName:treeName];
    treeSprite.anchorPoint = ccp(0.5,0);
    treeSprite.position = ccp(self.position.x, 0);
    treeSprite.scale = poleScale*1.75;
    //poleSprite.visible = NO;
    [[GamePlayLayer sharedLayer] addChild:treeSprite z:-5];
    
    // The pivot point for the pendulum
    ropeSwivelPosition = ccp(treeSprite.position.x, treeSprite.position.y + [treeSprite boundingBox].size.height);
    
    // Calculating the rope length given the period (from levels plist)
    // Shorter rope will swing  
    //ropeLength = 2*(gravity * period * period) / (4 * M_PI * M_PI);
    float xDiff = treeSprite.position.x - ropeSwivelPosition.x;
    float yDiff = (treeSprite.position.y + [treeSprite boundingBox].size.height) - (ropeSwivelPosition.y - swingScale);
    ropeLength = (sqrt(xDiff*xDiff + yDiff*yDiff)/2);// - 17*ssipad(2, 1));
    CCLOG(@"********** period = %f ropeLen = %f", period, ropeLength);
    
    catcherSprite = [CCSprite spriteWithSpriteFrameName:@"Catcher.png"];
    catcherSprite.opacity = 0;
    
    cap = [CCSprite spriteWithSpriteFrameName:@"SwingPoleTop1.png"];
    cap.visible = NO;
    cap.position = ccp(treeSprite.position.x, treeSprite.position.y + [treeSprite boundingBox].size.height);
    [[GamePlayLayer sharedLayer] addChild:cap];
    
    CGPoint catcherPos = ccp(cap.position.x, cap.position.y - ropeLength/2);
    catcherSprite.position = catcherPos;
    [[GamePlayLayer sharedLayer] addChild:catcherSprite];
    
    b2BodyDef capBodyDef;
    capBodyDef.type = b2_staticBody;
    //capBodyDef.userData = self;
    capBodyDef.position.Set(cap.position.x/PTM_RATIO, cap.position.y/PTM_RATIO);
    capBody = world->CreateBody(&capBodyDef);
    
    b2CircleShape capPoint;
    capPoint.m_radius = [cap boundingBox].size.width/PTM_RATIO/2;
    
    b2FixtureDef capFixtureDef;
    capFixtureDef.shape = &capPoint;
    capFixtureDef.density = 100.f;
    capFixtureDef.friction = 0;
    capBody->CreateFixture(&capFixtureDef);
    
//    b2BodyDef catcherBodyDef;
//    catcherBodyDef.type = b2_dynamicBody;
//    //catcherBodyDef.fixedRotation = YES;
//    catcherBodyDef.userData = self;
//    catcherBodyDef.position.Set(catcherPos.x/PTM_RATIO, (catcherPos.y + ropeLength)/PTM_RATIO);
//    body = world->CreateBody(&catcherBodyDef);
//    //body->SetSleepingAllowed(false);
//    
//    b2PolygonShape catcherBox;
//    catcherBox.SetAsBox(0.3,ropeLength/PTM_RATIO);
//    //catcherBox.SetAsBox(([catcherSprite boundingBox].size.width)/PTM_RATIO/2, ([catcherSprite boundingBox].size.height)/PTM_RATIO/2);
//    
//    b2FixtureDef catcherFixtureDef;
//    catcherFixtureDef.shape = &catcherBox;
//#ifdef USE_CONSISTENT_PTM_RATIO
//    catcherFixtureDef.density = 2.f;
//#else
//    catcherFixtureDef.density = 2.f/ssipad(4.0, 1.0);
//#endif
//    catcherFixtureDef.friction = 1.0f;
//    catcherFixtureDef.isSensor = YES;
    
    collideWithPlayer.categoryBits = CATEGORY_CATCHER;
    collideWithPlayer.maskBits = CATEGORY_JUMPER;
    noCollideWithPlayer.categoryBits = 0;
    noCollideWithPlayer.maskBits = 0;
    
//    catcherFixtureDef.filter.categoryBits = collideWithPlayer.categoryBits;
//    catcherFixtureDef.filter.maskBits = collideWithPlayer.maskBits;
//    catcherFixture = body->CreateFixture(&catcherFixtureDef);

    // Create the rope body as a series of segments so the rope body will swing naturally
    // and follow the verlet rope path
    float segmentLength = ropeLength*2/numSegments;
    b2Vec2 segPos = b2Vec2(cap.position.x/PTM_RATIO, (cap.position.y - segmentLength/2)/PTM_RATIO);
    lastSegmentBody = NULL;
//    CCLOG(@"\n\n\n****   Creating rope with %d segments and seg length=%f (%f m).  cap box2dpos=(%f,%f), ccpos=(%f,%f)  ****\n", numSegments, segmentLength, segmentLength/PTM_RATIO, cap.position.x, cap.position.y, capBody->GetPosition().x, capBody->GetPosition().y);
    for (int i=0; i < numSegments; i++) {
        b2BodyDef segBodyDef;
        segBodyDef.type = b2_dynamicBody;
        segBodyDef.userData = self;
        segBodyDef.position.Set(segPos.x, segPos.y);
        b2Body *segBody = world->CreateBody(&segBodyDef);
                
        b2PolygonShape segBox;
        segBox.SetAsBox(0.3, segmentLength/2/PTM_RATIO);
        
        b2FixtureDef segFixtureDef;
        segFixtureDef.shape = &segBox;
        segFixtureDef.density = 50.f;
        segFixtureDef.friction = 1.0f;
        segFixtureDef.isSensor = YES;
        segFixtureDef.filter.categoryBits = collideWithPlayer.categoryBits;
        segFixtureDef.filter.maskBits = collideWithPlayer.maskBits;
        
        b2Fixture *segFixture = segBody->CreateFixture(&segFixtureDef);

        RopeSegment *ropeSegment = (RopeSegment *)malloc(sizeof(RopeSegment));
        ropeSegment->body = segBody;
        ropeSegment->fixture = segFixture;
        [ropeSegments addObject:[NSValue valueWithPointer:ropeSegment]];
        
        // create a joint to the previous segment, or if this is the first segment create
        // the pivot joint
        if (lastSegmentBody == NULL) {
            b2RevoluteJointDef pivotJointDef;
            pivotJointDef.bodyA = capBody;
            pivotJointDef.bodyB = segBody;
            pivotJointDef.collideConnected = NO;
            pivotJointDef.localAnchorB = b2Vec2(0,(segmentLength/2/PTM_RATIO));
            world->CreateJoint(&pivotJointDef);
        } else {
            b2RevoluteJointDef segJointDef;
            segJointDef.Initialize(lastSegmentBody, segBody, b2Vec2(segPos.x, segPos.y + segmentLength/2/PTM_RATIO));

            world->CreateJoint(&segJointDef);
        }
        
        // update the last body reference
        lastSegmentBody = segBody;
        
        // update the segment position
        segPos.Set(segPos.x, segPos.y - (segmentLength/PTM_RATIO));
    }
        
    b2BodyDef endBodyDef;
    endBodyDef.type = b2_dynamicBody;
    //endBodyDef.userData = self;
    endBodyDef.position.Set(cap.position.x/PTM_RATIO, (cap.position.y - 2*ropeLength)/PTM_RATIO);
    endBodyDef.linearDamping = 0.6;
    endBody = world->CreateBody(&endBodyDef);
    
    b2CircleShape endPoint;
    endPoint.m_radius = [cap boundingBox].size.width/PTM_RATIO/2;
    
    b2FixtureDef endFixtureDef;
    endFixtureDef.shape = &endPoint;
    endFixtureDef.density = 40.f;
    endFixtureDef.friction = 0;
    endBody->CreateFixture(&endFixtureDef);
    
    // create revolute joint with the pivot point/cap
//    b2RevoluteJointDef pivotJointDef;
//    pivotJointDef.bodyA = capBody;
//    pivotJointDef.bodyB = body;
//    pivotJointDef.collideConnected = NO;
//    pivotJointDef.localAnchorB = b2Vec2(0,(ropeLength/PTM_RATIO));
//    world->CreateJoint(&pivotJointDef);
    
    // create the mouse joint to move the catcher
    b2MouseJointDef mouseJointDef;
    mouseJointDef.collideConnected = NO;
    mouseJointDef.bodyA = [[GamePlayLayer sharedLayer] getGround].groundBody;
    mouseJointDef.bodyB = endBody;
    
    mouseJointDef.maxForce = 10000*endBody->GetMass();
    mouseJointDef.dampingRatio = 0;
    mouseJointDef.frequencyHz = 100;
    mouseJointDef.target = endBody->GetPosition(); //b2Vec2(body->GetPosition().x, body->GetPosition().y + (ropeLength - [cap boundingBox].size.height/2)/PTM_RATIO);
    
    mouseJoint = (b2MouseJoint *)world->CreateJoint(&mouseJointDef);
    
    swingerHead = [CCSprite spriteWithSpriteFrameName:@"Default_H_Swing1.png"];
    swingerHead.position = ccp(ssipad(-18.75*2, -15.75), ssipad(23.23*2, 23.23));
    [catcherSprite addChild:swingerHead];
    swingerHead.visible = NO;
    
    swingerBody = [CCSprite spriteWithSpriteFrameName:@"Default_B_Swing1.png"];
    swingerBody.position = ccp(23.75*ssipad(2, 1), -8.25*ssipad(2, 1));
    [swingerHead addChild:swingerBody];
    swingerHead.opacity = 0;
    
    
    //CCSpriteBatchNode *ropeSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"rope.png" ];
    //[[GamePlayLayer sharedLayer] addChild:ropeSpriteSheet];
    
    //rope = [[VRope alloc] init:capBody body2:body spriteSheet:ropeSpriteSheet];
    //rope = [[GamePlayLayer sharedLayer] addRope:capBody body2:endBody];
    
    // calculate the jump force
    [self calcJumpForce];
}

- (void) createRopeEndJoint {
    
    if (steadyJoint != NULL) {
        world->DestroyJoint(steadyJoint);
        steadyJoint = NULL;
    }
    
    // hold the rope body steady when player is not swinging
    b2WeldJointDef weldJointDef;
    weldJointDef.Initialize(endBody, lastSegmentBody, endBody->GetWorldCenter());
    weldJointDef.collideConnected = NO;
    weldJointDef.bodyA = endBody;
    weldJointDef.bodyB = lastSegmentBody;
    weldJointDef.localAnchorA = b2Vec2(0,0);
    weldJointDef.localAnchorB = b2Vec2(0, -(ropeLength/numSegments/2/PTM_RATIO));
//    weldJointDef.localAnchorB = b2Vec2(0,-((ropeLength/* - [cap boundingBox].size.height*/)/PTM_RATIO));
    steadyJoint = world->CreateJoint(&weldJointDef);
}

- (void) createRopeJoint {
    
    if (rope != nil)
        return;
    
    // move rope end body into place
    endBody->SetTransform(b2Vec2(cap.position.x/PTM_RATIO, (cap.position.y - 2*ropeLength)/PTM_RATIO), 0);
    
    [self createRopeEndJoint];
    
    // soft distance joint to allow the end body to move properly while still 
    // connected to the rope body
//    b2DistanceJointDef ropeJointDef;
//    b2WeldJointDef ropeJointDef;
    b2RevoluteJointDef ropeJointDef;
    ropeJointDef.collideConnected = NO;
    ropeJointDef.bodyA = endBody;
    ropeJointDef.bodyB = lastSegmentBody;
//    ropeJointDef.frequencyHz = 30.0f;
//    ropeJointDef.dampingRatio = 0.5f;
    ropeJointDef.localAnchorA = b2Vec2(0,0);
//    ropeJointDef.localAnchorB = b2Vec2(0,-((ropeLength/* - [cap boundingBox].size.height*/)/PTM_RATIO));
    ropeJointDef.localAnchorB = b2Vec2(0, -(ropeLength/numSegments/PTM_RATIO));
    //b2Vec2(0,-((ropeLength/numSegments/* - [cap boundingBox].size.height*/)/PTM_RATIO));
    world->CreateJoint(&ropeJointDef);
    
    rope = [[GamePlayLayer sharedLayer] addRope:capBody body2:endBody];
    
    mouseJoint->SetTarget(endBody->GetPosition());
}

- (void) calcJumpForce {
    
#ifdef USE_ESTIMATED_FORCE
    // Estimate an appropriate jump force based on observed values from testing
    float lengthScale = swingScale/BASE_LENGTH;
    lengthScale *= lengthScale;
    
    float anglePeriodScale = CC_RADIANS_TO_DEGREES(swingAngle)/period/BASE_RATIO;
    float factor = g_gameRules.gravity * 0.55; // was hardcoded to 1.1
    
    jumpForce = b2Vec2(BASE_JUMP_X*(lengthScale + anglePeriodScale)*factor, BASE_JUMP_Y*(lengthScale + anglePeriodScale)*factor);
    
    CCLOG(@"\n\n###  set jumpForce=(%f, %f)  length=%f, max angle=%f, period=%f  ###\n\n", jumpForce.x, jumpForce.y, swingScale, CC_RADIANS_TO_DEGREES(swingAngle), period);
    
#else
    // Calculate the effective gravity for the given period and length.
    //   period = 2*pi*sqrt(L/g)
    //
    // Solve for g:
    //   g = (4*pi*pi*L)/period*period
    gravity = (4*M_PI*M_PI*swingScale/PTM_RATIO)/(period*period)*g_gameRules.gravity;
    
    // determine the velocity for half of the max angle (semi arbitrary but seems reasonable)
    // and then break down to the x and y component velocities
    // v = sqrt(2*gravity*ropeLength*(1-cos(angle)))
    float angle = swingAngle/2;
    float velocity = sqrtf(2*gravity*swingScale/PTM_RATIO*(1-cosf(angle)));
    
    float velX = velocity * cosf(angle);
    float velY = velocity * sinf(angle);
    jumpForce = b2Vec2(velX, velY);
    
    CCLOG(@"\n\n###  set gravity=%f, velocity=%f, jumpForce=(%f,%f)  ###\n\n", gravity, velocity, velX, velY);
#endif
}

- (void)setCatchBody:(b2Body *)cBody {
    body = cBody;
}

- (BOOL) caughtPlayer {
    //
    return jointWithPlayer != NULL;
}

- (void) attach: (Player *) thePlayer at: (CGPoint) location {
    CCLOG(@"ATTACHING TO ROPE!");
    CGPoint center = ccp(body->GetPosition().x*PTM_RATIO, body->GetPosition().y*PTM_RATIO);
    b2Body * pBody = [thePlayer getPhysicsBody];
    playerLocation = ccp(pBody->GetPosition().x*PTM_RATIO, pBody->GetPosition().y*PTM_RATIO);//location;
    
    float maxAnchor = ropeLength/2 - ssipadauto(40);
    float anchorY = playerLocation.y - center.y;
    
    if (anchorY > maxAnchor) {
        anchorY = maxAnchor;
    }
    
    b2WeldJointDef playerJointDef;
    playerJointDef.Initialize(body, pBody, body->GetWorldCenter());
    playerJointDef.collideConnected = NO;
    playerJointDef.bodyA = body;
    playerJointDef.bodyB = pBody;
    
    // set the local anchors of the joint to be the player and catcher's hands
//    playerJointDef.localAnchorA = b2Vec2(10/PTM_RATIO,anchorY/PTM_RATIO);
    playerJointDef.localAnchorA = b2Vec2(0,0);
    playerJointDef.localAnchorB = b2Vec2(0,0);//b2Vec2(-35/PTM_RATIO,15/PTM_RATIO);
    
    jointWithPlayer = world->CreateJoint(&playerJointDef);
    
    if (steadyJoint != NULL) {
        // destroy the steady joint
        world->DestroyJoint(steadyJoint);
        steadyJoint = NULL;
    }
    
    doDrop = NO;
    doDetach = NO;
    [thePlayer swingingAnimation];
    [self setCollideWithPlayer:NO];
}

- (void) detach: (Player *) thePlayer {
    
    doDetach = YES;
}

- (void) dropCatcher {
    doDrop = YES;
}

- (void) doDrop {
    
    if ([self destroyJointWithPlayer]) {
    
        //Player * player = [[GamePlayLayer sharedLayer] getPlayer];
        //[player fallingFromPlatformAnimation];
    }
    
    doDrop = NO;
}

- (BOOL) destroyJointWithPlayer {
    
    if (jointWithPlayer == NULL)
        return NO;
    
    world->DestroyJoint(jointWithPlayer);
    jointWithPlayer = NULL;
    
    return YES;
}

- (void) doDetach {
    
    if (jointWithPlayer == nil) {
        // no player to release
        return;
    }
    
    CCLOG(@"DETACHING FROM ROPE");
    Player * player = [[GamePlayLayer sharedLayer] getPlayer];
    
    /*float limitAngle = CC_RADIANS_TO_DEGREES(swingAngle);
    float currentAngle = -1*catcherSprite.rotation;
    
    if (fabsf((limitAngle - currentAngle) <= 5)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NICE_JUMP object:self];
    }*/
    
    // release from the rope
    [self destroyJointWithPlayer];
    
    [player jumpingAnimation];
    // fling yourself forward/backwards
    if (USE_CONSTANT_JUMP_FORCE_FROM_SWING != 0) {
        // jump backwards if on the backswing
        //    if (self.position.x < currentCatcher.position.x) {
        //        jumpForce = b2Vec2(-jumpForce.x, jumpForce.y);
        //    }
        //[player getPhysicsBody]->SetLinearVelocity(jumpForce);
        float mass = [player getPhysicsBody]->GetMass();
        [player getPhysicsBody]->SetLinearVelocity(b2Vec2(0,0));
        
        float xForce = mass*jumpForce.x;
        float yForce = mass*jumpForce.y;
        
        if (player.currentWind != nil) {
            //
            b2Vec2 windVec = [player.currentWind getWindForce: mass];
            xForce += windVec.x;
            yForce += windVec.y;
            player.currentWind = nil;
        }
        
        [player getPhysicsBody]->ApplyLinearImpulse(b2Vec2(xForce, yForce),[player getPhysicsBody]->GetPosition());
    } else {
        //float jumpImpulse = 2*body->GetMass();
        //body->ApplyLinearImpulse(b2Vec2(jumpImpulse, jumpImpulse), body->GetWorldCenter());
    }
    
    doDetach = NO;
}

- (void) createMagneticGrip : (float) radius {
    // destroy any existing magnetic grip
    [self destroyMagneticGrip];
    
    b2CircleShape magneGrip;
    magneGrip.m_radius = radius/PTM_RATIO;
    
    b2FixtureDef magneGripFixtureDef;
    magneGripFixtureDef.shape = &magneGrip;
#ifdef USE_CONSISTENT_PTM_RATIO
    magneGripFixtureDef.density = 0.1f;
#else
    magneGripFixtureDef.density = 0.1f/ssipad(4.0, 1.0);
#endif
    magneGripFixtureDef.friction = 1.0f;
    magneGripFixtureDef.isSensor = YES;
    
    magneGripFixtureDef.filter.categoryBits = collideWithPlayer.categoryBits;
    magneGripFixtureDef.filter.maskBits = collideWithPlayer.maskBits;
    magneticGripFixture = body->CreateFixture(&magneGripFixtureDef); 
}

- (void) destroyMagneticGrip {
    if(magneticGripFixture == nil)
        return;
    
    body->DestroyFixture(magneticGripFixture);
    magneticGripFixture = nil;
}

- (void) setCollideWithPlayer:(BOOL)doCollide {
    b2Filter newFilter = (doCollide ? collideWithPlayer : noCollideWithPlayer);
    
    for (NSValue *val in ropeSegments) {
        RopeSegment *seg = ((RopeSegment *)[val pointerValue]);
        seg->fixture->SetFilterData(newFilter);
    }
}

- (void) updateObject:(ccTime)dt scale:(float)scale {
    
    Player *thePlayer = [[GamePlayLayer sharedLayer] getPlayer];
    
    // Hide if off screen and show if on screen. We should let each object control itself instead
    // of managing everythign from GamePlayLayer. May want to add some buffer so swinger will still 
    // show even if pole is off screen. Convert to world coordinate first, and then compare.
    CGPoint gamePlayPosition = [[GamePlayLayer sharedLayer] getNode].position;
    float worldPos = normalizeToScreenCoord(gamePlayPosition.x, treeSprite.position.x, scale);
    if (worldPos < -scrollBufferZone || worldPos > screenSize.width+scrollBufferZone) {
        if (rope.visible && thePlayer.currentCatcher != self) {
            [self hide];
        }
    } else if (worldPos >= -scrollBufferZone && worldPos <= screenSize.width+scrollBufferZone) {
        if (!rope.visible) {
            [self show];
        }
    }
    
    // Equations used (http://en.wikipedia.org/wiki/Pendulum)
    // period = (2*PI) * sqrt(length/gravity)
    // theta(t) = maxTheta * cos(2*PI*t / period)
    
    float phase = -swingAngle * sinf((2*M_PI*(dtSum))/period);
    
    if (playerCaught) {
        dtSum += dt;
    } else {
        
        if (phase != 0) {
            SignType currSign = phase > 0 ? kSignPositive : kSignNegative;
            
            if (previousSign == currSign) {
                dtSum += dt;
            } else {
                // sign flipped, stop at angle 0
                phase = 0;
                dtSum = 0;
                [self createRopeEndJoint]; // steady the rope
            }
        }
        else {
            dtSum = 0;
            phase = 0;
        }
    }
    
    float x = ropeSwivelPosition.x - ((swingScale + ropeLength /*- [cap boundingBox].size.height/2*/)  * sinf(phase));
    float y = ropeSwivelPosition.y - ((swingScale + ropeLength /*- [cap boundingBox].size.height/2*/) * cosf(phase));
    
//    CCLOG(@"SWING X,Y = %f, %f", x,y);
    
    //catcherSprite.position = ccp(x, y);
    //catcherSprite.position = [[GamePlayLayer sharedLayer] getPlayer].position;
    //catcherSprite.rotation = CC_RADIANS_TO_DEGREES(phase);
    
    // Play swing sound fx each time he swings back and forth
    if (jointWithPlayer != nil && thePlayer.currentCatcher == self) {
        thePlayer.rotation = 0;//CC_RADIANS_TO_DEGREES(phase);
        if (thePlayer.state == kSwingerSwinging) {
            previousSign = sign;
            if (phase > 0) {
                sign = kSignPositive;
            } else {
                sign = kSignNegative;
            }
            
            if (previousSign != sign) {
                [[AudioEngine sharedEngine] playEffect:SND_SWOOSH];
            }
        }
    }
    
    mouseJoint->SetTarget(b2Vec2(x/PTM_RATIO, y/PTM_RATIO));
    //endBody->SetTransform(b2Vec2(x/PTM_RATIO, y/PTM_RATIO), 0);
    
    // Displays the correct catcher sprite animation frame based on angle of pendulum
    /*CCArray *swingHeadFrames = [Player getSwingHeadFrames];
    CCArray *swingBodyFrames = [Player getSwingBodyFrames];
    CCSpriteFrame *headFrame = [swingHeadFrames objectAtIndex:0];
    CCSpriteFrame *bodyFrame = [swingBodyFrames objectAtIndex:0];
    if (catcherSprite.rotation < -22) {
        headFrame = [swingHeadFrames objectAtIndex:4];
        bodyFrame = [swingBodyFrames objectAtIndex:4];
    } else if (catcherSprite.rotation < -7) {
        headFrame = [swingHeadFrames objectAtIndex:3];
        bodyFrame = [swingBodyFrames objectAtIndex:3];
    } else if (catcherSprite.rotation < 7) {
        headFrame = [swingHeadFrames objectAtIndex:2];
        bodyFrame = [swingBodyFrames objectAtIndex:2];
    } else if (catcherSprite.rotation < 22) {
        headFrame = [swingHeadFrames objectAtIndex:1];
        bodyFrame = [swingBodyFrames objectAtIndex:1];
    }
    
    [swingerHead setDisplayFrame:headFrame];
    [swingerBody setDisplayFrame:bodyFrame];*/
    
    // Draw the rope. Using a CCLayerColor instead of doing it in
    // OpenGL draw so that z-order issues can be easily managed.
    /*if (rope == nil) {
     float xDiff = poleSprite.position.x - x;
     float yDiff = (poleSprite.position.y + [poleSprite boundingBox].size.height) - (y);
     float dist = (sqrt(xDiff*xDiff + yDiff*yDiff)/catcherSprite.scale - 17*ssipad(2, 1));
     
     ccColor4B color = ccc4(51,102,153,255);
     
     if ([[[MainGameScene sharedScene] world] isEqualToString: WORLD_FOREST_RETREAT]) {
     color = ccc4(255,255,255,255);
     }
     
     rope = [CCLayerColor layerWithColor:color width:2 height:dist];
     [catcherSprite addChild:rope];
     
     rope.position = ccp(17*ssipad(2, 1), 45*ssipad(2, 1));
     }*/
    //[rope update: dt];
    
    //[self scaleTrajectoryPoints: scale];
    
    if (doDetach) {
        [self doDetach];
    } else if (doDrop) {
        [self doDrop];
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
 * Draw the trajectory at the angle which it can shoot the player the furthest - usually 45 degrees
 * If the cannon does not sweep through angle 45 then we plot the trajectory at its largest angle
 */
- (void) drawTrajectory {
    
    if (trajectoryDrawn) {
        return;
    }
    
    double angleDegs = 90;
    double swingAngleDegs = CC_RADIANS_TO_DEGREES(swingAngle);
    
    if (swingAngleDegs < angleDegs) {
        angleDegs = swingAngleDegs;
    }
    
    angleDegs = 90 - angleDegs;
    
    b2Vec2 windForce = b2Vec2(0,0);
    
    if (wind != nil) {
        windForce = [wind getWindForce:1];
    }
    
    double angle = CC_DEGREES_TO_RADIANS(angleDegs);
    b2Vec2 origin = b2Vec2((ropeSwivelPosition.x/PTM_RATIO), (ropeSwivelPosition.y/PTM_RATIO));
    float x0 = origin.x + (((swingScale)/PTM_RATIO) * cosf(angle)) + (([catcherSprite boundingBox].size.width/2) - ssipadauto(10))/PTM_RATIO; // starting x position in meters
    float y0 = origin.y - (((swingScale)/PTM_RATIO) * sinf(angle)) - ssipadauto(10)/PTM_RATIO; // starting y position in meters
    float v01 = jumpForce.x + 3 + windForce.x; // initial x velocity in meters/sec + small buffer + wind force
    float v02 = jumpForce.y + 3 + windForce.y; // initial y velocity in meters/sec + small buffer + wind force
    
    float g = fabsf(world->GetGravity().y); // gravity in meters/sec + a small buffer
    
    float v0x = v01*cos(angle);
    float v0y = v02*sin(angle);
    
    // range of the swing in meters + buffer since range is based on origin, and player lands below origin
    float range = ((2*(v0x*v0y))/g) + 2 + ((swingScale + [catcherSprite boundingBox].size.height)/PTM_RATIO);
    
    float t = 0; // time in seconds
    float stepAmt = v01/400; //0.05; // time step in fractions of a second
    
    dashes = [[CCArray alloc] init];
    while(true) 
    {
        float xPos = x0 + (cosf(angle)*v01*t); // x position over time
        float yPos = y0 + ((sinf(angle)*v02*t) - (g/2)*pow(t,2)); // y position over time taking gravity into consideration
        
        //CCLOG(@"DRAWING DASH AT %f,%f", xPos*PTM_RATIO, yPos*PTM_RATIO);
        
        CGPoint pos = ccp((xPos*PTM_RATIO), (yPos*PTM_RATIO));
        [dashes addObject:[[GamePlayLayer sharedLayer] addTrajectoryPoint: pos]];
        
        t += stepAmt;
        
        if (xPos > (x0 + range)) {
            break;
        }
    }
    
    trajectoryDrawn = YES;
}


-(void) moveTo:(CGPoint)pos {
    self.position = pos;
    
    // catcher position
    CGPoint catcherPos = ccp(pos.x, pos.y);
    
    //XXX necessary?  Will the weld joint automatically move him with the rope?
//    body->SetTransform(b2Vec2(catcherPos.x/PTM_RATIO, (catcherPos.y + ropeLength)/PTM_RATIO), 0);
    catcherSprite.position = catcherPos;
    
    treeSprite.position = catcherPos; //ccp(pos.x, pos.y);
    cap.position = ccp(pos.x, (pos.y + [treeSprite boundingBox].size.height));
    capBody->SetTransform(b2Vec2(cap.position.x/PTM_RATIO, cap.position.y/PTM_RATIO), 0);
    //endBody->SetTransform(b2Vec2(cap.position.x/PTM_RATIO, (cap.position.y - 2*ropeLength)/PTM_RATIO), 0);
    
    ropeSwivelPosition = ccp(cap.position.x, cap.position.y + ropeLength); //ccp(treeSprite.position.x, treeSprite.position.y + [treeSprite boundingBox].size.height);
    
    // move the rope segments
    int i=1;
    float segmentLength = ropeLength*2/numSegments;
    for (NSValue *val in ropeSegments) {
        RopeSegment *seg = ((RopeSegment *)[val pointerValue]);
        //XXX don't need to move into perfect position
        b2Vec2 newPos = b2Vec2(cap.position.x/PTM_RATIO, (cap.position.y - (segmentLength*i++))/PTM_RATIO);
//        CCLOG(@"  moving segment[%d] from (%f,%f) to (%f,%f)  ccpos=(%f,%f) to (%f,%f)\n", i, seg->body->GetPosition().x, seg->body->GetPosition().y, newPos.x, newPos.y, seg->body->GetPosition().x*PTM_RATIO, seg->body->GetPosition().y*PTM_RATIO, newPos.x*PTM_RATIO, newPos.y*PTM_RATIO);
        seg->body->SetTransform(newPos, 0);
    }
    [self createRopeJoint];
}

-(void) showAt:(CGPoint)pos {
    
    // Move the swinger
    [self moveTo:pos];
    [self show];
}

- (GameObjectType) gameObjectType {
    return kGameObjectCatcher;
}

- (void) hide {
    if(rope.visible) {
        [catcherSprite setVisible:NO];
        [rope setVisible:NO];
        swingerHead.visible = NO;
        [self showTrajectory: NO];
        
        //body->SetActive(NO);
        for (NSValue *val in ropeSegments) {
            RopeSegment *seg = ((RopeSegment *)[val pointerValue]);
            seg->body->SetActive(NO);
        }
    }
}

- (void) show {
    
    [catcherSprite setVisible:YES];
    [rope setVisible:YES];
    
    // Looks like there is a delay with the mouse joint. Move it initially.
    //body->SetTransform(b2Vec2(catcherSprite.position.x/PTM_RATIO, catcherSprite.position.y/PTM_RATIO), 0);
    
    if (swingerHead.visible) {
        [self showTrajectory:YES];
    } else {
        [self showTrajectory:NO];
    }
    
//    body->SetActive(YES);
    for (NSValue *val in ropeSegments) {
        RopeSegment *seg = ((RopeSegment *)[val pointerValue]);
        seg->body->SetActive(YES);
    }
}

- (void) showTrajectory: (BOOL) show {
    
    if (dashes == nil) {
        [self drawTrajectory];
    }
    
    for (CCSprite * dash in dashes) {
        [dash setVisible:show];
    }
}

#pragma mark - CatcherGameObject protocl

- (void) setSwingerVisible:(BOOL)visible {
    
    if (playerCaught != visible) {
        // switching
        playerReleased = !visible;
    }
    
    playerCaught = visible;
    //swingerHead.visible = visible;
    //[self showTrajectory:visible];
    
}

- (CGPoint) getCatchPoint {
    return catcherSprite.position;
}

- (float) getHeight {
    return treeSprite.position.y + [treeSprite boundingBox].size.height;
}

- (void) reset {
    
    if (jointWithPlayer != nil) {
        // release from the rope
        world->DestroyJoint(jointWithPlayer);
        jointWithPlayer = nil;
    }
    
    doDetach = NO;
    doDrop = NO;
    
    for (NSValue *val in ropeSegments) {
        RopeSegment seg = *((RopeSegment *)[val pointerValue]);
        seg.body->SetLinearVelocity(b2Vec2(0,0));
    }
    
    [self createRopeEndJoint];
    
    [self setSwingerVisible:NO];
    [super reset];
}

- (void) destroyPhysicsObject {
    if (world != NULL) {
        world->DestroyBody(capBody);
//        world->DestroyBody(body);
        world->DestroyBody(endBody);
        
        // clean up the rope segments
        for (NSValue *val in ropeSegments) {
            RopeSegment seg = *((RopeSegment *)[val pointerValue]);
            world->DestroyBody(seg.body);
        }
    }
}

- (void) dealloc {
    CCLOG(@"------------------------------ RopeSwinger being deallocated");
    
    // DO NOT DESTROY PHYSICS OBJECTS HERE!
    // SOMETHING WILL CALL destroyPhysicsObject
    [cap removeFromParentAndCleanup:YES];
    [swingerBody removeFromParentAndCleanup:YES];
    [swingerHead removeFromParentAndCleanup:YES];
    //[rope removeFromParentAndCleanup:YES];
    [catcherSprite removeFromParentAndCleanup:YES];
    [treeSprite removeFromParentAndCleanup:YES];
    
    //[rope removeSprites];
    //[rope release];
    
    if (dashes != nil) {
        // clean up trajectory dashes
        for (CCSprite * dash in dashes) {
            [dash removeFromParentAndCleanup:YES];
        }
        
        [dashes removeAllObjects];
        [dashes release];
        dashes = nil;
    }

    // clean up the rope segments
    for (NSValue *val in ropeSegments) {
        RopeSegment *seg = ((RopeSegment *)[val pointerValue]);
        free(seg);
    }
    
    [ropeSegments removeAllObjects];
    [ropeSegments release];
    ropeSegments = nil;
    
    [super dealloc];
}



@end
