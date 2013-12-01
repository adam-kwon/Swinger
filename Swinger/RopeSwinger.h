//
//  RopeSwinger.h
//  SwingProto
//
//  Created by James Sandoz on 3/16/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Box2D.h"
#import "GameObject.h"
#import "PhysicsObject.h"
#import "CatcherGameObject.h"
#import "Wind.h"
#import "BaseCatcherObject.h"
#import "Player.h"
#import "VRope.h"

typedef enum {
    kSignPositive,
    kSignNegative
} SignType;


@interface RopeSwinger : BaseCatcherObject {
    CGPoint anchorPos;
    CCNode *parent;
    
    b2Fixture *catcherFixture;
    b2Fixture *magneticGripFixture;
    b2Body    *capBody;
    b2Body    *endBody;
    b2Body    *lastSegmentBody;
    b2Joint   *jointWithPlayer;
    
    CCSprite *catcherSprite;
    //CCLayerColor *rope;
    VRope    *rope;
    CCSprite *treeSprite;
    CCSprite *cap;
    CCSprite *swingerHead;
    CCSprite *swingerBody;
    
    CGPoint ropeSwivelPosition;
    CGPoint playerLocation;
 
    float scrollBufferZone;
    
    BOOL playerCaught;
    BOOL playerReleased;
    BOOL doDetach;
    BOOL doDrop;
    
    double dtSum;
    float swingAngle;
    float gravity;
    float ropeLength;
    float swingScale;
    float period;
    float grip;
    
    b2Vec2 jumpForce;
    
    b2MouseJoint *mouseJoint;
    
    // joint to hold the rope body in the proper position when not swinging
    b2Joint *steadyJoint;
    
    float poleScale;
    
    SignType previousSign;
    SignType sign;
    
    BOOL trajectoryDrawn;
    CCArray *dashes;
    
    NSMutableArray *ropeSegments;
}

- (void) showAt:(CGPoint)pos;
- (void) createMagneticGrip : (float) radius;
- (void) destroyMagneticGrip;
- (void) calcJumpForce;
- (void) attach: (Player *) player at: (CGPoint) location;
- (void) detach: (Player *) player;
- (void) dropCatcher;
- (void) setCatchBody:(b2Body *)cBody;
- (BOOL) caughtPlayer;

@property (nonatomic, readwrite, assign) float swingAngle;
@property (nonatomic, readwrite, assign) float swingScale;
@property (nonatomic, readwrite, assign) float period;
@property (nonatomic, readwrite, assign) float grip;
@property (nonatomic, readwrite, assign) float poleScale;
@property (nonatomic, readonly) CCSprite *treeSprite;
@property (nonatomic, readonly) CCSprite *catcherSprite;
@property (nonatomic, readonly) CGPoint anchorPos;
@property (nonatomic, readonly) CGPoint ropeSwivelPosition;
@property (nonatomic, readonly) b2Vec2 jumpForce;

@end
