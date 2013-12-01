//
//  Elephant.m
//  Swinger
//
//  Created by James Sandoz on 6/19/2012.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Elephant.h"

#import "CCHeadBodyAnimate.h"
#import "CCHeadBodyAnimation.h"
#import "Constants.h"
#import "GamePlayLayer.h"
#import "Player.h"


// This is the walk velocity (from the level plist) at which the animation should be run 
// at 1.0 speed
#define BASE_WALK_VELOCITY 5


@interface Elephant(Private)
- (void) turnLeft;
- (void) turnRight;
@end


@implementation Elephant

@synthesize leftPos;
@synthesize rightPos;
@synthesize walkVelocity;
@synthesize timeout;


- (id) init {
	if ((self = [super init])) {
        screenSize = [[CCDirector sharedDirector] winSize];
        scrollBufferZone = screenSize.width/5;
        
        // create the sprite
        elephantSprite = [CCSprite spriteWithSpriteFrameName:@"ElephantWalk1.png"];
        [self addChild:elephantSprite];
        [self walkingAnimation];
    }
    
    return self;
}


- (void) createPhysicsObject:(b2World*)theWorld {
    
    world = theWorld;
    
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.fixedRotation = true;
    bodyDef.userData = self;
    body = theWorld->CreateBody(&bodyDef);
	
    b2PolygonShape shape;
    float elephantHeight = .95*elephantSprite.contentSize.height*self.scale/PTM_RATIO;
    playerCatchHeight = elephantHeight + [[GamePlayLayer sharedLayer] getPlayer].bodyHeight/2 + ssipadauto(1)/PTM_RATIO;
    shape.SetAsBox(.6*elephantSprite.contentSize.width*self.scale/PTM_RATIO/2, elephantHeight/2, b2Vec2(0, 0), 0);
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
#ifdef USE_CONSISTENT_PTM_RATIO
    fixtureDef.density = 5.f;
#else
    fixtureDef.density = 5.f/ssipad(4.f, 1.f);
#endif
    fixtureDef.friction = 0;
    
    collideWithPlayer.categoryBits = CATEGORY_LOOP;
    collideWithPlayer.maskBits = CATEGORY_JUMPER | CATEGORY_GROUND | CATEGORY_FINAL_PLATFORM;
    noCollideWithPlayer.categoryBits = 0;
    noCollideWithPlayer.maskBits = CATEGORY_GROUND | CATEGORY_FINAL_PLATFORM;
    
    fixtureDef.filter.categoryBits = collideWithPlayer.categoryBits;
    fixtureDef.filter.maskBits = collideWithPlayer.maskBits;
    fixture = body->CreateFixture(&fixtureDef);
}


- (void) walkingAnimation {
    if (state != kElephantStateWalking) {
        state = kElephantStateWalking;
        [elephantSprite stopAllActions];
        
        id action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"elephantWalkAnimation"] restoreOriginalFrame:NO];
        id walkingAction = [CCRepeatForever actionWithAction:action];
        walkSpeedAction = [CCSpeed actionWithAction:walkingAction speed:1.0f];
        [elephantSprite runAction:walkSpeedAction];   
    }
}

- (void) buckingAnimation {
    if (state != kElephantStateBucking) {
        state = kElephantStateBucking;
        [elephantSprite stopAllActions];
        
        id action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"elephantBuckAnimation"] restoreOriginalFrame:NO];
        id buckingAction = [CCRepeatForever actionWithAction:action];
        [elephantSprite runAction:buckingAction];   
    }
}

- (void) jump {
    if (playerJoint != NULL) {
        b2Body * pBody = [player getPhysicsBody];
        world->DestroyJoint(playerJoint);
        playerJoint = NULL;
        player = nil;
        
        pBody->SetActive(YES);
        // jump backwards if player is flipped
        float xForce = 10*pBody->GetMass() * (playerFlipped?-1:1);
        float yForce = 15*pBody->GetMass();
        pBody->ApplyLinearImpulse(b2Vec2(xForce, yForce), pBody->GetWorldCenter());
    }
}

- (void) buck {
    world->DestroyJoint(playerJoint);
    playerJoint = NULL;
    player = nil;
    
    [self buckingAnimation];
    body->SetActive(NO);
}

- (void) reset {
    if (playerJoint != NULL)
        world->DestroyJoint(playerJoint);
    playerJoint = NULL;
    player = nil;
    
    [self walkingAnimation];
    [self showAt:ccp(leftPos-1, self.position.y)];////body->GetPosition().y/PTM_RATIO)];
    
    [self setCollideWithPlayer:YES];
}

- (void) createPlayerJoint {
    b2Body *pBody = [player getPhysicsBody];
    b2WeldJointDef playerJointDef;
    playerJointDef.Initialize(body, pBody, body->GetWorldCenter());
    playerJointDef.collideConnected = NO;
    playerJointDef.bodyA = body;
    playerJointDef.bodyB = pBody;
    
    playerJoint = world->CreateJoint(&playerJointDef);
}

- (void) load:(Player *)thePlayer {
    NSAssert(thePlayer != NULL, @"Player should not be NULL!");
    
    player = thePlayer;
    
    // move the player to the center of the elephant
    b2Body *pBody = [player getPhysicsBody];
//    CCLOG(@"Elephant.load, player y=%f(%f), elephant y=%f(%f), playerCatchHeight=%f(%f)\n", pBody->GetPosition().y, pBody->GetPosition().y*PTM_RATIO, body->GetPosition().y, body->GetPosition().y*PTM_RATIO, playerCatchHeight, playerCatchHeight*PTM_RATIO);
    pBody->SetTransform(b2Vec2(body->GetPosition().x, /*self.position.y/PTM_RATIO/2*/ + playerCatchHeight), 0);
    
    // determine the offset from the middle of the elephant so we can move the player
    // around
    [self createPlayerJoint];
    
    // elephant sprite faces left by default, so player is facing backwards when
    // elephantSprite.flipX is false
    playerFlipped = !elephantSprite.flipX;
    [player balancingAnimation:playerFlipped];
}

- (void) flipPlayer {
    
    // set the state to none so balancingAnimation will stop the current animation and
    // reinitialize with the correct flipX value
    player.state = kSwingerNone;
    [player balancingAnimation:!player.flipX];

//    CCLOG(@"Elephant.flipPlayer, playerFlipped=%d\n", playerFlipped);
    
    // move the player to flip with the elephant around its vertical axis
    world->DestroyJoint(playerJoint);
    
    b2Body *pBody = [player getPhysicsBody];
    pBody->SetTransform(b2Vec2(body->GetPosition().x, /*self.position.y/PTM_RATIO/2*/ + playerCatchHeight), 0);

    playerFlipped = !playerFlipped;
    [self createPlayerJoint];
}

- (void) turnLeft {
    CCLOG(@"  in turnLeft.  self.pos=(%f,%f), rightPos=%f, velocity=(%f,%f)\n", self.position.x, self.position.y, rightPos, body->GetLinearVelocity().x, body->GetLinearVelocity().y);
    elephantSprite.flipX = NO;
    
    // move the player
//    Player *player = [[GamePlayLayer sharedLayer] getPlayer];
//    float playerDelta = player.position.x - self.position.x;
//    
//    [player moveTo:ccp(player.position.x, player.position.y + playerDelta)];
    
    body->SetLinearVelocity(b2Vec2(-walkVelocity, 0));
    
    // flip the player if  one has landed on us
    if (player != nil)
        [self flipPlayer];
}

- (void) turnRight {
    
    CCLOG(@"  in turnRight.  self.pos.x=%f, leftPos=%f, velocity=(%f,%f)\n", self.position.x, leftPos, body->GetLinearVelocity().x, body->GetLinearVelocity().y);
    
    elephantSprite.flipX = YES;
    body->SetLinearVelocity(b2Vec2(walkVelocity, 0));
    
    // flip the player if one has landed on us
    if (player != nil)
        [self flipPlayer];
}


- (GameObjectType) gameObjectType {
    return kGameObjectElephant;
}

- (void) updateObject:(ccTime)dt scale:(float)scale {
    
//    CCLOG(@"elephant.update: visible=%d, active=%d, state=%d, pos=%f,%f, leftPos=%f, rightPos=%f, velocity=(%f,%f)\n", self.visible, body->IsActive(), state, self.position.x, self.position.y, leftPos, rightPos, body->GetLinearVelocity().x, body->GetLinearVelocity().y);
    
    float yOffset = 0;//ssipadauto(5);
    if (state == kElephantStateBucking) {
        yOffset = ssipadauto(20);
    }
    self.position = CGPointMake( body->GetPosition().x * PTM_RATIO, (body->GetPosition().y * PTM_RATIO) + yOffset);
    self.rotation = -1 * CC_RADIANS_TO_DEGREES(body->GetAngle());
    
    if (state == kElephantStateWalking) {
        if (justTurned == 0) {
            if (self.position.x <= leftPos) {
                justTurned = 1;
                [self turnRight];
            } else if (self.position.x >= rightPos) {
                justTurned = 1;
                [self turnLeft];
            }
        } else if (++justTurned >= 5) {
            justTurned = 0;
        }
    }
   
    // Hide if off screen and show if on screen. We should let each object control itself instead
    // of managing everything from GamePlayLayer. Convert to world coordinate first, and then compare.
    CGPoint gamePlayPosition = [[GamePlayLayer sharedLayer] getNode].position;
    CGPoint worldPos = ccp(normalizeToScreenCoord(gamePlayPosition.x, (body->GetPosition().x * PTM_RATIO) - [elephantSprite boundingBox].size.width/2, scale), 
                           gamePlayPosition.y + (body->GetPosition().y * PTM_RATIO));
    if (elephantSprite.visible && player == NULL && 
        (worldPos.x < -([elephantSprite boundingBox].size.width) || 
         worldPos.x > screenSize.width)) {
            
        [self hide];
    } else if (!elephantSprite.visible && 
               worldPos.x >= -([elephantSprite boundingBox].size.width) && 
               worldPos.x <= screenSize.width) {
        [self show];
    }
}

// Set the distance to the next catcher based on the left boundary of the elephant path
- (float) distanceToNextCatcher {
    CCNode<GameObject> *nextObject = [self getNextCatcherGameObject];
    float distanceToNextCatcher = nextObject.position.x - leftPos; 
    return distanceToNextCatcher;
}

- (void) setSwingerVisible:(BOOL)visible {
    
}

- (void) hide {
    CCLOG(@"Elephant.hide()\n");
    [elephantSprite setVisible:NO];
    
    // don't make the body inactive, we have to keep moving it while offscreen
//    body->SetActive(NO);
}

- (void) show {
    CCLOG(@"Elephant.show()\n");
    [elephantSprite setVisible:YES];
    
    body->SetActive(YES);
}



- (void) setCollideWithPlayer:(BOOL)doCollide {
    if (doCollide) {
        fixture->SetFilterData(collideWithPlayer);
    } else {
        fixture->SetFilterData(noCollideWithPlayer);        
    }
}


- (CGPoint) getCatchPoint {
    
    return ccp(self.position.x, /*self.position.y/2*/ + playerCatchHeight*PTM_RATIO);
    
//    // use the player's x position and our y position
//    float x = player.position.x;
//    if (x < self.position.x - [elephantSprite boundingBox].size.width/2) {
//        x = self.position.x - [elephantSprite boundingBox].size.width/2 + [player boundingBox].size.width/2;
//    } else if (x > self.position.x + [elephantSprite boundingBox].size.width/2) {
//        x = self.position.x + [elephantSprite boundingBox].size.width/2 - [player boundingBox].size.width/2;
//    }
//    return ccp(x, [self getHeight]);
}


- (float) getHeight {
    CCLOG(@"  elephant.getHeight.  self.position.y=%f, bounding box height=%f, ret=%f\n", self.position.y, [elephantSprite boundingBox].size.height, self.position.y + [elephantSprite boundingBox].size.height);
    return self.position.y + [elephantSprite boundingBox].size.height/2 + [[[GamePlayLayer sharedLayer] getPlayer] boundingBox].size.height/2;
}

- (void) setWalkVelocity:(float)theWalkVelocity {
    walkVelocity = theWalkVelocity;
    
    float actionSpeed = walkVelocity/BASE_WALK_VELOCITY;
    CCLOG(@"\n\n\n###  Elephant.setWalkVelocity, actionSpeed=%f, walkVelocity=%f  ###\n\n\n", actionSpeed, walkVelocity);
    walkSpeedAction.speed = actionSpeed;
}

- (void) dealloc {
    CCLOG(@"-------------------------- Elephant being deallocated");
    [super dealloc];
}

@end
