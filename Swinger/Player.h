//
//  Player.h
//  SwingProto
//
//  Created by James Sandoz on 3/25/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Box2D.h"
#import "GameObject.h"
#import "PhysicsObject.h"
#import "CatcherGameObject.h"
#import "PhysicsSystem.h"
#import "PlayerFire.h"
#import "PlayerTrail.h"
#import "FloatingPlatform.h"
#import "AudioEngine.h"

typedef enum {
    kSwingerNone,                   // 0
    kSwingerSwinging,               // 1
    kSwingerInAir,                  // 2
    kSwingerLanding,                // 3
    kSwingerPosing,                 // 4
    kSwingerFalling,                // 5
    kSwingerInCannon,               // 6
    kSwingerOnSpring,               // 7
    kSwingerOnBoulder,              // 8
    kSwingerOnFinalPlatform,        // 9
    kSwingerFinishedLevel,          // 10
    kSwingerFell,                   // 11
    kSwingerReviving,               // 12
    kSwingerBalancing,              // 13
    kSwingerDead,                   // 14
    kSwingerOnFloatingPlatform,     // 15
    kSwingerJumping,                // 16
    kSwingerBouncingBack,           // 17
    kSwingerLooping,                // 18
    kSwingerHovering,               // 19
    kSwingerSkidding,               // 20
    kSwingerKnockedOff,             // 21 - knocked off by enemy
} SwingerState;

@class CatcherGameObject;
@class RopeSwinger;
@class Cannon;
@class Wind;
@class FloatingPlatform;
@class PowerUp;
@class Enemy;

@interface Player : CCSprite<GameObject, PhysicsObject> {
    int gameObjectId;

    CGSize screenSize;
    
    b2World *world;
    b2Body *body;
    b2Fixture *fixture;
    b2Fixture *bottomFixture;
    b2Joint *jointWithCatcher;
    float bodyWidth;
    float bodyHeight;
    
    float jumpForce;
    float floatForce;
    float runSpeed;
    float speedFactor;
    float scaleFactor;
    
    FloatingPlatform * lastPlatform;
    float landingVelocity;
    
    ContactLocation top;
    ContactLocation bottom;
    
    //CCSprite *bodySprite;
    PlayerType playerType;
    
    BOOL receivedFirstJumpInput;
    BOOL isCaught;
    BOOL playerAdvanced;
    BOOL isSafeToDelete;
    BOOL isJumpHeldDown;
    BOOL isBounceBackRequired;
    BOOL fallThrough;
    float bounceXPos;
    
    SwingerState state;

    Wind * currentWind;
    
    int fromCurrentCatcherIndex;
    int numCatchersSkipped;
    CCNode<GameObject, PhysicsObject, CatcherGameObject>  *currentCatcher; // current catcher eg. RopeSwinger, Cannon etc...
    CCNode<GameObject, PhysicsObject, CatcherGameObject>  *previousCatcher; // current catcher eg. RopeSwinger, Cannon etc...
    
    b2Vec2 previousPosition;
    b2Vec2 smoothedPosition;
    float previousAngle;
    float smoothedAngle;

#if USE_FIXED_TIME_STEP == 1
    PhysicsSystem *fixedPhysicsSystem;
#endif
        
    CCAction *animAction;
    CCSpeed  *runSpeedAction;
    CCSpeed  *stepSpeedAction;
    
    CCSprite *dizzyStars;
    
    float landingScore;
    CCSprite *coin;
    
    BOOL   dyingSoundStarted;
    ALuint dyingSound;
    
    BOOL  isFlying; // 
    BOOL  isJumpingFromPlatform;
    float jumpHeight;
    BOOL  bounceRequested;
    float launchAngle; // angle that the player took flight
    float prevVelocity;  // used to track when flying player starts falling
    float waitTime;
    
    CGPoint catchLocation;
    
    float xVelocity;
    
    // particle effects
    PlayerTrail *trail;
    PlayerFire *fire;
    
    // prismatic joint to hold player on moving platforms
    BOOL createRunJoint;
    BOOL destroyRunJoint;
    BOOL firstContact;
    b2PrismaticJoint *runJoint;
    
    // Powerups
    PowerUp * currentPower;
    PowerUp * revivePowerUp;
    int numJumpsAllowed;
}

- (id) initWithPlayerSkin:(PlayerType) pType;

- (void) initPlayer:(CatcherGameObject *) initialCatcher;
- (void) moveTo:(CGPoint)pos;

- (BOOL) handleTouchEvent;
- (BOOL) handleTapEvent;
- (BOOL) handleSwipeEvent;

- (void) jump;
- (void) land;
- (void) setOnFire: (BOOL) onFire;

- (void) doTouchAction;
- (void) gripRanOut;
- (void) fallingAnimation;
- (void) fallingFromPlatformAnimation;
- (void) swingingAnimation;
- (void) jumpingAnimation;
- (void) jumpingFromPlatformAnimation;
- (void) bouncingUpAnimation;
- (void) landingAnimation;
- (void) flyingAnimation: (float) angle;
- (void) bouncingAnimation : (float) delay;
- (void) boulderRunningAnimation : (float) delay;
- (void) platformRunningAnimation: (float) delay;
- (void) loopingAnimation;
- (void) stopAnimation;
- (void) skiddingAnimation;
- (void) setupAnimationsWithPlayerSkin:(PlayerType)pType;
- (void) flip:(BOOL)flipX;
- (void) showCannonTrail: (BOOL) show;
- (BOOL) revive;
- (void) resetGravity;
- (BOOL) willKill;
- (void) enemyKilled: (Enemy*)enemy;
- (void) waitForStore;

- (void) catchCatcher:(CCNode<GameObject, PhysicsObject, CatcherGameObject>*)newCatcher;
- (void) catchCatcher:(CCNode<GameObject, PhysicsObject, CatcherGameObject>*)newCatcher at: (CGPoint) location;
- (void) processContactWithCatcher:(CCNode<GameObject, PhysicsObject, CatcherGameObject>*)catcher;

- (void) bonusCoins:(int)numCoins;

@property (nonatomic, readonly) BOOL receivedFirstJumpInput;
@property (nonatomic, readonly) BOOL isCaught;
@property (nonatomic, readonly) float bodyWidth;
@property (nonatomic, readonly) float bodyHeight;
@property (nonatomic, readwrite, assign) Wind *currentWind;
@property (nonatomic, readonly) PowerUp *currentPower;
@property (nonatomic, readonly) PowerUp *revivePowerUp;
@property (nonatomic, readwrite, assign) FloatingPlatform * lastPlatform;
@property (nonatomic, readwrite, assign) SwingerState state;
@property (nonatomic, readwrite, assign) CCNode<GameObject, PhysicsObject, CatcherGameObject> *currentCatcher;
@property (nonatomic, readwrite, assign) float landingScore;
@property (nonatomic, readwrite, assign) PlayerType playerType;
@property (nonatomic, readwrite, assign) BOOL isJumpHeldDown;
@property (nonatomic, readwrite, assign) BOOL fallThrough;
@property (nonatomic, readwrite, assign) float scaleFactor;
@property (nonatomic, readwrite, assign) float speedFactor;
@property (nonatomic, readwrite, assign) int numJumpsAllowed;

@end
