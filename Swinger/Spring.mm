//
//  Spring.m
//  Swinger
//
//  Created by Isonguyo Udoka on 6/7/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Spring.h"
#import "GamePlayLayer.h"
#import "Player.h"
#import "Wind.h"

@implementation Spring

@synthesize topSprite;
@synthesize springSprite;
@synthesize anchorSprite;
@synthesize bounceFactor;
@synthesize timeout;
@synthesize state;
@synthesize bounceRequested;

#define BOUNCE_OFF_SPRING 0

- (id) init {
	if ((self = [super init])) {
        screenSize = [CCDirector sharedDirector].winSize;
    }
    
    return self;
}


- (void) createPhysicsObject:(b2World*)theWorld {
    player = nil;
    world = theWorld;
    
    anchorSprite = [CCSprite spriteWithSpriteFrameName:@"SpringBottom.png"];
    anchorSprite.anchorPoint = ccp(0.5,0);
    anchorSprite.position = self.position;
    [[GamePlayLayer sharedLayer] addChild:anchorSprite z:1];
    
    b2BodyDef anchorDef;
    anchorDef.type = b2_staticBody;
    anchorDef.userData = NULL;
    anchorDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    anchor = world->CreateBody(&anchorDef);
    
    b2PolygonShape anchorShape;
    anchorShape.SetAsBox([anchorSprite boundingBox].size.width/2/PTM_RATIO, [anchorSprite boundingBox].size.height/2/PTM_RATIO);
    b2FixtureDef anchorFixture;
    anchorFixture.shape = &anchorShape;
    anchorFixture.density = 10.0f;
    anchorFixture.filter.categoryBits = CATEGORY_ANCHOR;
    anchorFixture.filter.maskBits = 0;
    anchor->CreateFixture(&anchorFixture);
    
    //==========================================
    // Create the top platform of the spring
    //==========================================
    topSprite = [CCSprite spriteWithSpriteFrameName:@"SpringTop.png"];
    topSprite.anchorPoint = ccp(0.5,0);
    topSprite.position = self.position;
    [[GamePlayLayer sharedLayer] addChild:topSprite z:1];
    
    b2BodyDef topBodyDef;
    topBodyDef.type = b2_dynamicBody;
    topBodyDef.userData = self;
    topBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    body = world->CreateBody(&topBodyDef);
    
    collideWithPlayer.categoryBits = CATEGORY_SPRING;
    collideWithPlayer.maskBits = CATEGORY_JUMPER;
    noCollideWithPlayer.categoryBits = 0;
    noCollideWithPlayer.maskBits = 0;
    
    b2PolygonShape topShape;
    topShape.SetAsBox((([topSprite boundingBox].size.width/2) - 3)/PTM_RATIO, (([topSprite boundingBox].size.height/2) - 3)/PTM_RATIO);
    b2FixtureDef topFixtureDef;
    topFixtureDef.shape = &topShape;
#ifdef USE_CONSISTENT_PTM_RATIO
    topFixtureDef.density = 4.f;
#else
    topFixtureDef.density = ssipad(2.f, 4.f);    
#endif
    topFixtureDef.filter.categoryBits = collideWithPlayer.categoryBits;
    topFixtureDef.filter.maskBits = collideWithPlayer.maskBits;    
    topFixture = body->CreateFixture(&topFixtureDef);
    
    [self createSpring];
    
    //============================
    // Spring sprite
    //============================
    springSprite = [CCSprite spriteWithSpriteFrameName:@"SpringMiddle.png"];
    springSprite.anchorPoint = ccp(0.5,1);
    springSprite.position = self.position;
    [self updateSpringScale];
    [[GamePlayLayer sharedLayer] addChild: springSprite z:0];
    
    state = kSpringNone;
}

- (void) createSpring {
    bounceRequested = NO; // clear state
    if(springJoint != NULL) {
        return;
    }
    
    float lowerLimit = ssipad(-0.1f,-0.1f);
#ifdef USE_CONSISTENT_PTM_RATIO
    float upperLimit = 3;
#else
    float upperLimit = ssipad(6,3);
#endif
    
    springSprite.scale = 1;
    body->SetTransform(b2Vec2(self.position.x/PTM_RATIO, (self.position.y/PTM_RATIO)/* + upperLimit*/),0);
    
    //============================================================
    // create a prismatic joint with a motor to simulate a spring
    //============================================================
    b2PrismaticJointDef prismJointDef;
    prismJointDef.Initialize(anchor, body, b2Vec2(0,0), b2Vec2(0,1));
    prismJointDef.collideConnected = false;
    prismJointDef.lowerTranslation = lowerLimit;
    prismJointDef.upperTranslation = upperLimit;
    prismJointDef.enableLimit = true;
    prismJointDef.maxMotorForce = 500*bounceFactor;
    prismJointDef.motorSpeed = 200/bounceFactor;
    prismJointDef.enableMotor = true;
    springJoint = (b2PrismaticJoint *)world->CreateJoint(&prismJointDef);
}

- (void) reset {
    [self createSpring];
    [self setCollideWithPlayer:YES];
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
    
    float radius = 75;
    double angle = CC_DEGREES_TO_RADIANS(angleDegs);
    b2Vec2 origin = b2Vec2(body->GetPosition().x, body->GetPosition().y);
    float x0 = origin.x + (((radius + ssipad(0,0))/PTM_RATIO) * cosf(angle)) + 20/PTM_RATIO; // starting x position in meters
    float y0 = origin.y + (((radius + [springSprite boundingBox].size.height + ssipadauto(125))/PTM_RATIO) * sinf(angle)) + 20/PTM_RATIO; // starting y position in meters
    float v01 = bounceFactor + 5 + windForce.x; // initial x velocity in meters/sec + small buffer + wind force
    float v02 = bounceFactor + 5 + windForce.y; // initial y velocity in meters/sec + small buffer + wind force
    
    float g = fabsf(world->GetGravity().y);// + 5; // gravity in meters/sec + a small buffer
    
    float v0x = v01*cos(angle);
    float v0y = v02*sin(angle);
    
    float range = ((2*(v0x*v0y))/g) + 2; // range of the cannon in meters + buffer since player position is above the ground
    
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

- (void) updateSpringScale {
    springSprite.scale = 1;
    float springHeight = topSprite.position.y - anchorSprite.position.y - [anchorSprite boundingBox].size.height + ssipad(14,7); // height in pixels
    float springScale = fabsf(springHeight/[springSprite boundingBox].size.height);
    //CCLOG(@"Spring Distance: %f Spring Height: %f Spring Scale: %f", springHeight, [springSprite boundingBox].size.height, springScale);
    
    if(springScale != springSprite.scaleY) {
        springSprite.scaleY = springScale;
    }
}

- (void) updateObject:(ccTime)dt scale:(float)scale {
    
    // Hide if off screen and show if on screen. We should let each object control itself instead
    // of managing everything from GamePlayLayer. Convert to world coordinate first, and then compare.
    CGPoint gamePlayPosition = [[GamePlayLayer sharedLayer] getNode].position;
    
    CGPoint worldPos = ccp(normalizeToScreenCoord(gamePlayPosition.x, (body->GetPosition().x * PTM_RATIO), scale), 
                           gamePlayPosition.y + (body->GetPosition().y * PTM_RATIO));
    if (player == NULL && topSprite.visible && (worldPos.x < -([topSprite boundingBox].size.width) || worldPos.x > screenSize.width)) {
        [self hide];
    } else if (!topSprite.visible && worldPos.x >= -([topSprite boundingBox].size.width) && worldPos.x <= screenSize.width) {
        [self show];
    }
    
    //if (!topSprite.visible)
    //    return;
    
    if(springJoint != NULL) {
        //float force = 5000 * springJoint->GetJointTranslation() / (springJoint->GetUpperLimit() - springJoint->GetLowerLimit());
        //springJoint->SetMaxMotorForce(force);
        springJoint->SetMotorSpeed(ssipad(400, 200)); // expand the spring up
        
        if(state == kSpringLoaded) { // make the joint springy
            [self doSpring];
            
            float max = ssipad(10,20);
            float springy = ssipad(2, 1) * bounceFactor/2;
            
            if(springy > max) {
                springy = max;
            }
            
            if(springCount > springy) { // increase this max to slow the spring effect down
                springCount = 0;
                
                if(bounceRequested) {
                    //[self bouncePlayer];
                } else {
                    state = kSpringNone;
                    springJoint->SetMaxMotorForce(500*bounceFactor);
                }
            }
            springCount++;        
        }
        
        [self scaleTrajectoryPoints: scale];
    }
    
    topSprite.position = ccp((body->GetPosition().x * PTM_RATIO), (body->GetPosition().y * PTM_RATIO) - [topSprite boundingBox].size.height/2);
    anchorSprite.position = ccp((anchor->GetPosition().x * PTM_RATIO), (anchor->GetPosition().y * PTM_RATIO) - [anchorSprite boundingBox].size.height/2);
    springSprite.position = ccp(topSprite.position.x, topSprite.position.y + 2);
    
    [self updateSpringScale];
}

-(void) doSpring {
    // Spring translation based on the given speed/bounce factor of the spring
    float force = fabsf((springJoint->GetJointTranslation()) + ssipad(1,2) * (springJoint->GetMotorSpeed()));
    springJoint->SetMaxMotorForce(force);
    float speed = springJoint->GetMotorSpeed() - ssipad(100,50);
    springJoint->SetMotorSpeed(springJoint->GetJointTranslation() > 0 ? -speed : speed); // Arbitrary humongous number.
}

-(void) moveTo:(CGPoint)pos {
    self.position = pos;
    
    topSprite.position = pos;
    anchorSprite.position = pos;
    springSprite.position = pos;
    
    body->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0);
    anchor->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0);
}

-(void) showAt:(CGPoint)pos {
    // Move the spring
    [self moveTo:pos];
    
    [self show];
}

- (GameObjectType) gameObjectType {
    return kGameObjectSpring;
}

- (void) fallApart {
    // destroys the joint and spring should fall apart
    if (world != NULL) {
        world->DestroyJoint(springJoint);
        
        float impulse = ssipad(1, 1) * bounceFactor*body->GetMass();
        
        if(impulse < ssipad(80,40)) {
            impulse = 40;
        } else if(impulse > ssipad(100, 50)) {
            impulse = 50;
        }
        
        //CCLOG(@"SPRING FORCE: %f", yVel);
        body->ApplyLinearImpulse(b2Vec2(-impulse,impulse), b2Vec2(-([topSprite boundingBox].size.height * PTM_RATIO), [topSprite boundingBox].size.width * PTM_RATIO));
        springJoint = NULL;
        state = kSpringFellApart;
        bounceRequested = NO;
        player = nil;
        [self showTrajectory: NO];
    }
}

- (void) hide {
    [anchorSprite setVisible:NO];
    [topSprite setVisible:NO];
    [springSprite setVisible:NO];
    
    [self showTrajectory: NO];
    
    body->SetActive(NO);
    anchor->SetActive(NO);
}

- (void) show {
    [anchorSprite setVisible:YES];
    [topSprite setVisible:YES];
    [springSprite setVisible:YES];
    
    /*if (player != NULL) {
        [self showTrajectory: YES];
    } else {
        [self showTrajectory: NO];
    }*/
    
    body->SetActive(YES);
    anchor->SetActive(YES);
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
        
        if (springJoint != NULL) {
            world->DestroyJoint(springJoint);
        }
        
        world->DestroyBody(anchor);
        world->DestroyBody(body);
    }
}

- (void) dealloc {
    // DO NOT DESTROY PHYSICS OBJECTS HERE!
    // SOMETHING WILL CALL destroyPhysicsObject
    
    [anchorSprite removeFromParentAndCleanup:YES];
    [topSprite removeFromParentAndCleanup:YES];
    [springSprite removeFromParentAndCleanup:YES];
    
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

#pragma mark - CatcherGameObject protocol
- (void) setCollideWithPlayer:(BOOL)doCollide {
    if (doCollide) {
        topFixture->SetFilterData(collideWithPlayer);
    } else {
        topFixture->SetFilterData(noCollideWithPlayer);        
    }
}

- (CGPoint) getCatchPoint {
    return ccp(0,0);
}

- (float) getHeight {
    return (topSprite.position.y + [topSprite boundingBox].size.height) + (bounceFactor*ssipadauto(15));
}

- (void) bounce {
    
    if (BOUNCE_OFF_SPRING == 1) {
        bounceRequested = YES; // this waits till next contact with the spring to bounce player
    } else {
        bounceRequested = NO;
        [self bouncePlayer]; // uncomment this to make player bounce off even if he's not contacting the spring
    }
}

- (void) unloadPlayer {
    player = nil;
    [self showTrajectory:NO];
}

- (void) catchPlayer: (Player *) thePlayer {
    player = thePlayer;
    //b2Body * pBody = [player getPhysicsBody];
    state = kSpringLoaded;
    
    //===========================================
    // Canceling out the players velocity to
    // make the player bounce up and down until
    // the user taps the screen
    //===========================================
    /*CGPoint pos = topSprite.position;
    
    pBody->SetLinearVelocity(b2Vec2(0,0));
    pBody->SetTransform(b2Vec2(pos.x/PTM_RATIO, (pos.y + [topSprite boundingBox].size.height + 30)/PTM_RATIO), 0);
    
    float minBounce = ssipad(1,1) * PTM_RATIO;
    float maxBounce = ssipad(3,3) * PTM_RATIO;
    float bounceY = ssipad(bounceFactor, bounceFactor/2)*3;//ssipadauto(4);
    float bounceX = 0;
    
    if(bounceY < minBounce) {
        bounceY = minBounce;
    } else if(bounceY > maxBounce) {
        bounceY = maxBounce;
    }
    
    if(bounceRequested) {
        // bounce the player forwards
        [self bouncePlayer];
    } else {
        
        [self showTrajectory: YES];
        [player bouncingAnimation : ssipad(1,1) * .020f*bounceFactor];
        pBody->ApplyLinearImpulse(b2Vec2(bounceX,ssipad(0.5,1)*bounceY), pBody->GetWorldCenter());
    }*/
}

- (void) bouncePlayer {
    if(player != nil) {
        b2Body * pBody = [player getPhysicsBody];
        
        float impulseMag = /*pBody->GetMass() */ bounceFactor;
        float x = impulseMag/2;
        float y = impulseMag;
        
        player.state = kSwingerOnSpring;
        // Bounce the player
        //[player jumpingAnimation];
        [player flyingAnimation:0.f];
        
        //pBody->SetLinearVelocity(b2Vec2(0,0));
        //pBody->ApplyLinearImpulse(b2Vec2(x, y), pBody->GetWorldCenter());
        pBody->SetLinearVelocity(b2Vec2(x,y));
        bounceRequested = NO;
        state = kSpringNone;
        [self showTrajectory: NO];
    }
}

- (void) setSwingerVisible:(BOOL)visible {
}

@end
