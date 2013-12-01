//
//  Player.m
//  SwingProto
//
//  Created by James Sandoz on 3/25/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Player.h"
#import "RopeSwinger.h"
#import "Cannon.h"
#import "Spring.h"
#import "Wheel.h"
#import "GamePlayLayer.h"
#import "CatcherGameObject.h"
#import "HUDLayer.h"
#import "AudioEngine.h"
#import "AudioManager.h"
#import "Notifications.h"
#import "SkyLayer.h"
#import "TouchCloudLayer.h"
#import "Macros.h"
#import "Elephant.h"
#import "Constants.h"
#import "CCHeadBodyAnimate.h"
#import "CCHeadBodyAnimation.h"
#import "UserData.h"
#import "FinalPlatform.h"
#import "PlayerFire.h"
#import "FloatingPlatform.h"
#import "FallingPlatform.h"
#import "FloatingBlock.h"
#import "CurvedPlatform.h"
#import "Boulder.h"
#import "Globals.h"
#import "MainGameScene.h"
#import "Loop.h"
#import "Hunter.h"
#import "Insect.h"
#import "PowerUp.h"
#import "SpeedBoost.h"
#import "AngerPotion.h"
#import "Saw.h"
#import "Barrel.h"
#import "AchievementManager.h"

#define INITIAL_SWING_ANIM_DELAY 0.15f

static const int animationTag = 57;
static const int runningTag = 58;
static const int rotationTag = 59;
static const int cannonActionTag = 60;
static const float playerScale = 1.f;
static const float runAccelerationForce = 5.0;
static const float runDecelerationForce = 15.0;
static const float reviveWait = 3.f; // time to wait after player falls for user to select revive or not

@interface Player(Private)
- (void) crash;
- (void) jumpFromElephant;
@end

@implementation Player
@synthesize state;
@synthesize isCaught;
@synthesize bodyWidth;
@synthesize bodyHeight;
@synthesize currentCatcher;
@synthesize receivedFirstJumpInput;
@synthesize landingScore;
@synthesize playerType;
@synthesize currentWind;
@synthesize isJumpHeldDown;
@synthesize fallThrough;
@synthesize lastPlatform;
@synthesize currentPower;
@synthesize revivePowerUp;
@synthesize numJumpsAllowed;
@synthesize gameObjectId;
@synthesize scaleFactor;
@synthesize speedFactor;

static CCArray *swingHeadFrames;
static CCArray *swingBodyFrames;

#pragma mark - Initialization, setup and class members

- (void) reset {
    //
    [stepSpeedAction setSpeed: 1];
    [self stopAnimation];
    //[self stopAllActions];
    //[self unscheduleAllSelectors];
    
    [self initPlayer:nil];
}

- (id) initWithPlayerSkin:(PlayerType) pType {
    NSString *playerSpriteName;
    
    switch (pType) {
        case kPlayerTypeGonzo:
            playerSpriteName = @"gonzoRun_1.png";
            break;
        default:
            playerSpriteName = @"gonzoRun_1.png";
            break;
    }
    
	if ((self = [super initWithSpriteFrameName:playerSpriteName])) {
        screenSize = [[CCDirector sharedDirector] winSize];
#if USE_FIXED_TIME_STEP == 1
        fixedPhysicsSystem = PhysicsSystem::Instance();
#endif
        
        
        // Register for powerup activation notifications and deactivate yourself appropriately
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(activatedPowerUp:) 
                                                     name:NOTIFICATION_POWERUP_ACTIVATED 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(deactivatedPowerUp:) 
                                                     name:NOTIFICATION_POWERUP_DEACTIVATED 
                                                   object:nil];
        
        //[self addChild: [CCSprite spriteWithSpriteFrameName:playerSpriteName]];
        
        [self initPlayer: nil];
        [self setupAnimationsWithPlayerSkin:pType];
        
        // coin sprite to show for bonus coin collection
        coin = [CCSprite spriteWithSpriteFrameName:@"Coin1.png"];
        coin.visible = NO;
        [self addChild:coin];
        
        // init footsteps
        id stepCB = [CCCallFunc actionWithTarget:self selector:@selector(footStep)];
        id delay = [CCDelayTime actionWithDuration:0.425];
        id seq = [CCSequence actions:stepCB, delay, nil];
        id stepRepeat = [CCRepeatForever actionWithAction:seq];
        stepSpeedAction = [CCSpeed actionWithAction:stepRepeat speed:1.0];
        [self runAction:stepSpeedAction];
        
    }
    
    return self;
}

- (void) activatedPowerUp: (NSNotification *) notification {

    if (currentPower != nil) {
        if (![currentPower canCombine: (PowerUp *)notification.object]) {
            // manually turn off the current power
            [self turnOffPower: currentPower];
        }
    }
    
    currentPower = (PowerUp*) notification.object;
    
    if ([currentPower gameObjectType] == kGameObjectSpeedBoost) {
        
        if (state == kSwingerJumping || state == kSwingerInAir) {
            //state = kSwingerJumping;
            // XXX need a way to allow player to do a jump in this case
            numJumpsAllowed++;
        }
        
        speedFactor = [(SpeedBoost *) currentPower getBoostFactor];
        [[SkyLayer sharedLayer] startSpeedStreaks:20*speedFactor];
        [[TouchCloudLayer sharedLayer] startSpeedStreaks:20*speedFactor];
        float xVel = runSpeed * speedFactor;
        float yVel = 0;//body->GetLinearVelocity().y;
        
        if (yVel < 0) {
            yVel = 7;
        }
        
        //body->SetLinearVelocity(b2Vec2(xVel, yVel));
        body->ApplyLinearImpulse(b2Vec2(xVel * body->GetMass(), yVel * body->GetMass()), body->GetPosition());
    } else if ([currentPower gameObjectType] == kGameObjectJetPack) {
        //
        
        if ([currentCatcher gameObjectType] == kGameObjectCatcher) {
            [(RopeSwinger*) currentCatcher dropCatcher];
            [self hoveringAnimation];
        }
    }
}

- (void) deactivatedPowerUp: (NSNotification *) notification {
    
    [self turnOffPower: (PowerUp *) notification.object];
}

- (void) turnOffPower: (PowerUp *) power {
    
    if (power != nil) {
        
        switch ([power gameObjectType]) {
            case kGameObjectSpeedBoost: {
                
                if (power == currentPower || (currentPower != nil &&
                    [currentPower gameObjectType] != kGameObjectSpeedBoost)) {
                    speedFactor = 1;
                    [[SkyLayer sharedLayer] stopSpeedStreaks];
                    [[TouchCloudLayer sharedLayer] stopSpeedStreaks];
                    
                    if (numJumpsAllowed > 1) {
                        numJumpsAllowed--;
                    }
                }
                
                
                //body->SetLinearVelocity(b2Vec2(runSpeed * speedFactor, body->GetLinearVelocity().y));
            }
            case kGameObjectJetPack: {
                
                if (state == kSwingerHovering) {
                    //body->SetLinearVelocity(b2Vec2(3, -1));
                    state = kSwingerInAir;
                }
            }
            case kGameObjectAngerPotion: {
                
                if (currentPower != nil) {
                    
                    //if ([currentPower gameObjectType] != kGameObjectSpeedBoost) {
                    //    speedFactor = 1;
                    //}
                    
                    if (power == currentPower || [currentPower gameObjectType] != kGameObjectAngerPotion) {
                        scaleFactor = 1;
                    }
                } else {
                    speedFactor = 1;
                    scaleFactor = 1;
                }
                
                destroyRunJoint = YES;
            }
            default:
                break;
        }
        
        if (power == currentPower) {
            currentPower = nil;
        }
    }
}

- (BOOL) willKill {
    return speedFactor > 1 || scaleFactor > 1;
}

- (void) enemyKilled: (Enemy*) enemy {
    
    if (numJumpsAllowed < 1) {
        numJumpsAllowed = 1;
    }
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENEMY_KILLED object:enemy];
}

- (void) initPlayer: (CatcherGameObject *) initialCatcher {
    top = kContactTop;
    bottom = kContactBottom;
    state = kSwingerNone;
    
    scaleFactor = 0;
    
    if (body != NULL) {
        
        [self createScaledPhysicsObject: 1];
        
        // Move it so that it doesn't hit the final platform 
        // when the mouse joint tries to move the player
        body->SetActive(NO);
        //body->SetTransform(b2Vec2(0, screenSize.height/PTM_RATIO), 0);
        body->SetActive(YES);
        body->SetLinearVelocity(b2Vec2(0,0));
    }
    
    if (jointWithCatcher != NULL) {
        world->DestroyJoint(jointWithCatcher);
    }
    jointWithCatcher = NULL;
    
    [self doDestroyRunJoint];
    
    [self stopAnimation];
    
    /*if(initialCatcher != nil) {
     [self moveTo: [initialCatcher getCatchPoint]];
     [self catchCatcher: initialCatcher];
     [self processContactWithCatcher: initialCatcher];
     }*/
    
    fromCurrentCatcherIndex = 0;
    numCatchersSkipped = 0;
    isCaught = NO;
    currentCatcher = nil;
    currentWind = nil;
    currentPower = nil;
    previousCatcher = nil;
    receivedFirstJumpInput = NO;
    playerAdvanced = NO;
    [self resetGravity];
    catchLocation = CGPointZero;
    isBounceBackRequired = NO;
    lastPlatform = nil;
    fallThrough = NO;
    bounceXPos = 0;
    
    runSpeed = g_gameRules.runSpeed;
    speedFactor = 1;
    jumpForce = g_gameRules.jumpForce;
    floatForce = g_gameRules.floatForce;
    numJumpsAllowed = 0;
    isJumpHeldDown = NO;
    createRunJoint = NO;
    destroyRunJoint = NO;
    dyingSoundStarted = NO;
    
    self.scale = playerScale;
    self.rotation = 0;
    [self showCannonTrail: NO];
    [self setOnFire: NO];
}



- (void) setupAnimationsWithPlayerSkin:(PlayerType) pType {
    
    // Place them in blocks so we don't make stupid mistake of using wrong frame arrays
    
    // Jumping
    {
        NSMutableArray *jumpingFrames = [NSMutableArray array];
        for (int i=1; i <= 7; i++){
            NSString *file = [NSString stringWithFormat:@"gonzoJumpStart_%d.png", i];
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [jumpingFrames addObject:frame];
        }
        
        CCAnimation *animJump = [CCAnimation animationWithFrames:jumpingFrames delay:.0133f];
        [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"jumpingStartAnimation"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animJump name:@"jumpingStartAnimation"];
        
        [jumpingFrames removeAllObjects];
        for (int i=1; i <= 7; i++){
            NSString *file = [NSString stringWithFormat:@"gonzoJump_%d.png", i];
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [jumpingFrames addObject:frame];
        }
        
        animJump = [CCAnimation animationWithFrames:jumpingFrames delay:.0833f];
        [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"jumpingAnimation"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animJump name:@"jumpingAnimation"];
    }
    
    // Jumping Up Animation
    {
        NSMutableArray *jumpingFrames = [NSMutableArray array];
        for (int i=1; i <= 6; i++){
            NSString *file = [NSString stringWithFormat:@"gonzoJump_%d.png", i];
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [jumpingFrames addObject:frame];
        }
        
        CCAnimation *animJump = [CCAnimation animationWithFrames:jumpingFrames delay:.0833f];
        [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"bouncingUpAnimation"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animJump name:@"bouncingUpAnimation"];
    }
    
    // Jumping End
    {
        NSMutableArray *jumpingFrames = [NSMutableArray array];
        for (int i=1; i <= 6; i++){
            NSString *file = [NSString stringWithFormat:@"gonzoJumpEnd_%d.png", i];
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [jumpingFrames addObject:frame];
        }
        
        CCAnimation *animJump = [CCAnimation animationWithFrames:jumpingFrames delay:.233f];
        [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"jumpingEndAnimation"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animJump name:@"jumpingEndAnimation"];
    }
    
    // Falling
    {
        NSMutableArray *fallingFrames = [NSMutableArray array];        
        for (int i=1; i <= 11; i++){
            NSString *file = [NSString stringWithFormat:@"gonzoRoll_%d.png", i];
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [fallingFrames addObject:frame];
        }
        
        CCAnimation *animFalling = [CCAnimation animationWithFrames:fallingFrames delay:.0333f];
        [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"fallingAnimation"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animFalling name:@"fallingAnimation"];
    }
    
    // Flying    
    {
        NSMutableArray *flyingBodyFrames = [NSMutableArray array];        
        for (int i=1; i <= 2; i++){
            NSString *file = [NSString stringWithFormat:@"gonzoFly_%d.png", i];
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [flyingBodyFrames addObject:frame];
        }
        
        CCAnimation *animFly = [CCAnimation animationWithFrames:flyingBodyFrames delay:.133f];
        [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"flyingAnimation"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animFly name:@"flyingAnimation"];
    }
    
    // Swinging    
    {
        NSMutableArray *swingingFrames = [NSMutableArray array];        
        for (int i=1; i <= 6; i++){
            NSString *file = [NSString stringWithFormat:@"gonzoSwing_%d.png", i];
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [swingingFrames addObject:frame];
        }
        
        CCAnimation *animSwing = [CCAnimation animationWithFrames:swingingFrames delay:.133f];
        [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"swingingAnimation"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animSwing name:@"swingingAnimation"];
    }
    
    // Balance
    {
        NSMutableArray *balanceFrames = [NSMutableArray array];
        for (int i=1; i <= 6; i++) {
            NSString *file = [NSString stringWithFormat:@"gonzoSlide_%d.png", i];
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [balanceFrames addObject:frame];
        }
        
        CCAnimation *animBalance = [CCAnimation animationWithFrames:balanceFrames delay:0.133f];
        [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"balanceAnimation"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animBalance name:@"balanceAnimation"];
    }
    
    // Hovering
    {
        NSMutableArray *balanceFrames = [NSMutableArray array];
        for (int i=1; i <= 6; i++) {
            NSString *file = [NSString stringWithFormat:@"gonzoSlide_%d.png", i];
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [balanceFrames addObject:frame];
        }
        
        CCAnimation *animBalance = [CCAnimation animationWithFrames:balanceFrames delay:0.133f];
        [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"hoverAnimation"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animBalance name:@"hoverAnimation"];
    }
    
    // Running
    {
        NSMutableArray *runningFrames = [NSMutableArray array];
        for (int i=1; i <= 11; i++){
            NSString *file = [NSString stringWithFormat:@"gonzoRun_%d.png", i];
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [runningFrames addObject:frame];
        }
        
        CCAnimation *animRun = [CCAnimation animationWithFrames:runningFrames delay:.0333f];
        [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"runningAnimation"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animRun name:@"runningAnimation"];
    }
    
    // Skidding
    {
        NSMutableArray *skidFrames = [NSMutableArray array];
        for (int i=11; i <= 11 ; i++) {
            NSString *file = [NSString stringWithFormat:@"gonzoRun_%d.png", i];
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [skidFrames addObject:frame];
        }
        
        CCAnimation *animSkid = [CCAnimation animationWithFrames:skidFrames delay:0.133f];
        [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"skidAnimation"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animSkid name:@"skidAnimation"];
    }
    
    //=================================
    // Setup particle effects
    //=================================
    
    {
        trail = [PlayerTrail particleWithFile:@"playerTrail.plist"];
        trail.scale = ssipadauto(0.85f);
        trail.position = ccp(0,0);
        [[GamePlayLayer sharedLayer] addChild:trail z:-1];
    }
    
    {
        fire = [PlayerFire particleWithFile:@"playerFire.plist"];
        fire.scale = ssipadauto(0.1f);
        fire.position = ccp(ssipadauto(20),ssipadauto(0));
        [self addChild: fire z:1];
    }
}

- (void) flip:(BOOL)flipX {
    CCLOG(@"In player.flip(%d)\n", flipX);
    
    self.flipX = flipX;
    //bodySprite.flipX = flipX;
}

- (void) showCannonTrail: (BOOL) show {
    
    if (show && !trail.visible) {
        trail.position = self.position;
        [trail resetSystem];
    } else if(!show && trail.visible) {
        [trail stopSystem];
    }
    
    trail.visible = show;
}

- (void) setOnFire: (BOOL) onFire {
    
    fire.visible = onFire;
    
    if (onFire) {
        
        [fire resetSystem];
        
        fire.scale = ssipadauto(0.05f);
        CCScaleTo *scale1 = [CCScaleTo actionWithDuration:0.4 scale:ssipadauto(0.3f)];
        CCScaleTo *scale2 = [CCScaleTo actionWithDuration:0.8 scale:ssipadauto(0.1f)];
        
        CCSequence *seq = [CCSequence actions:scale1, scale2, nil];
        [fire stopAllActions];
        [fire runAction: seq];
    } else {
        [fire stopSystem];
    }
}

- (void) createPhysicsObject:(b2World*)theWorld {
    
    CGPoint p = ccp(0,0);
    
    world = theWorld;
    
    //    sprite = [CCSprite spriteWithFile:@"jumper.png"];
    //    sprite.position = p;
    //    [parent addChild:sprite];
    
    b2BodyDef jumperBodyDef;
    jumperBodyDef.type = b2_dynamicBody;
    jumperBodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
    jumperBodyDef.userData = self;
    body = world->CreateBody(&jumperBodyDef);
    
    
    //    b2PolygonShape topShape;
    //    topShape.SetAsBox(self.contentSize.width*self.scale/PTM_RATIO/2, self.contentSize.height*self.scale/PTM_RATIO/4, b2Vec2(0, self.contentSize.height*self.scale/PTM_RATIO/4), 0);
    //    b2FixtureDef topFixtureDef;
    //    topFixtureDef.shape = &topShape;
    //    topFixtureDef.density = 2.0f;
    //    topFixtureDef.friction = 0.3f;
    //    topFixtureDef.filter.categoryBits = CATEGORY_JUMPER;
    //    topFixtureDef.filter.maskBits = CATEGORY_CATCHER | CATEGORY_GROUND;
    //    b2Fixture *topFixture = body->CreateFixture(&topFixtureDef);
    //    topFixture->SetUserData(&top);
    //    
    //    b2PolygonShape bottomShape;
    //    bottomShape.SetAsBox(self.contentSize.width*self.scale/PTM_RATIO/2, self.contentSize.height*self.scale/PTM_RATIO/4, b2Vec2(0, -self.contentSize.height*self.scale/PTM_RATIO/4), 0);
    //    b2FixtureDef bottomFixtureDef;
    //    bottomFixtureDef.shape = &bottomShape;
    //    bottomFixtureDef.density = 2.0f;
    //    bottomFixtureDef.friction = 0.3f;
    //    bottomFixtureDef.filter.categoryBits = CATEGORY_JUMPER;
    //    bottomFixtureDef.filter.maskBits = CATEGORY_CATCHER | CATEGORY_GROUND;
    //    b2Fixture *bottomFixture = body->CreateFixture(&bottomFixtureDef);
    //    bottomFixture->SetUserData(&bottom);
    
    [self createScaledPhysicsObject: 1];
    
    //=======================
    // Revive powerup
    //=======================
    revivePowerUp = [SpeedBoost make];
    revivePowerUp.gameObjectId = [GamePlayLayer sharedLayer].goId++;
    //[revivePowerUp retain];
    [revivePowerUp createPhysicsObject: world];
    [revivePowerUp showAt: ccp(-ssipadauto(200), -ssipadauto(200))];
    [[GamePlayLayer sharedLayer] addChild: revivePowerUp];
}

- (void) createScaledPhysicsObject: (float) scale {
    
    // destroy current body fixtures and rescale them
    if (body != NULL) {
        
        if (scale == scaleFactor) {
            // already at the specified scale
            CCLOG(@"SCALE IS THE SAME!");
            //return;
        }
        
        if (fixture != NULL) {
            body->DestroyFixture(fixture);
            fixture = NULL;
        }
        
        if (bottomFixture != NULL) {
            body->DestroyFixture(bottomFixture);
            bottomFixture = NULL;
        }
    }
    
    scaleFactor = scale;
    self.scale = playerScale*scaleFactor;
    b2PolygonShape shape;
    
    // Hard code in size (due to separate head and body, can't rely on content size)
    bodyWidth = ssipadauto(60)*self.scale/PTM_RATIO;//ssipadauto(49)*self.scale/PTM_RATIO;
    bodyHeight = ssipadauto(55)*self.scale/PTM_RATIO;//ssipadauto(73)*self.scale/PTM_RATIO;
    
    // top half of body is a rectangle, bottom half is a circle.  Shift rectangle body
    // upwards and make it shorter so that the circle can fit in and maintain the 
    // previous height
    shape.SetAsBox(bodyWidth/2, bodyHeight*.375f, b2Vec2(0, bodyHeight*.125f), 0);
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
#ifdef USE_CONSISTENT_PTM_RATIO
    fixtureDef.density = /*scale*/2.f;
#else
    fixtureDef.density = /*scale*/2.f/ssipad(4.f, 1.f);
#endif
    fixtureDef.friction = 0.0f;//5.3f;
    fixtureDef.restitution = 0.f;
    
    fixtureDef.filter.categoryBits = CATEGORY_JUMPER;
    fixtureDef.filter.maskBits = CATEGORY_CATCHER | CATEGORY_GROUND | CATEGORY_FINAL_PLATFORM | CATEGORY_CANNON | CATEGORY_STAR | CATEGORY_LOOP | CATEGORY_SPRING | CATEGORY_FLOATING_PLATFORM | CATEGORY_ENEMY;
    fixture = body->CreateFixture(&fixtureDef);
    
    CCLOG(@"*************************** player mass = %f %f %f %f", body->GetMass(), self.contentSize.width*self.scale/PTM_RATIO/2, self.contentSize.height*self.scale/PTM_RATIO/2,
          (self.contentSize.width*self.scale/PTM_RATIO/2*2 * self.contentSize.height*self.scale/PTM_RATIO/2*2)/4.0);
    
    // Use a circle shape for the bottom of the runner, makes running on non-flat ground
    // work much better
    b2CircleShape circleShape;
    circleShape.m_radius = bodyWidth/2;
    circleShape.m_p = b2Vec2(0, bodyHeight*-.25f);
    fixtureDef.shape = &circleShape;
    fixtureDef.friction = 0;
    fixtureDef.restitution = 0;
    //fixtureDef.density = 1.f;
    bottomFixture = body->CreateFixture(&fixtureDef);
}


#pragma mark - Helpers and controllers
- (void) catchCatcher:(CCNode<GameObject, PhysicsObject, CatcherGameObject>*)newCatcher  {
    [self catchCatcher:newCatcher at: CGPointZero];
}

- (void) catchCatcher:(CCNode<GameObject, PhysicsObject, CatcherGameObject>*)newCatcher at: (CGPoint) location  {
    
    if (state == kSwingerDead || state == kSwingerFell /*|| state == kSwingerDizzy*/ || state == kSwingerInCannon /*|| state == kSwingerFalling*/) {
        return;
    }
    
    // When on jet pack no need of grabbing onto the rope
    if ((speedFactor > 1 || (currentPower != nil && [currentPower gameObjectType] == kGameObjectJetPack)) && 
        [newCatcher gameObjectType] == kGameObjectCatcher) {
        return;
    }
    
    // attach to catcher - the same cannon/spring can recatch the player
    if (([self isMultiCatchAllowed : newCatcher] || currentCatcher != newCatcher) 
        && NULL == jointWithCatcher) 
    {
        
        //self.rotation = 0;
        catchLocation = location;
        
        playerAdvanced = (currentCatcher != newCatcher);
        
        if (playerAdvanced && currentCatcher != nil) {
            
            BOOL collide = YES;
            
            /*if ([currentCatcher gameObjectType] == kGameObjectHunter &&
             ([(Hunter *) currentCatcher dead] || fallThrough)) {
             collide = NO;
             }*/
            
            if ([currentCatcher gameObjectType] == kGameObjectLoop) {
                collide = NO;
            }
            
            [currentCatcher setCollideWithPlayer: collide];
            
            if ([currentCatcher gameObjectType] == kGameObjectFloatingPlatform && (location.x == -1 && location.y == -1)) {
                
                if ([self willKill]) {
                    isBounceBackRequired = NO;
                } else {
                    isBounceBackRequired = YES;
                }
            } else if ([currentCatcher gameObjectType] == kGameObjectCatcher) {
                //[(RopeSwinger *) currentCatcher detach: self];
            } else if ([currentCatcher gameObjectType] == kGameObjectBoulder) {
                [(Boulder *) currentCatcher doUnload];
            }
        } else if (!playerAdvanced) {
            //
            
            if ([newCatcher gameObjectType] == kGameObjectCatcher) {
                [(RopeSwinger *) newCatcher detach:self];
            }
        }/* else if (!playerAdvanced && [currentCatcher gameObjectType] == kGameObjectHunter) {
          
          fallThrough = YES;
          }*/
        
        
        
        //if ([newCatcher gameObjectType] == kGameObjectSaw 
        //     || [newCatcher gameObjectType] == kGameObjectInsect ||
        //    [newCatcher gameObjectType] == kGameObjectHunter) {
            
            //return;
        //}
        
        previousCatcher = currentCatcher;
        currentCatcher = newCatcher;
        
        isCaught = YES;
        //self.rotation = 0;
        self.flipX = NO;
        self.flipY = NO;
        
        if ([newCatcher gameObjectType] == kGameObjectCannon) {
            [[AchievementManager sharedInstance] shotFromCannon];
            self.visible = NO;
        } else if ([newCatcher gameObjectType] == kGameObjectFloatingPlatform ||
                   [newCatcher gameObjectType] == kGameObjectCurvedPlatform) {
            landingVelocity = body->GetLinearVelocity().y;
            //CCLOG(@"LANDING VELOCITY IS %f", landingVelocity);
        } else if ([newCatcher gameObjectType] == kGameObjectCatcher) {
            [[AchievementManager sharedInstance] caughtRope];
        }
        
        // This will scroll the screen along with the swing -- think it feels better
        [GamePlayLayer sharedLayer].scrollMode = kScrollModeScroll;
        //[[GamePlayLayer sharedLayer] verticalScrollToPlatform];
        
        //[GamePlayLayer sharedLayer].scrollMode = kScrollModeFinish;
        //[[GamePlayLayer sharedLayer] smartZoom];
        
        // Calculate how many Dummy Catcher Objects (DCO) are between previous and current catcher
        // We want to ignore DCOs because they are as their name suggest, Dummys
        NSArray *levelObjects = [currentCatcher getLevelObjects];
        int numDummyObjects = 0;
        int indexInLevelObjects = [currentCatcher getIndexInLevelObjects];
        for (int i = fromCurrentCatcherIndex; i < indexInLevelObjects; i++) {
            CCNode<GameObject> *node = [levelObjects objectAtIndex:i];
            if ([node gameObjectType] == kGameObjectDummy) {
                numDummyObjects++;
            }
        }
        numCatchersSkipped =  (indexInLevelObjects - fromCurrentCatcherIndex) - numDummyObjects - 1;
        fromCurrentCatcherIndex = indexInLevelObjects;
        
        if (numCatchersSkipped > 0) {
            //[[SkyLayer sharedLayer] showFireWork];
            //[[HUDLayer sharedLayer] skippedCatchers: numCatchersSkipped];
        }
        
        if (playerAdvanced) {
            //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PLAYER_CAUGHT object:currentCatcher];
        }
        
        //CCLOG(@"======================> numCatchersSkiped = %d", numCatchersSkipped);
    } else {
        CCLOG(@"IGNORED CONTACT WITH %@", newCatcher);
    }
}

- (void) setRotation:(float)rotation {
    [super setRotation: rotation];
}

- (void) processContactWithCatcher:(CCNode<GameObject, PhysicsObject, CatcherGameObject>*)catcher {
    
    if(state == kSwingerFell /*|| state == kSwingerDizzy*/ || state == kSwingerDead /*|| state == kSwingerFalling*/) {
        return;
    }
    
    // clear some old states
    isFlying = NO;
    isJumpingFromPlatform = NO;
    jumpHeight = 0;
    
    firstContact = NO;
    
    if (currentCatcher == nil) {
        firstContact = YES;
        
        [[HUDLayer sharedLayer] displayLevel];
    }
    
    currentCatcher = catcher;
    currentWind = [(BaseCatcherObject*)catcher wind];
    float timeout = 0.f;
    
    [self resetGravity];
    
    // clear old state
    if (previousCatcher != nil && currentCatcher != previousCatcher) {
        switch ([previousCatcher gameObjectType]) {
            case kGameObjectBoulder: {
                [(Boulder *)previousCatcher unload];
                //[previousCatcher setCollideWithPlayer:YES];
                break;
            } case kGameObjectFloatingPlatform: {
                //destroyRunJoint = YES;
                [self doDestroyRunJoint];
                break;
            } case kGameObjectCatcher: {
                [(RopeSwinger *) previousCatcher detach:self];
                break;
            }
            default:
                break;
        }
    }
    
    switch ([currentCatcher gameObjectType]) {
        case kGameObjectCatcher: {
            RopeSwinger * rope = (RopeSwinger *) catcher;
            timeout = rope.grip;
            //[self createWeldJoint : catcher];
            [self destroyJointWithCatcher];
            [rope attach:self at:catchLocation];
            [currentCatcher setSwingerVisible:YES];
            //self.visible = NO;
            [self swingingAnimation];
            break;
        }
        case kGameObjectCannon: {
            //Cannon * cannon = (Cannon *) catcher;
            //[self createWeldJoint : catcher];
            //body->SetSleepingAllowed(false);
            //timeout = cannon.timeout;
            //[(Cannon *) catcher load: self]; // load yourself into the cannon immediately shoot out
            //[self cannonLoadedAnimation];
            
            // wait for a fraction of a second then shoot
            //CCDelayTime * waitToLoad = [CCDelayTime actionWithDuration:firstContact ? 0.f : 0.15f];
            //CCCallFunc  * load = [CCCallFunc actionWithTarget:self selector:@selector(loadCannon)];
            
            if (firstContact) {
                body->SetActive(NO);
                body->SetTransform(b2Vec2(0, screenSize.height/PTM_RATIO), 0);
                body->SetActive(YES);
                body->SetLinearVelocity(b2Vec2(0,0));
            }
            
            float duration = firstContact ? 1.5f : 0.f;
            
            //if (duration > 0.0) {
            [self loadCannon: NO];
            CCDelayTime * waitToShoot = [CCDelayTime actionWithDuration: duration];
            CCCallFunc  * shoot = [CCCallFunc actionWithTarget:self selector:@selector(shootFromCannon)];
            CCSequence  * cannonAction = [CCSequence actions: /*waitToLoad, load,*/ waitToShoot, shoot, nil];
            cannonAction.tag = cannonActionTag;
            
            [self runAction: cannonAction];
            //} else {
            //    [self loadCannon: YES];
            //}
            
            break;
        }
        case kGameObjectWheel: {
            timeout = [(Wheel *) catcher timeout];
            //body->SetSleepingAllowed(false);
            [(Wheel *) catcher load: self at: catchLocation]; // climb on the wheel
            break;
        }
        case kGameObjectSpring: {
            timeout = [(Spring*) catcher timeout];
            [self bounceOnSpring];
            [[catcher getNextCatcherGameObject] setCollideWithPlayer: YES];
            
            if (!playerAdvanced /*&& !firstContact*/) {
                // bouncing on the spring
                timeout = 0;
            }
            
            break;
        }
        case kGameObjectLoop: {
            [self loop];
            break;
        }
        case kGameObjectElephant: {
            timeout = ((Elephant *) catcher).timeout;
            // load player on the elephant
            [(Elephant *) catcher load:self];
            break;
        }
        case kGameObjectFloatingPlatform: 
        case kGameObjectCurvedPlatform: 
        case kGameObjectFallingPlatform:
        case kGameObjectBlock: {
            
            //if (body->GetLinearVelocity().y < 0) {
                // cut off y velocity
            //    body->SetLinearVelocity(b2Vec2(body->GetLinearVelocity().x, 0));
            //}
            
            destroyRunJoint = NO;
            if (firstContact) {
                [self moveTo: ccp([catcher getCatchPoint].x + ssipadauto(2), [catcher getCatchPoint].y + ((bodyHeight/2 + bodyWidth/4) * PTM_RATIO) /*- ssipadauto(30)*/)];
                //createRunJoint = YES;
                destroyRunJoint = YES;
            }
            
            //lastPlatform = (FloatingPlatform *) catcher;
            [self run:catchLocation];
            
            if ([currentCatcher isKindOfClass: [FallingPlatform class]]) {
                [(FallingPlatform *) currentCatcher fall];
            }
            
            numJumpsAllowed = 1;
            
            if (speedFactor > 1) {
                numJumpsAllowed++;
            }
            
            break;
        }
        case kGameObjectFinalPlatform: {
            
            [self run:catchLocation];
            
            state = kSwingerOnFinalPlatform;
            
            break;
        }
            // Enemies
        case kGameObjectBoulder: {
            timeout = 0;
            numJumpsAllowed = 1;
            [(Boulder *) catcher attack: self at: catchLocation];
            break;
        }
        case kGameObjectHunter: {
            timeout = 0;
            [(Hunter *) catcher attack: self at: catchLocation];
            //currentCatcher = nil;
            break;
        }
        case kGameObjectInsect: {
            timeout = 0;
            [(Insect *) catcher attack: self at: catchLocation];
            break;
        }
        case kGameObjectSaw: {
            timeout = 0;
            [(Saw *) catcher attack: self at: catchLocation];
            break;
        }
        case kGameObjectOilBarrel: {
            timeout = 0;
            
            if (catchLocation.x == -1 && catchLocation.y == -1) {
                [self skid];
            } else {
                [(Barrel *) catcher attack: self at: catchLocation];
            }
            break;
        }
        default:
            break;
    }
    
    if(timeout > 0 /*&& (!receivedFirstJumpInput || playerAdvanced)*/) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_WIND_BLOWING object:currentWind];
        
        if (DO_GRIP == 1) {
            [[HUDLayer sharedLayer] resetGripBar];
            [[HUDLayer sharedLayer] countDownGrip:timeout];
        }
    }
}

- (void) createWeldJoint : (CCNode<GameObject, PhysicsObject, CatcherGameObject>*) catcher {
    //NSAssert(jointWithCatcher == NULL, @"Joint with catcher should be NULL!");
    [self destroyJointWithCatcher];
    
    b2Body * catcherBody = [catcher getPhysicsBody];
    
    /*if ([catcher gameObjectType] == kGameObjectCannon || [catcher gameObjectType] == kGameObjectWheel) {
     [self moveTo: [catcher getCatchPoint]];
     body->SetTransform(body->GetPosition(), catcherBody->GetAngle());
     }*/
    
    b2WeldJointDef playerJointDef;
    playerJointDef.Initialize(catcherBody, body, catcherBody->GetWorldCenter());
    playerJointDef.collideConnected = NO;
    playerJointDef.bodyA = catcherBody;
    playerJointDef.bodyB = body;
    
    // set the local anchors of the joint to be the player and catcher's hands
    //XXX these will need to be set for iPad
    switch ([catcher gameObjectType]) {
        case kGameObjectCatcher: {
            playerJointDef.localAnchorA = b2Vec2(0,0);//-10.f/PTM_RATIO, -7.f/PTM_RATIO);
            playerJointDef.localAnchorB = b2Vec2(0,0);//8.f/PTM_RATIO, 6.f/PTM_RATIO);
            
            // XXX trying out magnegrip - destroying it on catch
            //RopeSwinger *rs = (RopeSwinger*)catcher;
            //[rs destroyMagneticGrip];
            break;            
        }
        case kGameObjectCannon: {
            
            playerJointDef.localAnchorA = b2Vec2(0,0);
            playerJointDef.localAnchorB = b2Vec2(0, ssipadauto(0)/PTM_RATIO); //ssipadauto(-110.f)/PTM_RATIO);
            break;
        }
        case kGameObjectWheel: {
            
            //float scale = (screenSize.height/640) * 2; // get scale for ipad/iphone
            playerJointDef.localAnchorA = b2Vec2(0,0);
            playerJointDef.localAnchorB = b2Vec2(ssipadauto(110.f)*self.scale/PTM_RATIO,0);
            //playerJointDef.localAnchorB = b2Vec2(0,0);
            break;
        }
        case kGameObjectElephant: {
            //
        }
            break;
        default:
            break;
    }
    
    jointWithCatcher = world->CreateJoint(&playerJointDef);
}




- (BOOL) isMultiCatchAllowed: (CCNode<GameObject, PhysicsObject, CatcherGameObject>*) newCatcher {
    return ([currentCatcher gameObjectType] == kGameObjectCannon ||
            [currentCatcher gameObjectType] == kGameObjectSpring ||
            [currentCatcher gameObjectType] == kGameObjectFloatingPlatform ||
            [currentCatcher gameObjectType] == kGameObjectCurvedPlatform ||
            [currentCatcher gameObjectType] == kGameObjectBlock) ||
            (([currentCatcher gameObjectType] == kGameObjectCatcher ||
              [currentCatcher gameObjectType] == kGameObjectHunter ||
              [currentCatcher gameObjectType] == kGameObjectInsect ||
              [currentCatcher gameObjectType] == kGameObjectOilBarrel ||
              [currentCatcher gameObjectType] == kGameObjectSaw) &&
            newCatcher.gameObjectId != currentCatcher.gameObjectId);
}

- (void) gripRanOut {
    if(jointWithCatcher != NULL) {
        world->DestroyJoint(jointWithCatcher);
    }
    jointWithCatcher = NULL;
    
    [currentCatcher setSwingerVisible:NO];
    [currentCatcher setCollideWithPlayer: NO];
    self.visible = YES;
    
    receivedFirstJumpInput = YES;
    
    if (/*state == kSwingerFalling ||*/ state == kSwingerFell /*|| state == kSwingerDizzy*/ || state == kSwingerDead) {
        return;
    }
    
    switch ([currentCatcher gameObjectType]) {
        case kGameObjectCatcher:
            // Stop all forward momentum so the player will fall straight down
            [currentCatcher setCollideWithPlayer:NO];
            body->SetLinearVelocity(b2Vec2(0, body->GetLinearVelocity().y));
            [self fallingAnimation];
            break;
        case kGameObjectCannon:
            //state = kSwingerInAir; // shoot the player up
            //[self shootFromCannon];
            break;
        case kGameObjectSpring:
            [self fallingAnimation];
            [(Spring *) currentCatcher fallApart]; // Uncomment this if we want spring to fall apart
            break;
        case kGameObjectWheel:
            body->SetLinearVelocity(b2Vec2(0,5));
            [self fallingAnimation];
            [(Wheel *) currentCatcher unload];
            // notification so wheel button can be hidden
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PLAYER_IN_AIR object:nil];
            break;
        case kGameObjectElephant:
            body->SetLinearVelocity(b2Vec2(2.5, 5));
            [(Elephant *)currentCatcher buck];
            //                [currentCatcher setCollideWithPlayer:NO];
            [self fallingAnimation];
            break;
        default:
            break;
    }        
}


- (void) scoreLanding {
    FinalPlatform *fp = (FinalPlatform*)currentCatcher;
    
    float finalPlatformLeftEdge = fp.position.x;
    float finalPlatformRightEdge = fp.position.x + [fp boundingBox].size.width;
    
    float finalPlatformHalfWidth = (finalPlatformRightEdge - finalPlatformLeftEdge)/2;
    float finalPlatformCenter = finalPlatformLeftEdge + finalPlatformHalfWidth;
    float offset = fabs(self.position.x-finalPlatformCenter);
    
    // The score is the percent away from the center of the platform (lower is better)
    landingScore = offset/finalPlatformHalfWidth;
    
    //    CCLOG(@"\n\n\n***  scoreLanding: set score to %f, offset was %f (half width=%f)  ***\n\n\n", player.landingScore, offset, finalPlatformHalfWidth);
    
    int score=0;
    if (landingScore < .15f) {
        score = 3;
    } else if (landingScore < .35f) {
        score = 2;
    } else if (landingScore < .5f) {
        score = 1;
    }
    
    if (score > 0) {
        [self bonusCoins:score];
    }
}

- (void) moveTo:(CGPoint)position {
    self.position = position;
    body->SetTransform(b2Vec2(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO), body->GetAngle());
}


#pragma mark - Touch handling
- (void) doTouchAction {
    
    switch ([currentCatcher gameObjectType]) {
        case kGameObjectCatcher:
            [self jumpFromSwing];
            break;
        case kGameObjectCannon:
            //[self shootFromCannon];
            break;
        case kGameObjectSpring:
            [self bounceOffSpring];
            break;
        case kGameObjectElephant:
            [self jumpFromElephant];
            break;
        case kGameObjectWheel:
            [self jumpFromWheel];
            break;
        case kGameObjectBoulder:
            [self jumpFromBoulder];
            break;
        case kGameObjectFloatingPlatform:
        case kGameObjectCurvedPlatform:
        case kGameObjectFallingPlatform: 
        case kGameObjectBlock: {
            [self jumpFromPlatform];
            break;
        }
        case kGameObjectHunter:
        case kGameObjectInsect:
        case kGameObjectSaw:
        case kGameObjectOilBarrel: {
            [self jumpFromPlatform];
            break;
        }
        default:
            break;
    }
}

- (BOOL) handleSwipeEvent {
    
    //if (runJoint != NULL && ([currentCatcher gameObjectType] == kGameObjectFloatingPlatform ||
    //    [currentCatcher gameObjectType] == kGameObjectCurvedPlatform)) {
    
    if ([self canDescend]) {
        [self doDestroyRunJoint];
        [self fallingFromPlatformAnimation];
        
        if ([currentCatcher gameObjectType] == kGameObjectCatcher) {
            [(RopeSwinger*)currentCatcher dropCatcher];
        }
        
        if (!fallThrough) {
            fallThrough = ([currentCatcher gameObjectType] == kGameObjectFloatingPlatform ||
                           [currentCatcher gameObjectType] == kGameObjectCurvedPlatform);
        }
        
        if (/*[currentCatcher gameObjectType] == kGameObjectCatcher ||*/ body->GetLinearVelocity().x < 0) {
            body->SetLinearVelocity(b2Vec2(0,0));
        } else if (body->GetLinearVelocity().y > 0) {
            body->SetLinearVelocity(b2Vec2(body->GetLinearVelocity().x, 0));
        }
        
        return YES;
    }
    
    return NO;
}

- (BOOL) canDescend {
    // put some logic in here to determine if there is an available platform below you, before allowing player to descend
    // makes the game more forgiving?
    return (state != kSwingerOnFinalPlatform && state != kSwingerFinishedLevel && state != kSwingerDead && state != kSwingerFalling &&
            state != kSwingerKnockedOff && state != kSwingerInCannon && !isFlying);//YES;
}

- (BOOL) handleTouchEvent {
    
    if (state == kSwingerFalling) {
        // make sure jumper is below the current platform/catcher before disabling jump
        if (body->GetPosition().y < [currentCatcher getPhysicsBody]->GetPosition().y) {
            return NO;
        }
    }
    
    if(state == kSwingerFell || state == kSwingerReviving || state == kSwingerDead /*|| state == kSwingerFalling*/ || state == kSwingerInCannon) {
        //CCLOG(@"REJECTING JUMP REQUEST!");
        return NO;
    }
    
    if (currentPower != nil && [currentPower gameObjectType] == kGameObjectJetPack) {
        return NO;
    }
    
    if (jointWithCatcher != NULL ||
        ([currentCatcher gameObjectType] == kGameObjectCatcher && state == kSwingerSwinging) ||
        (([currentCatcher gameObjectType] == kGameObjectSpring   || 
          [currentCatcher gameObjectType] == kGameObjectElephant || 
          [currentCatcher gameObjectType] == kGameObjectWheel ||
          [currentCatcher gameObjectType] == kGameObjectBoulder ||
          [currentCatcher gameObjectType] == kGameObjectFloatingPlatform ||
          [currentCatcher gameObjectType] == kGameObjectCurvedPlatform ||
          [currentCatcher gameObjectType] == kGameObjectHunter ||
          [currentCatcher gameObjectType] == kGameObjectInsect ||
          [currentCatcher gameObjectType] == kGameObjectSaw ||
          [currentCatcher gameObjectType] == kGameObjectOilBarrel) && state != kSwingerInAir)) {
        
        //[[HUDLayer sharedLayer] resetGripBar];
        
        // make sure the old catcher no longer collides with the player, and enable collision
        // for the next object
        [currentCatcher setCollideWithPlayer:NO];
        
        [[currentCatcher getNextCatcherGameObject] setCollideWithPlayer:YES];
        [currentCatcher setSwingerVisible:NO];
        
        if(jointWithCatcher != NULL) {
            //XXX is it safe to just destroy this here or does this need to happen in update?
            //XXX seems safe so far but I'm not 100% convinced
            world->DestroyJoint(jointWithCatcher);
            jointWithCatcher = NULL;
        }
        
        // switch to the jumping animation
        [self doTouchAction];
        
        receivedFirstJumpInput = YES;
        
        //[[AudioEngine sharedEngine] playEffect:SND_SWOOSH];
        return YES;
    }
    
    //CCLOG(@"REJECTED JUMP REQUEST!");
    return NO;
}

- (BOOL) handleTapEvent {
    
    if([currentCatcher gameObjectType] == kGameObjectWheel) {
        
        [(Wheel *) currentCatcher handleTap];
        
        return YES;
    }
    
    return NO;
}

- (void) setFallThrough: (BOOL) fall {
    fallThrough = fall;
    
    if (fall) {
        
        // turn off certain powers like jet pack
        if (currentPower != nil && [currentPower gameObjectType] == kGameObjectJetPack) {
            [currentPower deactivate];
            currentPower = nil;
        }
    }
}


#pragma mark - Player control
- (void) run {
    [self run: CGPointZero];
}

- (void) skid {
    //
    
    [(Barrel *) currentCatcher skid];
    [self skiddingAnimation];
}

- (void) run:(CGPoint)location {
    
    if (state == kSwingerSkidding) {
        // can't run, skidding on oil
        return;
    }
    
    //shake the screen on a heavy impact
    float   landingDuration = 0;
    float shakeFactor = 0;
    
    if (landingVelocity < 0) {
        
        float32 approachVelocity = fabsf(landingVelocity);
        //CCLOG(@"LANDING VELOCITY: %f", approachVelocity);
        if (approachVelocity >= 45) {
            shakeFactor = .25;
            landingDuration = 0.25;
        } else if (approachVelocity >= 30) {
            shakeFactor = .2;
            landingDuration = 0.20;
        } else if (approachVelocity >= 25) {
            shakeFactor = .15;
            landingDuration = 0.15;
        }
        
        if (approachVelocity >= 22.5 && !firstContact) {
            //
            [[AudioEngine sharedEngine] playEffect:SND_LAND];
        }
    }
    
    if (shakeFactor > 0) {
        [[MainGameScene sharedScene] shake: ssipadauto(1.f) duration: shakeFactor*scaleFactor];
    } else if (scaleFactor > 1) {
        [[MainGameScene sharedScene] shake: ssipadauto(1.f) duration: .55*scaleFactor];
    }
    
    //CCLOG(@"---------PLAYER PACE: %f--------------", speedFactor);
    
    [self platformRunningAnimation: speedFactor];
    //CCLOG(@"APPLYING LINEAR IMPULSE %f", speedFactor);
    //body->ApplyLinearImpulse(b2Vec2(runSpeed*speedFactor*body->GetMass(), 0), body->GetPosition());
    //body->ApplyLinearImpulse(b2Vec2(runSpeed*speedFactor, 0), body->GetPosition());
    //body->SetLinearVelocity(b2Vec2(runSpeed*speedFactor, 0)); //body->GetLinearVelocity().y));
    
    if (![currentCatcher isKindOfClass: [FloatingBlock class]]) {
        createRunJoint = YES;
    }
    
    // If running on a moving platform, stick to it
    /*if ([currentCatcher gameObjectType] == kGameObjectFloatingPlatform) {
        FloatingPlatform *fp = (FloatingPlatform *)currentCatcher;
        if (fp.elevatorSpeed > 0) {
            createRunJoint = YES;
        }
    }*/
}

- (void) loop {
    
    [(Loop *) currentCatcher loop:self];
}

- (void) bounceBack {
    
    float force = -15;
    
    /*if (state == kSwingerJumping || state == kSwingerInAir) {
        force = -1;
    }*/
    
    bounceXPos = body->GetPosition().x;
    
    // bounce the player back
    [self bounceBackAnimation];
    
    body->SetLinearVelocity(b2Vec2(0,0));
    body->ApplyLinearImpulse(b2Vec2(force*body->GetMass(),0), body->GetPosition());
    
    isBounceBackRequired = NO;
}

- (void) jump {
    [self jumpingAnimation];
    body->ApplyLinearImpulse(b2Vec2(0.0, body->GetMass()*jumpForce), body->GetWorldCenter());
}

- (void) jumpFromSwing {
    [self jumpingAnimation];
    
    [(RopeSwinger *)currentCatcher detach: self];
}

- (void) jumpFromWheel {
    [self jumpingAnimation];
    [(Wheel *)currentCatcher fling];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PLAYER_IN_AIR object:nil];
    currentCatcher = nil;
}

- (void) jumpFromBoulder {
    
    if (numJumpsAllowed > 0 && !fallThrough) {
        [(Boulder *)currentCatcher unload];
        
        state = kSwingerInAir;
        
        body->SetLinearVelocity(b2Vec2(0,0));
        b2Vec2 impulse = b2Vec2(body->GetMass() * 2, body->GetMass() * jumpForce);
        b2Vec2 impulsePoint = body->GetPosition();
        body->ApplyLinearImpulse(impulse, impulsePoint);
        
        [self jumpingFromPlatformAnimation];
        
        [currentCatcher setCollideWithPlayer: YES];
        numJumpsAllowed--;
    }
}

- (void) jumpFromPlatform {
    
    if (numJumpsAllowed > 0 && !firstContact && state != kSwingerFalling && state != kSwingerKnockedOff) {//state != kSwingerJumping) {
        //CCLOG(@"JUMP REQUESTED!");
        //[self showTrail: YES];
        [[AudioEngine sharedEngine] playEffect:SND_JUMP];
        float xForce = 0;
        float yForce = body->GetMass() * jumpForce * (state == kSwingerSkidding ? 0.85 : 1);
        
        if (state == kSwingerJumping) {
            //xForce = (speedFactor > 1 ? 10 : 7)*body->GetMass();
            //yForce = body->GetMass() * (jumpForce + 2);
            
            //if (body->GetLinearVelocity().x > xForce) {
                // kill momentum for deterministic jump every time
            float factor = speedFactor > 1 ? 0.85 : 0.625;
            
            xForce = factor*(jumpForce /*- body->GetLinearVelocity().x*/)*body->GetMass();
            yForce *= factor;
            
            //if (body->GetLinearVelocity().x <= 1) {
                //xForce = jumpForce - body->GetLinearVelocity().x;
            //    xForce = (speedFactor > 1 ? 10 : 7)*body->GetMass();
            //}
            
                //body->SetLinearVelocity(b2Vec2(body->GetLinearVelocity().x,0));
            if (speedFactor <= 1) {
                body->SetLinearVelocity(b2Vec2(0,0));
            } else {
                body->SetLinearVelocity(b2Vec2(body->GetLinearVelocity().x/6,0));
            }
            //}
        } else if (speedFactor <= 1) {
            //body->SetLinearVelocity(b2Vec2(body->GetLinearVelocity().x, 0));
            //body->SetLinearVelocity(b2Vec2(10, 0));
        }
        
        state = kSwingerInAir;
        
        isJumpingFromPlatform = YES;
        jumpHeight = body->GetPosition().y;
        
        // If the player was running on a moving platform, destroy the joint now
        [self doDestroyRunJoint];
        
        //if (body->GetLinearVelocity().x < 0) {
        //    body->SetLinearVelocity(b2Vec2(0,0));
        //}
        
        b2Vec2 impulse = b2Vec2(xForce, yForce);
        b2Vec2 impulsePoint = body->GetPosition();
        
        if (speedFactor <= 1) {
            body->SetLinearVelocity(b2Vec2(body->GetLinearVelocity().x,0));
        }
        
        body->ApplyLinearImpulse(impulse, impulsePoint);
        
        [self jumpingFromPlatformAnimation];
        
        [currentCatcher setCollideWithPlayer: YES];
        numJumpsAllowed--;
    }
}

- (void) destroyJointWithCatcher {
    
    if (jointWithCatcher == NULL)
        return;
    
    world->DestroyJoint(jointWithCatcher);
    jointWithCatcher = NULL;
}

- (void) loadCannon: (BOOL) shootImmediately {
    self.visible = NO;
    Cannon * cannon = (Cannon *) currentCatcher;
    [self cannonLoadedAnimation];
    //[self createWeldJoint : cannon];
    
    /*if (shootImmediately) {
     [self destroyJointWithCatcher];
     }*/
    
    [self doDestroyRunJoint];
    prevVelocity = 0;
    [(Cannon *) cannon load: self shoot: shootImmediately]; // load yourself into the cannon
    
    /*if (shootImmediately) {
     [self shootFromCannon];
     }*/
}

- (void) doDestroyRunJoint {
    
    if (runJoint != NULL) {
        world->DestroyJoint(runJoint);
    }
    runJoint = NULL;
}

- (void) shootFromCannon {
    //[self destroyJointWithCatcher];
    [self setVisible: YES];
    
    //[self showCannonTrail: YES];
    [(Cannon *)currentCatcher shoot];
    //[currentCatcher setCollideWithPlayer: YES];
}

- (void) bounceOnSpring {
    [self setVisible: YES];
    [(Spring *)currentCatcher catchPlayer: self];
}

- (void) bounceOffSpring {
    state = kSwingerOnSpring;
    [(Spring *)currentCatcher bounce];
    [currentCatcher setCollideWithPlayer: YES];
}

- (void) jumpFromElephant {
    [self jumpingAnimation];
    [self setVisible: YES];
    [(Elephant *)currentCatcher jump];
    [currentCatcher setCollideWithPlayer: YES];
}

- (void) bouncingAnimation: (float) delay {
    CCLOG(@"In Player.springBounceAnimation, state=%d\n", state);
    if (state != kSwingerOnSpring) {        
        state = kSwingerOnSpring;
        
        //if (animAction != nil)
        //[self stopAnimation];
        
        //animAction = nil;
    }
    
    [self stopAnimation];
    
    CCAnimation *anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"bouncingAnimation"];
    anim.delay = delay; // setting the delay based on the bounce factor of the spring
    CCAnimate *animate = [CCHeadBodyAnimate actionWithHeadBodyAnimation:anim restoreOriginalFrame:NO];
    CCSequence *seq = [CCSequence actions: animate, [CCCallFunc actionWithTarget:self selector:@selector(stopAnimation)], nil];
    animAction = seq;
    animAction.tag = animationTag;
    [self runAction:animAction];
}

- (void) boulderRunningAnimation: (float) pace {
    CCLOG(@"In Player.boulderRunningAnimation, state=%d\n", state);
    if (state != kSwingerOnBoulder) {        
        state = kSwingerOnBoulder;
        
        [self stopAnimation];
        //bodySprite.visible = NO;
        
        CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"runningAnimation"] restoreOriginalFrame:NO];
        animAction = [CCRepeatForever actionWithAction:action];
        animAction.tag = animationTag;
        
        runSpeedAction = [CCSpeed actionWithAction:(CCActionInterval*)animAction speed:pace];
        runSpeedAction.tag = runningTag;
        
        [self runAction:runSpeedAction];
        [stepSpeedAction setSpeed: pace];
    } else {
        // changing pace
        if (pace != runSpeedAction.speed) {
            [runSpeedAction setSpeed: pace];
            [stepSpeedAction setSpeed: pace];
        }
    }
}

- (void) hoveringAnimation {
    CCLOG(@"In Player.hoveringAnimation, state=%d\n", state);
    self.visible = YES;
    self.rotation = 0;
    
    if (state != kSwingerHovering) {       
        state = kSwingerHovering;
        
        [self stopAnimation];
        //bodySprite.visible = NO;
        
        CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"hoverAnimation"] restoreOriginalFrame:NO];
        animAction = [CCRepeatForever actionWithAction:action];
        animAction.tag = animationTag;
        self.rotation = 0;
        [self runAction:animAction];
    }
}

- (void) loopingAnimation {
    CCLOG(@"In Player.loopingAnimation, state=%d\n", state);
    self.visible = YES;
    self.rotation = 0;
    
    if (state != kSwingerLooping) {       
        state = kSwingerLooping;
        destroyRunJoint = YES;
        
        [self stopAnimation];
        //bodySprite.visible = NO;
        
        CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"balanceAnimation"] restoreOriginalFrame:NO];
        animAction = [CCRepeatForever actionWithAction:action];
        animAction.tag = animationTag;
        self.rotation = 0;
        [self runAction:animAction];
    }
}

- (void) skiddingAnimation {
    //
    CCLOG(@"In Player.skiddingAnimation, state=%d\n", state);
    self.visible = YES;
    self.rotation = 0;
    
    if (state != kSwingerSkidding) {
        state = kSwingerSkidding;
        
        [self doDestroyRunJoint];
        
        CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"skidAnimation"] restoreOriginalFrame:NO];
        animAction = [CCRepeatForever actionWithAction:action];
        animAction.tag = animationTag;
        self.rotation = 0;
        [self runAction:animAction];
    }
}

- (void) platformRunningAnimation: (float) pace {
    self.visible = YES;
    self.rotation = 0;
    
    if (state != kSwingerOnFloatingPlatform) {
        //CCLOG(@"In Player.platformRunningAnimation, pace=%f, state=%d\n", pace, state);
        //SwingerState oldState = state;
        state = kSwingerOnFloatingPlatform;
        
        //FloatingPlatform *fp = (FloatingPlatform *)currentCatcher;
        //if ([currentCatcher isKindOfClass: [CurvedPlatform class]] ||
        //    self.position.x <= (fp.position.x + fp.width)-ssautores(0.5)) {
            
            [self stopAnimation];
            //bodySprite.visible = NO;
            CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"runningAnimation"] restoreOriginalFrame:NO];
            animAction = [CCRepeatForever actionWithAction:action];
            animAction.tag = animationTag;
            
            runSpeedAction = [CCSpeed actionWithAction:(CCActionInterval*)animAction speed:pace];
            runSpeedAction.tag = runningTag;
            
            [self runAction:runSpeedAction];
        [stepSpeedAction setSpeed: pace];
        //}
    } else {
        // changing pace
        if (pace != runSpeedAction.speed) {
            //CCLOG(@"In Player.platformRunningAnimation, new pace=%f, state=%d\n", pace, state);
            [runSpeedAction setSpeed: pace];
            [stepSpeedAction setSpeed: pace];
        }
    }
}

- (void) footStep {
    if (state == kSwingerOnFloatingPlatform || state == kSwingerOnFinalPlatform) {
        [[AudioEngine sharedEngine] playEffect:SND_STEP gain:32];
    }
}

- (void) cannonLoadedAnimation {
    CCLOG(@"In Player.cannonLoadedAnimation, state=%d\n", state);
    if (state != kSwingerInCannon) {        
        state = kSwingerInCannon;
        
        [self stopAnimation];
        
        //        
        //        CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"swingingAnimation"] restoreOriginalFrame:NO];
        //        animAction = [CCRepeatForever actionWithAction:action];
        //        [self runAction:animAction];
    }
}

- (void) swingingAnimation {
    CCLOG(@"In Player.swingingAnimation, state=%d\n", state);
    if (state != kSwingerSwinging) {        
        state = kSwingerSwinging;
        
        [self stopAnimation];
        //bodySprite.visible = NO;
        
        animAction = nil;
        
        CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"swingingAnimation"] restoreOriginalFrame:NO];
        animAction = [CCRepeatForever actionWithAction:action];
        [self runAction:animAction];
    }
}

- (void) jumpingFromPlatformAnimation {
    CCLOG(@"In Player.jumpingFromPlatformAnimation, state=%d\n", state);
    if (state != kSwingerJumping && !fallThrough) {
        state = kSwingerJumping;
        self.visible = YES;
        
        [self stopAnimation];
        //bodySprite.visible = NO;
        
        CCAnimate *runAction = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"jumpingStartAnimation"] restoreOriginalFrame:NO];
        CCCallFunc *jumpAction = [CCCallFunc actionWithTarget:self selector:@selector(runAndJump)];
        
        CCSequence * runAndJump = [CCSequence actions:runAction, jumpAction, nil];
        runAndJump.tag = runningTag;
        [self runAction: runAndJump];
    }
}

- (void) bouncingUpAnimation {
    
    if (state == kSwingerJumping || state == kSwingerInAir) {
        
        CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"bouncingUpAnimation"] restoreOriginalFrame:NO];
        animAction = [CCRepeatForever actionWithAction:action];
        animAction.tag = animationTag;
        
        [self runAction:animAction];
    }
}

- (void) runAndJump {    
    
    [self stopAnimation];
    //bodySprite.visible = NO;
    
    CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"jumpingAnimation"] restoreOriginalFrame:NO];
    animAction = [CCRepeatForever actionWithAction:action];
    animAction.tag = animationTag;
    
    [self runAction:animAction];
}

- (void) jumpingAnimation {
    
    CCLOG(@"In Player.jumpingAnimation, state=%d\n", state);
    if (state != kSwingerInAir || [currentCatcher gameObjectType] == kGameObjectSpring) {        
        state = kSwingerInAir;
        self.visible = YES;
        
        [self stopAnimation];
        //bodySprite.visible = NO;
        
        CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"jumpingAnimation"] restoreOriginalFrame:NO];
        animAction = [CCRepeatForever actionWithAction:action];
        animAction.tag = animationTag;
        
        [self runAction:animAction];
    }
}

- (void) jumpingEndAnimation {
    
    if (state == kSwingerJumping || state == kSwingerInAir) {
        self.visible = YES;
        [self stopAnimation];
        
        CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"jumpingEndAnimation"] restoreOriginalFrame:NO];
        animAction = [CCRepeatForever actionWithAction:action];
        animAction.tag = animationTag;
        
        [self runAction:animAction];
    }
}

- (void) flyingAnimation: (float) angle {
    
    CCLOG(@"In Player.flyingAnimation, angle=%f state=%d\n", angle, state);
    if (state != kSwingerInAir) {        
        state = kSwingerInAir;
        
        self.visible = YES;
        
        [self stopAnimation];
        //bodySprite.visible = NO;
        
        CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"flyingAnimation"] restoreOriginalFrame:NO];
        animAction = [CCRepeatForever actionWithAction:action];
        animAction.tag = animationTag;
        
        
        [self runAction:animAction];
        
        //self.flipX = NO;
        /*if(angle < 0) {
         self.flipY = YES;
         } else {
         self.flipY = NO;
         }*/
        
        isFlying = YES;
        launchAngle = angle;
        self.rotation = angle - 90; //30;// - 90; // rotate sprite to match launch angle
    }
}

- (void) landingAnimation {
    if (state != kSwingerLanding) {        
        state = kSwingerLanding;
        
        body->SetLinearVelocity(b2Vec2(0,0));
        
        [self stopAnimation];
        
        CCAnimate *action = [CCHeadBodyAnimate actionWithHeadBodyAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"landingAnimation"] restoreOriginalFrame:NO];
        
        animAction = [CCRepeatForever actionWithAction:action];
        animAction.tag = animationTag;
        self.rotation = 0;
        [self runAction:animAction];
    }
}

- (void) land {
    id land;
    if (landingScore < .85) {
        land = [CCCallFunc actionWithTarget:self selector:@selector(landingAnimation)];
    } else {
        land = [CCCallFunc actionWithTarget:self selector:@selector(balancingAnimation)];        
    }
    
    id delay = [CCDelayTime actionWithDuration:0.5f];
    id pose = [CCCallFunc actionWithTarget:self selector:@selector(posingAnimation)];
    
    id seq = [CCSequence actions:land, delay, pose, nil];
    [self runAction:seq];
    [self showCannonTrail:NO];
    
    [[GamePlayLayer sharedLayer] zoomInAndCenterOnPlayer];
}

- (void) fallingAnimation {
    // make the player fall straight down
    float xImp = -1*body->GetMass();
    float yImp = -2*body->GetMass();
    
    if (state != kSwingerKnockedOff) {
        CCLOG(@"In Player.fallingAnimation, state=%d speed=%f,%f\n", state,body->GetLinearVelocity().x,body->GetLinearVelocity().y);
        state = kSwingerKnockedOff;
        
        //body->SetLinearVelocity(b2Vec2(0,0));
        
        //currentCatcher = nil;
        //b2Filter noCollideWithPlayer;
        //noCollideWithPlayer.maskBits = 0;
        //noCollideWithPlayer.categoryBits = CATEGORY_JUMPER;
        //fixture->SetFilterData(noCollideWithPlayer);
        //fallThrough = YES;
        
        //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PLAYER_FALLING object:currentCatcher];
        
        [self doDestroyRunJoint];
        [self stopAnimation];
        //bodySprite.visible = NO;
        
        CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"fallingAnimation"] restoreOriginalFrame:NO];
        animAction = [CCRepeatForever actionWithAction:action];
        animAction.tag = animationTag;
        [self runAction:animAction];
    }
    
    body->ApplyLinearImpulse(b2Vec2(xImp, yImp), body->GetPosition());
    //body->SetLinearVelocity(b2Vec2(5,-5));
    
    //fallThrough = YES;
}

- (void) fallingFromPlatformAnimation {
    
    self.rotation = 0;
    if (state != kSwingerFalling) {
        //CCLOG(@"FALLING FROM PLATFORM ANIMATION!");
        state = kSwingerFalling;
        
        [self stopAnimation];
        //bodySprite.visible = NO;
        
        CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"jumpingEndAnimation"] restoreOriginalFrame:NO];
        animAction = [CCRepeatForever actionWithAction:action];
        animAction.tag = animationTag;
        [self runAction:animAction];
    }
}

/*- (void) balancingAnimation {
    [self balancingAnimation:NO];
}*/

- (void) bounceBackAnimation {
    if (state != kSwingerBouncingBack) {        
        state = kSwingerBouncingBack;
        
        /*[self stopAnimation];
         
         CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"jumpingEndAnimation"] restoreOriginalFrame:NO];
         animAction = [CCRepeatForever actionWithAction:action];
         animAction.tag = animationTag;
         self.rotation = 0;
         [self runAction:animAction];*/
        //[self platformRunningAnimation:1.f];
    }
}


- (void) crash {
    
    //if (state != kSwingerDizzy) {        
    //    state = kSwingerDizzy;
        
        /*[[AudioEngine sharedEngine] playEffect:SND_FOLLY];
         [[AudioEngine sharedEngine] playEffect:SND_DIZZY];
         
         [self stopAnimation];
         [self showCannonTrail: NO];
         
         animAction = [CCHeadBodyAnimate actionWithHeadBodyAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"crashingAnimation"] restoreOriginalFrame:NO];
         animAction.tag = animationTag;
         [self runAction:animAction];
         
         dizzyStars.visible = YES;
         CCAnimate *dizzy = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"dizzyAnimation"] restoreOriginalFrame:NO];
         id dizzyRepeat = [CCRepeatForever actionWithAction:dizzy];
         [dizzyStars runAction:dizzyRepeat]; */
        
        //        id delay = [CCDelayTime actionWithDuration:3.0f];
        //        id die = [CCCallFunc actionWithTarget:self selector:@selector(die)];
        //        id seq = [CCSequence actions:delay, die, nil];
        //        [self runAction:seq];
        
        //[[GamePlayLayer sharedLayer] zoomInAndCenterOnPlayer];
    //}
}

//- (void) die {
//    state = kSwingerDead;
//}

- (void) doBonusCoin {
    // reset the coin
    [coin stopAllActions];
    CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"coinAnimation"] restoreOriginalFrame:NO];
    CCRepeatForever *anim = [CCRepeatForever actionWithAction:action];
    [coin runAction:anim];
    
    float x=ssipadauto(18);
    float y=ssipadauto(40);
    if (state == kSwingerPosing) {
        x = ssipadauto(15);
    }
    
    coin.position = ccp(x,y);
    coin.visible = YES;
    
    id moveUp = [CCMoveBy actionWithDuration:.2f position:ccp(0,ssipad(300,150))];
    id moveDown = [CCMoveBy actionWithDuration:.1f position:ccp(0,ssipad(-150,-75))];
    id hide = [CCFadeOut actionWithDuration:0];
    id seq = [CCSequence actions:moveUp, moveDown, hide, nil];
    [coin runAction:seq];
    [[AudioEngine sharedEngine] playEffect:SND_BLOP];
    [[HUDLayer sharedLayer] addBonusCoin:1];
}

- (void) bonusCoins:(int)numCoins {
    
    NSMutableArray *coinActions = [NSMutableArray arrayWithCapacity:2*numCoins];
    for (int i=0; i < numCoins; i++) {
        id coinAction = [CCCallFunc actionWithTarget:self selector:@selector(doBonusCoin)];
        id delay = [CCDelayTime actionWithDuration:.3f];
        [coinActions addObject:coinAction];
        [coinActions addObject:delay];
    }
    
    id seq = [CCSequence actionsWithArray:coinActions];
    [self runAction:seq];
}


#pragma mark - GameObject protocol
- (void) updateObject:(ccTime)dt scale:(float)scale {    
    if (/*state == kSwingerFinishedLevel ||*/ state == kSwingerDead) {
        
        //if (body->GetContactList() == NULL) {
        //    body->SetActive(NO);
        //}
        /*if (state == kSwingerDead) {
         CCLOG(@" Game over detected!  player.position.y=%f\n", self.position.y);
         [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GAME_OVER object:nil];
         }*/
        
        if (dyingSound > 0) {
            [[AudioEngine sharedEngine] stopEffect:dyingSound];
            dyingSound = 0;
        }
        
        return;
    }
    
    if (state == kSwingerOnFinalPlatform) {
        self.rotation = 0;
        self.flipX = NO;
        self.flipY = NO;
        state = kSwingerFinishedLevel;
        //body->SetActive(NO);
        //[self scoreLanding];
        //[self land];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FINISHED_LEVEL object:nil];
        return;
    }
    
    xVelocity = body->GetLinearVelocity().x;
    
    /*
     if (state == kSwingerOnFloatingPlatform) {
     if (xVelocity < g_gameRules.runSpeed) {
     body->ApplyForce(b2Vec2(runAccelerationForce*body->GetMass(), 0), body->GetPosition());
     } else {
     body->ApplyForce(b2Vec2(-runDecelerationForce*body->GetMass(), 0), body->GetPosition());            
     }
     }
     */
    
    /*if (state == kSwingerFalling || (state == kSwingerInAir && body->GetLinearVelocity().y < 0)) {
        
        if (body->GetPosition().y <= 3 && !dyingSoundStarted) {
            dyingSound = [[AudioEngine sharedEngine] playEffect:SND_DYING loop:YES];
            dyingSoundStarted = YES;
        }
    }*/
    
    if (state == kSwingerFell) {
        
        if (!dyingSoundStarted) {
            dyingSound = [[AudioEngine sharedEngine] playEffect:SND_DYING loop:YES];
            dyingSoundStarted = YES;
            [[TouchCloudLayer sharedLayer] stopSpeedStreaks];
        }
        
        waitTime += dt;
        self.flipX = NO;
        self.flipY = NO;
        
        if (waitTime >= reviveWait && state != kSwingerDead) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GAME_OVER object:nil];
            state = kSwingerDead;
            [[AudioEngine sharedEngine] stopEffect:dyingSound];
            dyingSound = 0;
            [[AudioEngine sharedEngine] playEffect:SND_DEAD];
        }
    }
    
    if (state != kSwingerReviving && state != kSwingerFinishedLevel && state != kSwingerDead && state != kSwingerFell && body->GetPosition().y <= -(((bodyHeight*scaleFactor)/PTM_RATIO) + 1.5)) {

        waitTime = 0;
        state = kSwingerFell;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PLAYER_FELL object:nil];
        body->SetActive(NO);
    }
    
    //if (state == kSwingerReviving) {
    //    CCLOG(@"VELOCITY: (%f,%f)", body->GetLinearVelocity().x, body->GetLinearVelocity().y);
    //}
    
    if ((state == kSwingerReviving || revivePowerUp.state == kPowerUpActivated) && body->GetLinearVelocity().y < 0 && body->GetPosition().y <= 0) {
        //
        CCLOG(@"FELL DURING REVIVAL - TRYING AGAIN!");
        [self revive: YES];
    }
    
    if (isBounceBackRequired) {
        [self bounceBack];
        //return;
    }
    
    // XXX - TEMP FIX FOR DIFFERENT OBJECTS MESSING UP PLAYERS ROTATION
    if(state != kSwingerLooping && body->GetAngle() != 0) {
        // fix rotation
        body->SetTransform(body->GetPosition(), 0);
    }
    
    // Apply a y-offset to the sprite to make sure all animations display at the appropriate
    // height.  This is needed because the box2d object is sized based on the swinging 
    // animation, and other animations are not the same size, which can result in the player
    // "floating" above the ground.
    float yOffset = ssipad(-20, -10);
    float xOffset = 6;
    
    if (state == kSwingerOnBoulder) {
        yOffset = ssipad(-10, -5);
    } else if (state == kSwingerSwinging) {
        yOffset = ssipad(-40, -20);
        xOffset = ssipad(40, 20);
    } else if (state == kSwingerInAir || state == kSwingerHovering) {
        if (isFlying) {
            xOffset = -6;
            //if (launchAngle > 0) {
            //    yOffset = ssipad(50, 25);
            //}
        } //else {
            yOffset = ssipad(10, 5);
        //}
    } else if (state == kSwingerFalling || state == kSwingerKnockedOff) {
        yOffset = ssipad(-14, -7);
    }
    
    /*if (state == kSwingerFell || state == kSwingerDizzy || state == kSwingerDead) {
     float cosAngle = fabs(cosf(body->GetAngle()));
     if (cosAngle <= 0.7 ) {
     yOffset = ssipadauto(-3); //-12
     } else {
     yOffset = ssipadauto(-5); //-15
     }
     } else if (state == kSwingerPosing) {
     yOffset = ssipadauto(18);//11
     } else if (state == kSwingerLanding) {
     yOffset = ssipadauto(14);//7
     } else if (state == kSwingerBalancing) {
     yOffset = ssipadauto(11);//3
     } else if (state == kSwingerOnBoulder || kSwingerOnFloatingPlatform) {
     //yOffset = ssipadauto(16);//16
     //xOffset = ssipadauto(4);
     } else if (state == kSwingerOnSpring) {
     yOffset = ssipadauto(20);
     xOffset = ssipadauto(0);
     } else if (isFlying) {
     yOffset = ssipadauto(16);
     xOffset = ssipadauto(-10);
     }*/
    xOffset *= scaleFactor;
    yOffset *= scaleFactor;
    
    //CCLOG(@"STATE == %d", state);
    
    if (state == kSwingerOnFloatingPlatform || state == kSwingerOnFinalPlatform) {
        
        //CCLOG(@"-----------PLAYER SPEED %f------------", body->GetLinearVelocity().x);
        float maxSpeed = runSpeed*speedFactor;
        float pace = body->GetLinearVelocity().x/maxSpeed;
        BOOL noContact = ![self hasContact];
        BOOL runJointNull = runJoint == NULL;
        
        //CCLOG(@"CONTACT EDGE IS NULL? %d, runJoint is Null? %d", noContact, runJointNull);
        
        if (speedFactor <= 1 && scaleFactor <= 1 && noContact && runJointNull && body->GetPosition().y <= [currentCatcher getPhysicsBody]->GetPosition().y) {
            // falling from floating platform
            [self fallingFromPlatformAnimation];
            
            if (body->GetLinearVelocity().x > 0) {
                body->ApplyLinearImpulse(b2Vec2(-(body->GetLinearVelocity().x*body->GetMass()*(0.35*speedFactor)), 0), body->GetWorldCenter());
            }
        } else {
            
            if (body->GetLinearVelocity().x < maxSpeed && !isBounceBackRequired) {
                // Player is slowing down due to running up a hill. Maintain speed
                //CCLOG(@"-------------PLAYER PICKING UP SPEED...-------------");
                float yVel = body->GetLinearVelocity().y;
                
                if (body->GetContactList() != NULL) {
                    yVel = 0;
                }
                
                body->ApplyLinearImpulse(b2Vec2(maxSpeed, 0), body->GetPosition());
                //body->SetLinearVelocity(b2Vec2(speedFactor*runSpeed, yVel));
            } else if (body->GetLinearVelocity().x > 1.5*maxSpeed) {
                // Player is going too fast, slow him down
                //CCLOG(@"-------------PLAYER SLOWING DOWN TO MATCH MAX SPEED...:----------");
                body->ApplyLinearImpulse(b2Vec2(-maxSpeed, 0), body->GetPosition());
            }
        
            //if (runJoint != NULL) {
                
                if (pace < 0.5) {
                    pace = 0.5;
                } else if (pace > speedFactor) {
                    pace = speedFactor;
                }
                
                if ([currentCatcher isKindOfClass: [CurvedPlatform class]]) {
                    pace = 1;
                }
                
                if (speedFactor > 1) {
                    pace = speedFactor;
                }
            
            
                [self platformRunningAnimation: pace];
            //}
        }
        
        //CCLOG(@"PLAYER SPEED %f, %f, gravity: %f", body->GetLinearVelocity().x, body->GetLinearVelocity().y, body->GetGravityScale());
        
        if (createRunJoint) {
            
            if (!fallThrough && /*![currentCatcher isKindOfClass: [FloatingBlock class]] &&*/
                ![currentCatcher isKindOfClass: [CurvedPlatform class]]) {
                
                [self doDestroyRunJoint];
                
                if ([currentCatcher isKindOfClass: [FloatingPlatform class]]) {
                    
                    FloatingPlatform *fp = (FloatingPlatform *)currentCatcher;
                    if (self.position.x <= (fp.position.x + fp.width)-ssautores(2.5)) {
                        
                        // Create a prismatic joint to hold the player steady on the moving platform.
                        // This prevents the player from shaking around so much and looks much smoother.
                        createRunJoint = NO;
                        b2PrismaticJointDef runJointDef;
                        runJointDef.Initialize(body, [currentCatcher getPhysicsBody], b2Vec2(0, -bodyHeight), b2Vec2(1, 0));
                        runJointDef.collideConnected = NO;
                        runJoint = (b2PrismaticJoint *)world->CreateJoint(&runJointDef);
                    } else {
                        //CCLOG(@"NOT CREATING JOINT!");
                        createRunJoint = NO;
                    }
                } else {
                    createRunJoint = NO;
                }
            } else {
                createRunJoint = NO;
            }
        } else if (runJoint != NULL) {
            
            if (destroyRunJoint) {
                destroyRunJoint = NO;
                [self doDestroyRunJoint];
            } else {
                
                if (![currentCatcher isKindOfClass: [FloatingPlatform class]]) {
                    [self doDestroyRunJoint];
                }
                else if (![currentCatcher isKindOfClass: [FinalPlatform class]]) {
                    // If the player is at the edge of the platform, destroy the joint so he can fall off the edge
                    FloatingPlatform *fp = (FloatingPlatform *)currentCatcher;
                    if (self.position.x > (fp.position.x + fp.width)-ssautores(2.5) || fallThrough) {
                        [self doDestroyRunJoint];
                    }
                }
            }
        }
    }
    
    if (state == kSwingerBouncingBack) {
        
        float threshold = 0.1f;
        float currXPos = body->GetPosition().x;
        float diffXPos = fabsf(bounceXPos - currXPos);
        
        if (xVelocity <= 0 && diffXPos >= threshold) {
            // allow him to bounce back a little before stopping and going forward
            //[self run];//: ccp(body->GetPosition().x/PTM_RATIO, body->GetPosition().y/PTM_RATIO)];
            //body->ApplyLinearImpulse(b2Vec2(diffXPos, 0), body->GetPosition());
            bounceXPos = 0;
            state = kSwingerOnFloatingPlatform;
        }
    }
    
#if USE_FIXED_TIME_STEP == 1
    const float oneMinusRatio = 1.f - fixedPhysicsSystem->fixedTimestepAccumulatorRatio;
    self.position = CGPointMake((body->GetPosition().x * fixedPhysicsSystem->fixedTimestepAccumulatorRatio + oneMinusRatio * previousPosition.x) * PTM_RATIO + xOffset, 
                                (body->GetPosition().y * fixedPhysicsSystem->fixedTimestepAccumulatorRatio + oneMinusRatio * previousPosition.y) * PTM_RATIO + yOffset);
#else
    self.position = CGPointMake((body->GetPosition().x) * PTM_RATIO + xOffset, 
                                (body->GetPosition().y) * PTM_RATIO + yOffset);    
#endif
    
    if (state == kSwingerFinishedLevel) {
        
        body->SetLinearVelocity(b2Vec2(speedFactor*runSpeed, 0));
        
        return;
    }
    
    if (state != kSwingerNone && state != kSwingerFalling && state != kSwingerKnockedOff) {
        // start trail when player goes fast enough
        /*float threshold = 50.f;
         BOOL showTrail = NO;
         if (fabsf(body->GetLinearVelocity().x) >= threshold || fabsf(body->GetLinearVelocity().y) >= threshold) {
         showTrail = YES;
         }
         
         [self showTrail: showTrail];*/
        
        if (trail.visible) {
            trail.position = ccp(self.position.x + ssipadauto(10), self.position.y - ssipadauto(20));
            
            if (isFlying) {
                float rotation = 0;
                b2Vec2 vel = body->GetLinearVelocity();
                
                if (self.rotation - 10 == 0) {
                    // going straight up
                    if (vel.y > 0) {
                        rotation = -10;
                    } else if (vel.y < 0) {
                        rotation = 10;
                    }
                }
                
                trail.rotation = rotation;
            } else {
                trail.rotation = 0;
            }
        }
    }
    
    float currentVelocity = body->GetLinearVelocity().y;
    
    // If we are swinging, set the visible sprite to the appropriate frame based on the rotation
    if(state == kSwingerInCannon)
    {
        //CCSpriteFrame * frame = [jumpFrames objectAtIndex:0];
        
        //[self setDisplayFrame: frame];
        [self setVisible: NO];
    } 
    else if (state == kSwingerJumping) {
        if (isJumpHeldDown) {
            body->ApplyForce(b2Vec2(0.0f, body->GetMass()*floatForce), body->GetPosition());
        }
        
        if (prevVelocity > 0 && currentVelocity <= 0) {
            // change to jump end animation
            [self jumpingEndAnimation];
        } /*else if (prevVelocity <= 0 && currentVelocity > 0) {
            [self bouncingUpAnimation];
        }*/
        else if (body->GetLinearVelocity().x <= -2) {
            //body->ApplyForce(b2Vec2(15, 0), body->GetPosition());
            body->SetLinearVelocity(b2Vec2(-0.5,0));
        }
        
        prevVelocity = currentVelocity;
    }
    else if(state == kSwingerInAir) {
        /*if(currentWind != nil) {
            [currentWind blow: body];
            currentWind = nil;
        }*/
        
        if (isFlying) {
            // Fix rotation if flying
            
            if (prevVelocity > 0 && currentVelocity <= 0) {
                // player is coming down
                float angle = 0;
                
                //if (launchAngle == 0 || self.flipY || launchAngle < 0) {
                    angle = 90;
                    float duration = 0.75f;
                    
                    if (launchAngle < 0) {
                        duration = 0.45f;
                    }
                
                    CCRotateBy *rotate = [CCRotateBy actionWithDuration:duration angle: angle];
                    rotate.tag = rotationTag;
                
                    [self runAction: rotate];
                    isFlying = NO;
                //} else {
                    //state = kSwingerNone; // have to set this for swinging animation to take
                    //[self jumpingAnimation];
                    
                    isFlying = NO;
                //}
            }
            
            prevVelocity = currentVelocity;
        } else {
            
            if (prevVelocity > 0 && currentVelocity <= 0) {
                // change to jump end animation
                [self jumpingEndAnimation];
            } /*else if (prevVelocity <= 0 && currentVelocity > 0) {
                [self bouncingUpAnimation];
            }*/
            
            prevVelocity = currentVelocity;
        }
        
        // limiting the players world bounds - x only
        /*float32 xPos = body->GetPosition().x * PTM_RATIO;
         
         if (xPos <= -(screenSize.width/4)) {
         body->SetLinearVelocity(b2Vec2(0, (body->GetLinearVelocity().y)));
         } else if (xPos >= [GamePlayLayer sharedLayer].finalPlatformRightEdge + ((screenSize.width/4)*self.scale)) {
         body->SetLinearVelocity(b2Vec2(0, (body->GetLinearVelocity().y)));
         }*/
    }
    
    if (self.scale != scaleFactor) {
        [self createScaledPhysicsObject: scaleFactor];
    }
    
    if (currentPower != nil && state != kSwingerDead /*&& state != kSwingerDizzy*/ && state != kSwingerFell) {
        
        if ([currentPower gameObjectType] == kGameObjectJetPack) {
            
            if (isJumpHeldDown) {
                
                [self doDestroyRunJoint];
                [self hoveringAnimation];
                
                // send him up
                float force = fabsf((body->GetGravityScale() * world->GetGravity().y));
                float xVel = body->GetLinearVelocity().x;
                float yVel = body->GetLinearVelocity().y;
                
                if (yVel < 0) {
                    yVel = 0;
                } else {
                    yVel = 3;
                }
                
                if (xVel < 0) {
                    xVel = 0;
                } else if (xVel > 5) {
                    xVel = 6;
                }
                
                body->SetLinearVelocity(b2Vec2(xVel,yVel));
                //body->SetLinearVelocity(b2Vec2(0,0));
                //body->ApplyLinearImpulse(b2Vec2(3*body->GetMass(),(force/5)*body->GetMass()), body->GetPosition());
                body->ApplyForce(b2Vec2(10, force*body->GetMass()), body->GetPosition());
            } else if (body->GetContactList() == NULL) {
                // send him down
                //body->SetLinearVelocity(b2Vec2(2*body->GetMass(),0));
                body->ApplyForce(b2Vec2(body->GetMass()*20,0.0), body->GetPosition());
            }
        } else if ([currentPower gameObjectType] == kGameObjectAngerPotion) {
            
            float scale = [(AngerPotion*) currentPower getSizeScale];
            
            if (scale != scaleFactor) {
                
                if (state != kSwingerInAir && state != kSwingerJumping) {
                    body->SetLinearVelocity(b2Vec2(0,0));
                }
                
                [self createScaledPhysicsObject: scale];
                
                if (body->GetLinearVelocity().y <= 0) {
                    // bump him up to stay on platform
                    body->ApplyLinearImpulse(b2Vec2(0,8*body->GetMass()), body->GetPosition());
                }
            }
            
            speedFactor = 1;
        }
    }
    
    // Player has caught catcher
    if (isCaught) {
        isCaught = NO;
        [self processContactWithCatcher: currentCatcher];
        
        //if ([currentCatcher gameObjectType] != kGameObjectCannon) {
        [self showCannonTrail: NO];
        //}
    }
}

- (void) waitForStore {
    //
    waitTime = reviveWait - 1;
}

- (BOOL) hasContact {
    
    BOOL contactDetected = NO;
    
    if (body->GetContactList() != NULL) {
    
        for (b2ContactEdge* ce = body->GetContactList(); ce; ce = ce->next) {
            
            if (ce->other->GetUserData() == currentCatcher) {
                contactDetected = YES;
                break;
            }
        }
    }
    
    //CCLOG(@"CONTACT DETECTED %d", contactDetected);
    
    return contactDetected;
}

- (BOOL) revive {
    
    return [self revive: NO];
}

- (BOOL) revive: (BOOL) retry {
    
    if (state != kSwingerDead) {
        CCLOG(@"----------PLAYER REVIVED---------");
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PLAYER_REVIVED object:[NSNumber numberWithBool:retry]];
        
        self.visible = YES;
        body->SetActive(YES);
        
        // disable all powerups
        [[GamePlayLayer sharedLayer] deactivateAllPowerups: revivePowerUp];
        b2Vec2 distance = [[GamePlayLayer sharedLayer] getDistanceToNearestPlatform];
        
        if (distance.x == 0.0f && distance.y == 0.0f) {
            
            state = kSwingerDead;
            return NO;
        }
        
        if (dyingSound > 0) {
            [[AudioEngine sharedEngine] stopEffect:dyingSound];
            dyingSound = 0;
        }
        
        dyingSoundStarted = NO;
        
        if (currentPower != nil && currentPower != revivePowerUp) {
            [currentPower deactivate];
        }
        
        // activate revive power up
        if (revivePowerUp.state == kPowerUpActivated) {
            [revivePowerUp reset];
        }
        [revivePowerUp activate];
        
        float positionX = body->GetPosition().x;
        float buffer = ssipadauto(200);
        
        if (positionX*PTM_RATIO > [GamePlayLayer sharedLayer].finalPlatformRightEdge - buffer) {
            //
            positionX = ([GamePlayLayer sharedLayer].finalPlatformRightEdge - buffer)/PTM_RATIO;
        }
        
        body->SetTransform(b2Vec2(positionX, 0), 0);
        body->SetLinearVelocity(b2Vec2(0,0));
        body->SetActive(false);
        
        float angle = 30;
        [self flyingAnimation: angle];
        state = kSwingerReviving;
        isFlying = YES;
        self.visible = YES;
        
        // equation derived from http://hyperphysics.phy-astr.gsu.edu/Hbase/traj.html#tra5
        // height = Ypeak = v0y^2/2g
        // width * 2 = (2Vox * Voy)/g
        float g = fabsf(world->GetGravity().y*body->GetGravityScale());
        float yForce = sqrtf(((distance.y + (retry ? 5 : 5))*2*g));
        float xForce = (((distance.x*2*g)/yForce)/2) + 2;// + 5;
        
        b2Vec2 impForce = b2Vec2(xForce, yForce);
        
        if (impForce.x <= 0) {
            //impForce.x = 3;
        }
        
        body->SetActive(true);
        //body->SetLinearVelocity(b2Vec2(0,0));
        body->SetLinearVelocity(impForce);
        waitTime = 0;
        fallThrough = NO;
        
        CCLOG(@"---------B2Vec2(%f,%f)------------", impForce.x, impForce.y);
        
        return YES;
    }
    
    return NO;
}

- (GameObjectType) gameObjectType {
    return kGameObjectJumper;
}

- (void) show {
    
}

- (void) hide {
    
}

- (BOOL) isSafeToDelete {
    return isSafeToDelete;
}

- (void) safeToDelete {
    isSafeToDelete = YES;
}


#pragma mark - PhysicsObject protocol
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


- (b2Body*) getPhysicsBody {
    return body;
}


- (void) destroyPhysicsObject {
    if (world != NULL) {
        world->DestroyBody(body);
    }
}

- (void) resetGravity {
    
    if (body != nil) {
        body->SetGravityScale(g_gameRules.gravity);
    }
}

#pragma mark - Cleanup
- (void) stopAnimation {
    // Stop it by tag, becaue if animation is done, 
    // it will point to garbage causing it to crash.
    [self stopActionByTag:animationTag];
    [self stopActionByTag:runningTag];
    [self stopActionByTag:rotationTag];
    [self stopActionByTag:cannonActionTag];
    animAction = nil;
    runSpeedAction = nil;
    
    self.anchorPoint = ccp(0.5, 0.5);
    
    [dizzyStars stopAllActions];
    dizzyStars.visible = NO;
    
    // unflip
    //self.flipX = NO;
    //bodySprite.flipX = NO;
    //bodySprite.visible = YES;
}

- (void) dealloc {
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [swingHeadFrames release];
    swingHeadFrames = nil;
    [swingBodyFrames release];
    swingBodyFrames = nil;
    [self removeChild:coin cleanup:YES];
    [trail removeFromParentAndCleanup:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_POWERUP_ACTIVATED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_POWERUP_DEACTIVATED object:nil];
    
    /*if (revivePowerUp != nil) {
        CCLOG(@"---------Deallocating revive power up from player--------");
        [revivePowerUp destroyPhysicsObject];
        [revivePowerUp release];
        revivePowerUp = nil;
    }*/
    
    [super dealloc];
}

@end
