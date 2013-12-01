//
//  StrongMan.m
//  Swinger
//
//  Created by Isonguyo Udoka on 7/4/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "StrongMan.h"
#import "GamePlayLayer.h"
#import "GPUtil.h"

@implementation StrongMan

@synthesize gameObjectId;

- (id) init {
	if ((self = [super init])) {
        
        screenSize = [CCDirector sharedDirector].winSize;
        finalPosition = ccp(0,0);
        animationsLoaded = NO;
        [self initStrongMan];
    }
    
    return self;
}

- (void) setupAnimations {
    
    if (animationsLoaded) {
        return;
    }
    
    trailNode = [CCNode node];
    [self addChild: trailNode z: -1];
    
    for (int i = 0; i < 4; i++) {
        NSString *file = [NSString stringWithFormat:@"StrongmanJump.png"];
        
        CCSprite *jumpTrailFrame = [CCSprite spriteWithSpriteFrameName:file];
        jumpTrailFrame.opacity = 0;
        //[[GamePlayLayer sharedLayer] addChild:jumpTrailFrame z:3];
        [trailNode addChild: jumpTrailFrame];
        jumpTrailFrames[i] = jumpTrailFrame;
    }
    
    for (int i = 0; i < 4; i++) {
        NSString *file = [NSString stringWithFormat:@"StrongmanSmash.png"];
        
        CCSprite *smashTrailFrame = [CCSprite spriteWithSpriteFrameName:file];
        smashTrailFrame.opacity = 0;
        //[[GamePlayLayer sharedLayer] addChild:smashTrailFrame z:3];
        [trailNode addChild: smashTrailFrame];
        smashTrailFrames[i] = smashTrailFrame;
    }
    
    animationsLoaded = YES;
}

- (void) initStrongMan {
    
    state = kStrongManNone;
    started = NO;
    jumpPosX = (arc4random() % ((int)screenSize.width/2)) + ssipadauto(200);
    
    /*if (jumpPosX < 0) {
        jumpPosX = 100;
    }*/
    
    jumpPosX += finalPosition.x;
    runSpeed = 5;
    jumpForce = 5;
    numJumps = [GPUtil randomFrom:5 to:10] + 1;
    maxJumpHeight = screenSize.height/4;
    currentJumpCount = 0;
    jumpDelta = 0;
    jumpCount = 0;
    
    [self hide];
}

- (void) reset {
    [self initStrongMan];
}

- (void) runningAnimation {
    
    [self stopAnimation];
    CCAnimate *running = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"strongmanRunAnimation"] restoreOriginalFrame:NO];
    currentAnim = [CCRepeatForever actionWithAction:running];
    [strongMan runAction:currentAnim];
}

- (void) standingAnimation {
    
    [self stopAnimation];
    CCAnimate *standing = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"strongmanStandAnimation"] restoreOriginalFrame:NO];
    currentAnim = [CCRepeatForever actionWithAction:standing];
    [strongMan runAction:currentAnim];
}

- (void) jumpingAnimation {
    [self stopAnimation];
    CCAnimate *jumping = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"strongmanJumpAnimation"] restoreOriginalFrame:NO];
    currentAnim = [CCRepeatForever actionWithAction:jumping];
    [strongMan runAction:currentAnim];
}

- (void) smashingAnimation {
    [self stopAnimation];
    CCAnimate *smashing = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"strongmanSmashAnimation"] restoreOriginalFrame:NO];
    currentAnim = [CCRepeatForever actionWithAction:smashing];
    [strongMan runAction:currentAnim];
}

- (void) stopAnimation {
    
    if (currentAnim != nil) {
        [self stopAction: currentAnim];
        currentAnim = nil;
    }
}

- (void) begin {
    
    if (state == kStrongManNone) {
        // moved this here to after I have added myself to the gameplay layer, so I can be deallocated properly - hack but works for now
        [self setupAnimations];
        
        started = YES;
    }
}

- (void) run {
    
    if (state != kStrongManRunning) {
        
        state = kStrongManRunning;
        //self.visible = YES;
        [self show];
        [self runningAnimation];
        body->SetLinearVelocity(b2Vec2(-runSpeed,0));
    }
}

- (void) stand {
    
    if (state != kStrongManStanding) {
        
        state = kStrongManStanding;
        dtSum = 0; // determines how long he will stand
        [self standingAnimation];
        body->SetLinearVelocity(b2Vec2(0,0));
    }
}

- (void) jump {
    
    if (state != kStrongManJumping) {
        
        state = kStrongManJumping;
        [self jumpingAnimation];
        jumpDelta = 0;
        jumpCount = 0;
        currentJumpHeight = 0;
        currentJumpCount++;
        body->SetLinearVelocity(b2Vec2(0, jumpForce));
    }
}

- (void) smash {
    
    if (state != kStrongManSmashing) {
        
        state = kStrongManSmashing;
        jumpDelta = 0;
        jumpCount = 0;
        [self smashingAnimation];
        body->SetLinearVelocity(b2Vec2(0, -jumpForce));
    }
}

- (void) stop {
    
    if (state != kStrongManDone) {
        state = kStrongManDone;
        [self standingAnimation];
        body->SetLinearVelocity(b2Vec2(0,0));
    }
}

- (void) showAt:(CGPoint)pos {
    //self.position = pos;
    finalPosition = pos;
    
    self.position = ccp(finalPosition.x + screenSize.width + [strongMan boundingBox].size.width/2, finalPosition.y);
    jumpPosX += finalPosition.x;
}

#pragma mark - PhysicsObject protocol
- (void) createPhysicsObject:(b2World *)theWorld {
    world = theWorld;
    
    strongMan = [CCSprite spriteWithSpriteFrameName:@"StrongmanStand1.png"];
    self.visible = NO;
    [self addChild: strongMan];
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_kinematicBody;
    bodyDef.position.Set(0,0);
    bodyDef.userData = self;
    body = world->CreateBody(&bodyDef);
    
    b2PolygonShape shape;
    shape.SetAsBox([strongMan boundingBox].size.width/2/PTM_RATIO, [strongMan boundingBox].size.height/2/PTM_RATIO);
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
    fixtureDef.density = 1.f;
    fixtureDef.friction = 5.3f;
    fixtureDef.isSensor = YES;
    //fixtureDef.filter.categoryBits = CATEGORY_STRONGMAN;
    //fixtureDef.filter.maskBits = CATEGORY_ANCHOR;
    body->CreateFixture(&fixtureDef);
}

- (void) destroyPhysicsObject {
    if (world != NULL) {
        world->DestroyBody(body);
    }
}

- (b2Body*) getPhysicsBody {
    return body;
}

- (b2Vec2) previousPosition {
    return previousPosition;
}

- (b2Vec2) smoothedPosition {
    return smoothedPosition;
}

- (void) setPreviousPosition:(b2Vec2)p {
    previousPosition = p;
}

- (void) setSmoothedPosition:(b2Vec2)p {
    smoothedPosition = p;
}

- (float) previousAngle {
    return previousAngle;
}

- (float) smoothedAngle {
    return smoothedAngle;
}

- (void) setPreviousAngle:(float)a {
    previousAngle = a;
}

- (void) setSmoothedAngle:(float)a {
    smoothedAngle = a;
}

#pragma mark - GameObject protocol
- (GameObjectType) gameObjectType {
    return kGameObjectStrongMan;
}

- (void) updateObject:(ccTime)dt scale:(float)scale {
    
    if (!started) {
        [self hide];
        body->SetActive(false);
        return;
    } else {
        if (!body->IsActive()) {
            body->SetActive(true);
        }
    }
    
    CGPoint gamePlayPosition = [[GamePlayLayer sharedLayer] getNode].position;
    
    // Hide/show based on whether its on screen or not
    CGPoint worldPos = ccp(normalizeToScreenCoord(gamePlayPosition.x, (body->GetPosition().x * PTM_RATIO), scale), 
                           gamePlayPosition.y + (body->GetPosition().y * PTM_RATIO));
    if (worldPos.x < -([strongMan boundingBox].size.width) || worldPos.x > screenSize.width) {
        if (self.visible) {
            [self hide];
        }
    } else if (worldPos.x >= -([strongMan boundingBox].size.width) && worldPos.x <= screenSize.width) {
        if (!self.visible) {
            [self show];
        }
    }
    
    if (state != kStrongManDone) {
    
        CGPoint bodyPos = ccp(body->GetPosition().x * PTM_RATIO, body->GetPosition().y * PTM_RATIO);
        float groundHeight = finalPosition.y;
        
        if (state == kStrongManNone) {
            // start him off to the right of the screen
            
            bodyPos = ccp(finalPosition.x + (screenSize.width/scale) + [strongMan boundingBox].size.width/2, groundHeight + [strongMan boundingBox].size.height/2);
            body->SetTransform(b2Vec2(bodyPos.x/PTM_RATIO, bodyPos.y/PTM_RATIO), 0);
            float buffer = 20.f;
            
            if (started && (fabsf(gamePlayPosition.x) + buffer >= finalPosition.x )) {
                startingPosX = bodyPos.x;
                [self run];
            }
        } else {
            //
            
            if (currentJumpCount > numJumps) {
                [self run]; // run off to your final position
            }
            else {
                if (state == kStrongManRunning) {
                    
                    if (bodyPos.x <= jumpPosX) {
                        [self stand];
                    }
                } else if (state == kStrongManStanding) {
                    
                    if (dtSum > 0.1f) {
                        [self jump];
                    }
                } else if (state == kStrongManJumping) {
                    jumpDelta += dt;
                    currentJumpHeight = bodyPos.y;
                    
                    [self showTrailFrames: jumpTrailFrames direction: YES];
                    
                    if (currentJumpHeight >= maxJumpHeight) {
                        // on his way down, do smash
                        [self smash];
                    }
                    
                } else if (state == kStrongManSmashing) {
                    jumpDelta += dt;
                    
                    [self showTrailFrames: smashTrailFrames direction: NO];
                    
                    if (bodyPos.y <= groundHeight + [strongMan boundingBox].size.height/2) {
                        bodyPos = ccp(bodyPos.x, groundHeight + [strongMan boundingBox].size.height/2);
                        [[GamePlayLayer sharedLayer] shake: 0.55f];
                        [self stand];
                    }
                }
            }
        }
        
        self.position = bodyPos;
        dtSum += dt;
        
        if (bodyPos.x <= finalPosition.x) {
            [self stop];
        }
    }
}

- (void) showTrailFrames: (CCSprite *[]) frames direction:(BOOL)up {
    
    if (jumpCount < 4 && (jumpCount == 0 || jumpDelta >= 0.05)) {
        jumpDelta = 0;
        CCSprite *jumpFrame = frames[jumpCount++];
        
        //jumpFrame.position = self.position;
        //trailNode.position = self.position;
        jumpFrame.position = ccp(0, (up ? 1:-1)*(4-jumpCount)*ssipadauto(10));
        jumpFrame.opacity = 150;
        
        CCFadeOut *fadeOut = [CCFadeOut actionWithDuration:0.15f];
        [jumpFrame runAction:fadeOut];
    }
}

- (BOOL) isSafeToDelete {
    return isSafeToDelete;
}

- (void) safeToDelete {
    isSafeToDelete = YES;
}

- (void) show {
    self.visible = YES;
}

- (void) hide {
    self.visible = NO;
}

- (void) dealloc {
    CCLOG(@"------------------------------ Strongman being dealloced");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    // clean up the trail frames
    for (int i=0; i<4; i++) {
        [jumpTrailFrames[i] removeFromParentAndCleanup:YES];
        jumpTrailFrames[i] = nil;
    }
    
    for (int i=0; i<4; i++) {
        [smashTrailFrames[i] removeFromParentAndCleanup:YES];
        smashTrailFrames[i] = nil;
    }
    
    [strongMan removeFromParentAndCleanup: YES];
    
    [super dealloc];
}

@end
