//
//  Loop.m
//  Swinger
//
//  Created by Isonguyo Udoka on 8/13/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Loop.h"
#import "GamePlayLayer.h"

static const uint16 CATEGORY_LOOP_HAND = 0x0200;

@implementation Loop

@synthesize radius;
@synthesize speed;

+ (id) make: (float) theRadius speed: (float) theSpeed {
    return [[[self alloc] initLoop: theRadius speed: theSpeed] autorelease];
}

- (id) initLoop: (float) theRadius speed: (float) theSpeed  {
	if ((self = [super init])) {
        screenSize = [CCDirector sharedDirector].winSize;
        
        radius = ssipadauto(110);//theRadius;
        speed = theSpeed;
        state = kLoopNone;
    }
    
    return self;
}

- (void) createPhysicsObject:(b2World*)theWorld {
    world = theWorld;
    
    //=================================================
    // Create the anchor & pulley of the loop
    //=================================================
    b2BodyDef anchorBodyDef;
    anchorBodyDef.type = b2_staticBody;
    anchorBodyDef.userData = NULL;
    anchorBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    anchor = world->CreateBody(&anchorBodyDef);
    //anchor->SetSleepingAllowed(false);
    
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
    // Create the car
    //===============================
    b2BodyDef carBodyDef;
    carBodyDef.type = b2_dynamicBody;
    carBodyDef.userData = self;
    carBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    carBody = world->CreateBody(&carBodyDef);
    
    b2PolygonShape carShape;
    carShape.SetAsBox(ssipadauto(30)/PTM_RATIO, ssipadauto(5)/PTM_RATIO);
    b2FixtureDef carFixtureDef;
    carFixtureDef.shape = &carShape;
    carFixtureDef.friction = 0;
#ifdef USE_CONSISTENT_PTM_RATIO
    carFixtureDef.density =  20.0f;
#else
    carFixtureDef.density =  20.0f/ssipad(4.0, 1);
#endif
    
    collideWithPlayer.categoryBits = CATEGORY_LOOP;
    collideWithPlayer.maskBits = CATEGORY_JUMPER | CATEGORY_FLOATING_PLATFORM;// | CATEGORY_LOOP_HAND;
    noCollideWithPlayer.categoryBits = 0;
    noCollideWithPlayer.maskBits = 0;
    
    carFixtureDef.filter.categoryBits = collideWithPlayer.categoryBits;
    carFixtureDef.filter.maskBits = collideWithPlayer.maskBits;
    carFixture = carBody->CreateFixture(&carFixtureDef);
    
    //===============================
    // Create the loop
    //===============================
    loopSprite = [CCSprite spriteWithSpriteFrameName:@"Wheel.png"];
    loopSprite.position = self.position;
    loopSprite.opacity = 0;
    [[GamePlayLayer sharedLayer] addChild:loopSprite z: 0];
    
    b2BodyDef loopBodyDef;
    loopBodyDef.type = b2_dynamicBody;
    //loopBodyDef.userData = self;
    loopBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    body = world->CreateBody(&loopBodyDef);
    
    // Create the Loop's hand fixture
    float width = ssipadauto(5)/PTM_RATIO;
    float height = radius/PTM_RATIO;
    
    b2PolygonShape shape;
    shape.SetAsBox(width, height, b2Vec2(0,0), 0);
    b2FixtureDef loopFixtureDef;
    loopFixtureDef.shape = &shape;
    loopFixtureDef.friction = 0.0f;
#ifdef USE_CONSISTENT_PTM_RATIO
    loopFixtureDef.density =  50.0f;
#else
    loopFixtureDef.density =  50.0f/ssipad(4.0, 1);
#endif
    
    //loopFixtureDef.filter.categoryBits = CATEGORY_LOOP_HAND; //collideWithPlayer.categoryBits;
    //loopFixtureDef.filter.maskBits = CATEGORY_LOOP;//collideWithPlayer.maskBits;
    loopFixture = body->CreateFixture(&loopFixtureDef);
    
    // create loop joint
    b2RevoluteJointDef revJointDef;
    revJointDef.bodyA = anchor;
    revJointDef.bodyB = body;
    revJointDef.collideConnected = false;
    
    // set the anchor for the body to be the bottom edge
    revJointDef.localAnchorA = b2Vec2(0,0);
    revJointDef.localAnchorB = b2Vec2(0,0);
    revJointDef.motorSpeed = 0;
    revJointDef.enableMotor = true;
    revJointDef.maxMotorTorque = 100000000;
    revJointDef.enableLimit = false;
    loopJoint = (b2RevoluteJoint *)world->CreateJoint(&revJointDef);
    
    playerJoint = nil;
}

- (void) destroyPhysicsObject {
    
    if (world != nil) {
        world->DestroyBody(anchor);
        world->DestroyBody(body);
        world->DestroyBody(carBody);
    }
}

- (void) updateObject:(ccTime)dt scale:(float)scale {
    
    // Hide if off screen and show if on screen. We should let each object control itself instead
    // of managing everything from GamePlayLayer. Convert to world coordinate first, and then compare.
    CGPoint gamePlayPosition = [[GamePlayLayer sharedLayer] getNode].position;
    
    CGPoint worldPos = ccp(normalizeToScreenCoord(gamePlayPosition.x, self.position.x, scale), 
                           normalizeToScreenCoord(gamePlayPosition.y, self.position.y, scale));
    
    CGRect box = [self boundingBox];
    if (loopSprite.visible) {
        if ((worldPos.x < -box.size.width || worldPos.x > screenSize.width)
            || (worldPos.y < -box.size.height || worldPos.y > screenSize.height)) 
        {
            [self hide];
        }
    } else if (!loopSprite.visible) { 
        if ((worldPos.x >= -box.size.width && worldPos.x <= screenSize.width)
            && (worldPos.y >= -box.size.height && worldPos.y <= screenSize.height))
        {
            [self show];
        }
    }
    
    if (!loopSprite.visible) {
        return;
    }
    
    if (state == kLoopPlayerLoaded) {
        [player loopingAnimation];
        CGPoint carPos = ccp(carBody->GetPosition().x * PTM_RATIO, carBody->GetPosition().y * PTM_RATIO);
        
        if (carPos.x >= self.position.x) {
            // Stop the car
            carBody->SetLinearVelocity(b2Vec2(0,0));
            // do the loop
            [self doLoop];
        }
        
        carBody->SetTransform(carBody->GetPosition(), 0);
    }
    else if (state == kLoopLooping) {
        [player loopingAnimation];
        float angle = CC_RADIANS_TO_DEGREES(body->GetAngle());
        
        //CCLOG(@"CURRENT LOOP ANGLE: %f", angle);
        player.state = kSwingerLooping;
        player.rotation = -angle;
        
        if (angle >= 360) {
            // drop player off
            state = kLoopNone;
            [self destroyCarJoint];
            loopJoint->SetMotorSpeed(0);
            state = kLoopFinished;
            // move car to the end
            carBody->SetTransform(carBody->GetPosition(), 0);
            carBody->SetLinearVelocity(b2Vec2(speed*carBody->GetMass(), 0));
        }
    } else if (state == kLoopFinished) {
        [player loopingAnimation];
        CGPoint carPos = ccp(carBody->GetPosition().x * PTM_RATIO, carBody->GetPosition().y * PTM_RATIO);

        if (carPos.x >= self.position.x + ssipadauto(150)) {
            // Stop the car
            carBody->SetLinearVelocity(b2Vec2(0,0));
            // keep a hold of the player reference before destroying the joint
            // unload player from car
            [self destroyPlayerJoint];
            
            if (player != nil) {
                b2Body * pBody = [player getPhysicsBody];
                //pBody->SetTransform(pBody->GetPosition(), 0);
                // stop players momentum, and bump him off the car
                pBody->SetLinearVelocity(b2Vec2(0,0));
                pBody->ApplyLinearImpulse(b2Vec2(9*pBody->GetMass(),9*pBody->GetMass()), pBody->GetPosition());
            
                player = nil;
                state = kLoopNone;
            }
        }
        
        carBody->SetTransform(carBody->GetPosition(), 0);
    } else {
        // return to waiting angle
        body->SetTransform(body->GetPosition(), 0);
        carBody->SetTransform(carBody->GetPosition(), 0);
    }
}

-(void) moveTo:(CGPoint)pos {
    self.position = pos;
    
    anchor->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0);
    body->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0);
    carBody->SetTransform(b2Vec2((pos.x - ssipadauto(300))/PTM_RATIO, (pos.y - radius)/PTM_RATIO), 0);
    
    loopSprite.position = ccp(pos.x, pos.y);
}

-(void) showAt:(CGPoint)pos {
    
    // Move the loop
    [self moveTo:pos];
    
    [self show];
}

- (void) show {
    
    loopSprite.visible = YES;
    anchor->SetActive(true);
    body->SetActive(true);
    carBody->SetActive(true);
}

- (void) hide {
    
    loopSprite.visible = NO;
    anchor->SetActive(false);
    body->SetActive(false);
    carBody->SetActive(false);
}

- (GameObjectType) gameObjectType {
    return kGameObjectLoop;
}

- (void) destroyCarJoint {
    
    if (carJoint != nil) {
        world->DestroyJoint(carJoint);
        carJoint = nil;
    }
}

- (void) destroyPlayerJoint {
    
    if (playerJoint != nil) {
        world->DestroyJoint(playerJoint);
        playerJoint = nil;
    }
}

- (void) createCarJoint {
    
    [self destroyCarJoint];
    
    // create a joint to hold car with the player in place as he loops
    b2WeldJointDef playerJointDef;
    playerJointDef.bodyA = body;
    playerJointDef.bodyB = carBody;
    playerJointDef.collideConnected = false;
    
    // set the anchor for the body to be the bottom edge
    playerJointDef.localAnchorA = b2Vec2(0,-((radius-ssipadauto(5))/PTM_RATIO));
    playerJointDef.localAnchorB = b2Vec2(0,0);
    carJoint = (b2WeldJoint *)world->CreateJoint(&playerJointDef);
}

- (void) createPlayerJoint {
    
    b2Body* pBody = [player getPhysicsBody];
    [self destroyPlayerJoint];
    
    // create a joint to hold player in place on the car
    b2WeldJointDef playerJointDef;
    playerJointDef.bodyA = carBody;
    playerJointDef.bodyB = pBody;
    playerJointDef.collideConnected = false;
    
    // set the anchor for the body to be the bottom edge
    playerJointDef.localAnchorA = b2Vec2(0, ssipadauto(20)/PTM_RATIO);
    playerJointDef.localAnchorB = b2Vec2(0,-(player.bodyHeight/2));
    playerJoint = (b2WeldJoint *)world->CreateJoint(&playerJointDef);
}

- (void) loop: (Player *) thePlayer {
    
    player = thePlayer;
    player.state = kSwingerLooping;
    [player loopingAnimation];
    state = kLoopPlayerLoaded;
    [self setCollideWithPlayer: NO];
    // create joint between player and car
    [self createPlayerJoint];
    // get the car moving forward
    carBody->SetLinearVelocity(b2Vec2(speed*carBody->GetMass(),0));
}

- (void) doLoop {
    // create joint, start revolute motor to 
    state = kLoopLooping;
    [self createCarJoint];
    loopJoint->SetMotorSpeed(speed*2*CC_DEGREES_TO_RADIANS(90)); // 90 degrees per second
}

- (void) setCollideWithPlayer:(BOOL)doCollide {
    if (doCollide) {
        carFixture->SetFilterData(collideWithPlayer);
    } else {
        carFixture->SetFilterData(noCollideWithPlayer);        
    }
}

- (void) reset {
    state = kLoopNone;
    [self moveTo: self.position];
    body->SetTransform(body->GetPosition(), 0);
    [self setCollideWithPlayer:YES];
}

- (void) dealloc {
    CCLOG(@"------------------------Deallocating Loop---------------------------");
    
    [super dealloc];
}

@end
